package org.mixxx;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.hardware.usb.UsbDevice;
import android.hardware.usb.UsbManager;
import android.os.Build;
import android.util.Log;

public class UsbPermission {
    private static final String ACTION_USB_PERMISSION =
        "org.mixxx.permissions.USB_PERMISSION";
    private static final String TAG = "MixxxUsbPermission";
    private static native void usbDeviceAccessResult(Object device, boolean granted);
    private static native void usbDeviceChanged();

    public boolean registerServiceBroadcastReceiver(Context context) {
        try {
            IntentFilter intentFilter = new IntentFilter();
            intentFilter.addAction(ACTION_USB_PERMISSION);
            intentFilter.addAction(UsbManager.ACTION_USB_DEVICE_ATTACHED);
            intentFilter.addAction(UsbManager.ACTION_USB_DEVICE_DETACHED);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                context.registerReceiver(usbPermissionReceiver, intentFilter,
                        Context.RECEIVER_NOT_EXPORTED);
            } else {
                context.registerReceiver(usbPermissionReceiver, intentFilter);
            }
            Log.i(TAG, "Registered broadcast receiver for USB permission, attach, and detach");
            return true;
        } catch (Exception e) {
            Log.w(TAG, "Unable to register the broadcast receiver: " + e.toString());
            return false;
        }
    }

    private final BroadcastReceiver usbPermissionReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            Log.v(TAG, "Received " + action);
            if (ACTION_USB_PERMISSION.equals(action)) {
                synchronized (this) {
                    UsbDevice usbDevice = intent.getParcelableExtra(UsbManager.EXTRA_DEVICE);
                    if (usbDevice == null) {
                        Log.e(TAG, "USB device is null");
                        return;
                    }
                    boolean granted = intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false);
                    usbDeviceAccessResult(usbDevice, granted);
                    if (!granted) {
                        Log.w(TAG, "Permission was denied");
                    } else {
                        Log.i(TAG, "Permission was granted");
                    }
                }
            } else if (UsbManager.ACTION_USB_DEVICE_ATTACHED.equals(action) ||
                       UsbManager.ACTION_USB_DEVICE_DETACHED.equals(action)) {
                Log.i(TAG, "USB device state changed: " + action);
                try {
                    usbDeviceChanged();
                } catch (UnsatisfiedLinkError e) {
                    Log.w(TAG, "usbDeviceChanged native method not found", e);
                }
            }
        }
    };
}
