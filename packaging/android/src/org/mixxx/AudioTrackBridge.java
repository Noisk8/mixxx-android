package org.mixxx;

import android.content.Context;
import android.media.AudioAttributes;
import android.media.AudioDeviceInfo;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import java.nio.ByteBuffer;
import java.util.concurrent.ConcurrentHashMap;
import org.json.JSONObject;

public final class AudioTrackBridge {
    private static final String TAG = "MixxxAudioRoutes";
    private static final ConcurrentHashMap<Integer, AudioTrackBridge> OPEN = new ConcurrentHashMap<>();
    private final AudioTrack track;
    private final int deviceId;
    private final int frameBytes;
    private volatile boolean invalidRoute;
    private volatile boolean closed;

    private AudioTrackBridge(AudioTrack track, int deviceId, int channels) {
        this.track = track;
        this.deviceId = deviceId;
        frameBytes = channels * Float.BYTES;
        track.addOnRoutingChangedListener(router -> {
            if (closed) { return; }
            AudioDeviceInfo routed = track.getRoutedDevice();
            if (routed != null && routed.getId() != deviceId) {
                invalidRoute = true;
                try { track.pause(); } catch (IllegalStateException ignored) { }
                Log.e(TAG, "USB output changed unexpectedly: expected=" + deviceId
                        + " actual=" + routed.getId());
                HardwareBridge.outputFailed();
            }
        }, new Handler(Looper.getMainLooper()));
    }

    public static AudioTrackBridge create(Context context, int deviceId,
            int sampleRate, int channels, int frames) {
        AudioTrack track = null;
        try {
            AudioManager manager = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
            AudioDeviceInfo selected = null;
            for (AudioDeviceInfo device : manager.getDevices(AudioManager.GET_DEVICES_OUTPUTS)) {
                if (device.getId() == deviceId) {
                    selected = device;
                    break;
                }
            }
            if (selected == null || channels != 4 || frames <= 0) {
                throw new IllegalArgumentException("Four-channel USB output unavailable");
            }
            AudioFormat format = new AudioFormat.Builder()
                    .setEncoding(AudioFormat.ENCODING_PCM_FLOAT)
                    .setSampleRate(sampleRate)
                    .setChannelIndexMask(0xF)
                    .build();
            int minimum = AudioTrack.getMinBufferSize(sampleRate,
                    AudioFormat.CHANNEL_OUT_QUAD, AudioFormat.ENCODING_PCM_FLOAT);
            if (minimum <= 0) {
                throw new IllegalArgumentException("Unsupported four-channel format");
            }
            int frameBytes = channels * Float.BYTES;
            int bufferBytes = Math.max(minimum, frames * frameBytes * 3);
            bufferBytes = ((bufferBytes + frameBytes - 1) / frameBytes) * frameBytes;
            track = new AudioTrack.Builder()
                    .setAudioAttributes(new AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_MEDIA)
                            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC).build())
                    .setAudioFormat(format)
                    .setTransferMode(AudioTrack.MODE_STREAM)
                    .setBufferSizeInBytes(bufferBytes)
                    .setPerformanceMode(AudioTrack.PERFORMANCE_MODE_NONE)
                    .build();
            if (track.getState() != AudioTrack.STATE_INITIALIZED
                    || track.getChannelCount() != channels
                    || track.getSampleRate() != sampleRate
                    || track.getFormat().getChannelIndexMask() != 0xF
                    || !track.setPreferredDevice(selected)) {
                throw new IllegalStateException("Android rejected independent USB channels");
            }
            Log.i(TAG, "AudioTrack USB id=" + deviceId + " channels=" + channels
                    + " indexMask=0xf sampleRate=" + sampleRate
                    + " bufferFrames=" + track.getBufferSizeInFrames()
                    + " session=" + track.getAudioSessionId());
            AudioTrackBridge bridge = new AudioTrackBridge(track, deviceId, channels);
            OPEN.put(deviceId, bridge);
            return bridge;
        } catch (RuntimeException e) {
            if (track != null) {
                track.release();
            }
            Log.e(TAG, "Cannot open independent USB output", e);
            return null;
        }
    }

    public boolean start() {
        try {
            track.play();
            return true;
        } catch (RuntimeException e) {
            Log.e(TAG, "Cannot start USB output", e);
            return false;
        }
    }

    public int write(ByteBuffer buffer, int offset, int bytes) {
        if (invalidRoute) {
            return AudioTrack.ERROR_DEAD_OBJECT;
        }
        buffer.limit(offset + bytes);
        buffer.position(offset);
        return track.write(buffer, bytes, AudioTrack.WRITE_BLOCKING);
    }

    public void interrupt() {
        invalidRoute = true;
        try { track.pause(); track.flush(); } catch (IllegalStateException ignored) { }
    }

    public int bufferFrames() {
        return track.getBufferSizeInFrames();
    }

    public int playbackHead() { return track.getPlaybackHeadPosition(); }
    public int underrunCount() { return track.getUnderrunCount(); }

    private synchronized void logState() {
        if (closed) { return; }
        AudioDeviceInfo routed = track.getRoutedDevice();
        Log.i(TAG, "USB session=" + track.getAudioSessionId() + " selectedId=" + deviceId
                + " routedId=" + (routed == null ? -1 : routed.getId())
                + " channels=" + track.getChannelCount()
                + " indexMask=" + track.getFormat().getChannelIndexMask()
                + " underruns=" + track.getUnderrunCount()
                + " bufferFrames=" + track.getBufferSizeInFrames());
        try {
            JSONObject sample = new JSONObject();
            sample.put("type", "audio");
            sample.put("selectedId", deviceId);
            sample.put("routedId", routed == null ? -1 : routed.getId());
            sample.put("channels", track.getChannelCount());
            sample.put("indexMask", track.getFormat().getChannelIndexMask());
            sample.put("underruns", track.getUnderrunCount());
            sample.put("bufferFrames", track.getBufferSizeInFrames());
            sample.put("sampleRate", track.getSampleRate());
            SessionDiagnostics.record(sample.toString());
        } catch (Exception e) { Log.w(TAG, "Cannot record USB measurements", e); }
    }

    public static void logAll() {
        for (AudioTrackBridge bridge : OPEN.values()) { bridge.logState(); }
    }

    public synchronized void close() {
        closed = true;
        OPEN.remove(deviceId, this);
        Log.i(TAG, "AudioTrack closed id=" + deviceId + " underruns="
                + track.getUnderrunCount() + " frameBytes=" + frameBytes);
        track.release();
    }
}
