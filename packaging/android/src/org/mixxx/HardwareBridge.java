package org.mixxx;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.hardware.usb.UsbConstants;
import android.hardware.usb.UsbDevice;
import android.media.AudioDeviceCallback;
import android.media.AudioDeviceInfo;
import android.media.AudioManager;
import android.media.midi.MidiDeviceInfo;
import android.media.midi.MidiManager;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import java.util.HashSet;
import java.util.Set;

public final class HardwareBridge {
    private static final Handler MAIN = new Handler(Looper.getMainLooper());
    private static Context context;
    private static AudioManager audio;
    private static MidiManager midi;
    private static final Set<Integer> usbOutputs = new HashSet<>();
    private static final AudioDeviceCallback AUDIO_CALLBACK = new AudioDeviceCallback() {
        @Override public void onAudioDevicesAdded(AudioDeviceInfo[] devices) { refreshAudio(); }
        @Override public void onAudioDevicesRemoved(AudioDeviceInfo[] devices) { refreshAudio(); }
    };
    private static final MidiManager.DeviceCallback MIDI_CALLBACK = new MidiManager.DeviceCallback() {
        @Override public void onDeviceAdded(MidiDeviceInfo device) {
            int flags = midiHardwareChangeFlags(device);
            Log.i("MixxxAudioRoutes", "USB MIDI device added: "
                    + device.getProperties().getString("name") + " flags=" + flags);
            onHardwareChanged(flags & HardwareChanges.MIDI);
            if ((flags & HardwareChanges.AUDIO) != 0) {
                retryUsbAudioEnumeration(0);
            }
        }
        @Override public void onDeviceRemoved(MidiDeviceInfo device) {
            MidiBridge.close(device.getId());
            int flags = midiHardwareChangeFlags(device);
            Log.i("MixxxAudioRoutes", "USB MIDI device removed: "
                    + device.getProperties().getString("name") + " flags=" + flags);
            onHardwareChanged(flags);
        }
    };
    private static final BroadcastReceiver NOISY = new BroadcastReceiver() {
        @Override public void onReceive(Context context, Intent intent) {
            onHardwareChanged(HardwareChanges.ROUTE_LOST);
        }
    };

    private HardwareBridge() { }

    private static int midiHardwareChangeFlags(MidiDeviceInfo device) {
        int flags = HardwareChanges.MIDI;
        if (device.getType() != MidiDeviceInfo.TYPE_USB) {
            return flags;
        }
        UsbDevice usbDevice = (UsbDevice) device.getProperties().getParcelable("usb_device");
        if (usbDevice == null) {
            return flags;
        }
        for (int index = 0; index < usbDevice.getInterfaceCount(); index++) {
            int interfaceClass = usbDevice.getInterface(index).getInterfaceClass();
            Log.i("MixxxAudioRoutes", "USB interface " + index + " class=" + interfaceClass);
            if (interfaceClass == UsbConstants.USB_CLASS_AUDIO) {
                return flags | HardwareChanges.AUDIO;
            }
        }
        return flags;
    }

    private static void retryUsbAudioEnumeration(int attempt) {
        if (audio == null) {
            return;
        }
        Set<Integer> current = outputs();
        int flags = HardwareChanges.audioOutputs(usbOutputs, current);
        usbOutputs.clear();
        usbOutputs.addAll(current);
        if (flags != 0) {
            Log.i("MixxxAudioRoutes", "USB audio outputs now available: " + current);
            onHardwareChanged(flags);
            return;
        }
        Log.i("MixxxAudioRoutes", "USB audio enumeration attempt " + (attempt + 1)
                + " found outputs=" + current);
        onHardwareChanged(HardwareChanges.AUDIO);
        if (attempt < 3) {
            MAIN.postDelayed(() -> retryUsbAudioEnumeration(attempt + 1), 500);
        }
    }

    private static boolean isUsb(AudioDeviceInfo device) {
        return device.getType() == AudioDeviceInfo.TYPE_USB_DEVICE
                || device.getType() == AudioDeviceInfo.TYPE_USB_HEADSET
                || device.getType() == AudioDeviceInfo.TYPE_USB_ACCESSORY;
    }

    private static Set<Integer> outputs() {
        Set<Integer> result = new HashSet<>();
        for (AudioDeviceInfo device : audio.getDevices(AudioManager.GET_DEVICES_OUTPUTS)) {
            if (isUsb(device)) { result.add(device.getId()); }
        }
        return result;
    }

    private static void refreshAudio() {
        Set<Integer> current = outputs();
        int flags = HardwareChanges.audioOutputs(usbOutputs, current);
        if (flags == 0) { return; }
        usbOutputs.clear();
        usbOutputs.addAll(current);
        onHardwareChanged(flags);
    }

    public static void init(Context app) {
        MAIN.post(() -> {
            if (context != null) { return; }
            context = app.getApplicationContext();
            audio = (AudioManager) context.getSystemService(Context.AUDIO_SERVICE);
            midi = (MidiManager) context.getSystemService(Context.MIDI_SERVICE);
            usbOutputs.addAll(outputs());
            audio.registerAudioDeviceCallback(AUDIO_CALLBACK, MAIN);
            if (midi != null) { midi.registerDeviceCallback(MIDI_CALLBACK, MAIN); }
            context.registerReceiver(NOISY, new IntentFilter(AudioManager.ACTION_AUDIO_BECOMING_NOISY),
                    Context.RECEIVER_NOT_EXPORTED);
        });
    }

    public static void shutdown() {
        MAIN.post(() -> {
            if (context == null) { return; }
            audio.unregisterAudioDeviceCallback(AUDIO_CALLBACK);
            if (midi != null) { midi.unregisterDeviceCallback(MIDI_CALLBACK); }
            context.unregisterReceiver(NOISY);
            usbOutputs.clear();
            context = null;
        });
    }

    public static void outputFailed() {
        onHardwareChanged(HardwareChanges.AUDIO | HardwareChanges.ROUTE_LOST | HardwareChanges.OUTPUT_FAILED);
    }
    private static native void onHardwareChanged(int flags);
}
