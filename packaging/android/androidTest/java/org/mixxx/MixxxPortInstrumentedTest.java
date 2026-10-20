package org.mixxx;

import android.Manifest;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Environment;
import androidx.test.core.app.ApplicationProvider;
import androidx.test.ext.junit.runners.AndroidJUnit4;
import org.junit.Test;
import org.junit.runner.RunWith;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

/**
 * Instrumented QA tests verifying key Android port components
 * without requiring real physical DJ controller hardware.
 */
@RunWith(AndroidJUnit4.class)
public class MixxxPortInstrumentedTest {

    @Test
    public void testApplicationContextAvailable() {
        Context context = ApplicationProvider.getApplicationContext();
        assertNotNull("Application context should be accessible", context);
    }

    @Test
    public void testStorageBridgeAccessCheckDoesNotCrash() {
        Context context = ApplicationProvider.getApplicationContext();
        boolean hasAccess = StorageBridge.hasAccess(context);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            assertEquals(Environment.isExternalStorageManager(), hasAccess);
        } else {
            int granted = context.checkSelfPermission(Manifest.permission.READ_EXTERNAL_STORAGE);
            assertEquals(granted == PackageManager.PERMISSION_GRANTED, hasAccess);
        }
    }

    @Test
    public void testUsbPermissionReceiverRegistration() {
        Context context = ApplicationProvider.getApplicationContext();
        UsbPermission usbPermission = new UsbPermission();
        boolean registered = usbPermission.registerServiceBroadcastReceiver(context);
        assertTrue("UsbPermission broadcast receiver should register cleanly", registered);
    }

    @Test
    public void testHardwareChangesFlagBitmask() {
        int audioFlag = HardwareChanges.AUDIO;
        int midiFlag = HardwareChanges.MIDI;
        int disconnectFlag = HardwareChanges.ROUTE_LOST;
        int failureFlag = HardwareChanges.OUTPUT_FAILED;

        int combined = audioFlag | midiFlag;
        assertTrue((combined & audioFlag) != 0);
        assertTrue((combined & midiFlag) != 0);
        assertFalse((combined & disconnectFlag) != 0);
        assertFalse((combined & failureFlag) != 0);
    }

    @Test
    public void testPlaybackServiceContract() {
        Context context = ApplicationProvider.getApplicationContext();
        // PlaybackService.setActive() returns true on success (for both activation and
        // deactivation) and false only if a RuntimeException occurs when interacting with Android services.
        boolean deact = PlaybackService.setActive(context, false);
        assertTrue("PlaybackService.setActive(false) should complete without exception", deact);
    }
}
