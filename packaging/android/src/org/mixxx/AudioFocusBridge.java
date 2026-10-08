package org.mixxx;

import android.content.Context;
import android.media.AudioAttributes;
import android.media.AudioFocusRequest;
import android.media.AudioManager;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

/**
 * JNI bridge for Android audio focus.
 *
 * Native code requests audio focus while at least one deck plays and abandons
 * it when all decks stop. Focus changes are reported back through the native
 * method onAudioFocusChange on the Qt main thread.
 */
public final class AudioFocusBridge {
    private static final String TAG = "MixxxAudioFocus";
    private static final Handler sMainHandler = new Handler(Looper.getMainLooper());
    private static volatile AudioManager sAudioManager;
    private static AudioFocusRequest sRequest;

    private static final AudioManager.OnAudioFocusChangeListener sListener =
            focusChange -> onAudioFocusChange(focusChange);

    private AudioFocusBridge() {
    }

    public static void init(Context context) {
        sAudioManager = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
    }

    public static synchronized boolean request() {
        AudioManager audioManager = sAudioManager;
        if (audioManager == null) {
            Log.w(TAG, "AudioManager is not initialized");
            return false;
        }
        if (sRequest == null) {
            AudioAttributes attributes = new AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build();
            sRequest = new AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
                    .setAudioAttributes(attributes)
                    .setWillPauseWhenDucked(false)
                    .setOnAudioFocusChangeListener(sListener, sMainHandler)
                    .build();
        }
        int result = audioManager.requestAudioFocus(sRequest);
        Log.i(TAG, "requestAudioFocus result=" + result);
        return result == AudioManager.AUDIOFOCUS_REQUEST_GRANTED;
    }

    public static synchronized void abandon() {
        AudioManager audioManager = sAudioManager;
        if (audioManager != null && sRequest != null) {
            audioManager.abandonAudioFocusRequest(sRequest);
        }
    }

    private static native void onAudioFocusChange(int focusChange);
}
