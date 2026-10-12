package org.mixxx;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;
import android.util.Log;

public final class StorageBridge {
    private static final String TAG = "MixxxStorage";
    private static final Handler MAIN = new Handler(Looper.getMainLooper());

    private StorageBridge() {
    }

    public static void requestAccess(Context context) {
        MAIN.post(() -> {
            if (hasAccess(context)) { return; }
            if (context instanceof Activity) {
                new AlertDialog.Builder(context)
                        .setTitle(R.string.mixxx_music_access)
                        .setMessage(R.string.mixxx_music_access_message)
                        .setPositiveButton(R.string.mixxx_open_settings, (dialog, which) -> openSettings(context))
                        .setNegativeButton(android.R.string.cancel, null)
                        .show();
            } else {
                openSettings(context);
            }
        });
    }

    public static boolean hasAccess(Context context) {
        return Build.VERSION.SDK_INT >= Build.VERSION_CODES.R
                ? Environment.isExternalStorageManager()
                : context.checkSelfPermission(Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED;
    }

    private static void openSettings(Context context) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                if (Environment.isExternalStorageManager()) {
                    return;
                }
                Intent intent = new Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION,
                        Uri.parse("package:" + context.getPackageName()));
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                try {
                    context.startActivity(intent);
                } catch (ActivityNotFoundException e) {
                    Intent fallback = new Intent(Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION);
                    fallback.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    try {
                        context.startActivity(fallback);
                    } catch (ActivityNotFoundException unavailable) {
                        Log.w(TAG, "Storage permission settings unavailable", unavailable);
                    }
                }
            } else if (context instanceof Activity
                    && (context.checkSelfPermission(Manifest.permission.READ_EXTERNAL_STORAGE)
                            != PackageManager.PERMISSION_GRANTED
                        || context.checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE)
                            != PackageManager.PERMISSION_GRANTED)) {
                ((Activity) context).requestPermissions(new String[]{
                        Manifest.permission.READ_EXTERNAL_STORAGE,
                        Manifest.permission.WRITE_EXTERNAL_STORAGE}, 1001);
            }
    }
}
