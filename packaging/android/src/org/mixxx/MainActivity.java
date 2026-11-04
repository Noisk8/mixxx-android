package org.mixxx;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.hardware.usb.UsbManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Process;
import android.view.WindowManager;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.view.WindowInsetsControllerCompat;
import org.qtproject.qt.android.QtActivityBase;

public class MainActivity extends QtActivityBase {
    private final BroadcastReceiver mUsbHotplugReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            UsbPermission.notifyDevicesChanged();
        }
    };

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            getWindow().setPreferMinimalPostProcessing(true);
        }

        // Disable drawing over cutout - isn't working
        WindowManager.LayoutParams lp = this.getWindow().getAttributes();
        lp.layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_NEVER;
        this.getWindow().setAttributes(lp);

        // Disable system and navigation bar to prevent accidental back or app switch
        WindowInsetsControllerCompat windowInsetsController =
            WindowCompat.getInsetsController(getWindow(), getWindow().getDecorView());
        windowInsetsController.setSystemBarsBehavior(
            WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE);
        windowInsetsController.hide(WindowInsetsCompat.Type.navigationBars());

        Process.setThreadPriority(Process.THREAD_PRIORITY_URGENT_DISPLAY);

        // USB_DEVICE_ATTACHED is only delivered to the activity through
        // onNewIntent, but USB_DEVICE_DETACHED needs a receiver. Both are
        // protected system broadcasts, which also reach receivers that other
        // apps can't send to.
        IntentFilter usbFilter = new IntentFilter();
        usbFilter.addAction(UsbManager.ACTION_USB_DEVICE_ATTACHED);
        usbFilter.addAction(UsbManager.ACTION_USB_DEVICE_DETACHED);
        registerReceiver(mUsbHotplugReceiver, usbFilter, Context.RECEIVER_NOT_EXPORTED);

        MidiHelper.init(this);
    }

    /// Saves the settings and the loaded tracks on the main thread of Mixxx,
    /// waits for it at most a few seconds
    private static native void saveBeforeExit();

    @Override
    public void onDestroy() {
        try {
            unregisterReceiver(mUsbHotplugReceiver);
        } catch (IllegalArgumentException e) {
            // Receiver was not registered
        }
        if (isFinishing()) {
            // Qt ends the process with System.exit() while the threads of
            // Mixxx and Android are still running, which crashes in them at
            // times (e.g. in Android's hwui threads). Save what Mixxx has to
            // keep and end the process at once instead.
            try {
                saveBeforeExit();
            } catch (UnsatisfiedLinkError e) {
                // The native library isn't loaded (yet)
            }
            Process.killProcess(Process.myPid());
        }
        super.onDestroy();
    }

    @Override
    protected void onNewIntent(android.content.Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        if (UsbManager.ACTION_USB_DEVICE_ATTACHED.equals(intent.getAction())) {
            UsbPermission.notifyDevicesChanged();
        }
    }
}
