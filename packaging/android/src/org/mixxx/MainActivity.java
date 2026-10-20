package org.mixxx;

import android.media.AudioManager;
import android.os.Bundle;
import android.view.WindowManager;
import java.lang.ref.WeakReference;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.view.WindowInsetsControllerCompat;
import org.qtproject.qt.android.QtActivityBase;

public class MainActivity extends QtActivityBase {
    private static WeakReference<MainActivity> current = new WeakReference<>(null);
    private static volatile boolean screenOn;

    public static void keepScreenOn(boolean enabled) {
        screenOn = enabled;
        MainActivity activity = current.get();
        if (activity != null) {
            activity.runOnUiThread(() -> {
                if (screenOn) { activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON); }
                else { activity.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON); }
            });
        }
    }

    @Override
    public void onResume() {
        super.onResume();
        setVolumeControlStream(AudioManager.STREAM_MUSIC);
        current = new WeakReference<>(this);
        keepScreenOn(screenOn);
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Disable drawing over cutout - isn't working
        WindowManager.LayoutParams lp = this.getWindow().getAttributes();
        lp.layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_NEVER;
        getWindow().setAttributes(lp);

        getWindow().setBackgroundDrawable(new android.graphics.drawable.ColorDrawable(android.graphics.Color.BLACK));

        // Non-intrusive default: navigation bars remain visible for normal system interaction.
        // TODO: Wire an optional immersive "DJ Mode" preference through QML / ControlObject
        // using WindowInsetsControllerCompat.hide(WindowInsetsCompat.Type.navigationBars())
        // and BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE.
        WindowInsetsControllerCompat windowInsetsController =
                WindowCompat.getInsetsController(getWindow(), getWindow().getDecorView());
        windowInsetsController.show(WindowInsetsCompat.Type.navigationBars());
    }
}
