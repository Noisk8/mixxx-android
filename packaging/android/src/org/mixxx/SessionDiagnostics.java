package org.mixxx;

import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Debug;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.PowerManager;
import android.os.SystemClock;
import android.util.Log;
import java.io.File;
import java.io.FileOutputStream;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.Comparator;
import org.json.JSONObject;

public final class SessionDiagnostics {
    private static volatile SessionDiagnostics active;
    private final HandlerThread thread = new HandlerThread("MixxxSessionDiagnostics");
    private final Handler handler;
    private final Context context;
    private final long startMs = SystemClock.elapsedRealtime();
    private FileOutputStream output;
    private long bytes;
    private boolean stopped;
    private final Runnable snapshot = new Runnable() {
        @Override public void run() {
            if (stopped) { return; }
            try {
                PowerManager power = context.getSystemService(PowerManager.class);
                Intent battery = context.registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
                JSONObject sample = new JSONObject();
                sample.put("type", "system");
                sample.put("nativeHeapBytes", Debug.getNativeHeapAllocatedSize());
                sample.put("pssKiB", Debug.getPss());
                sample.put("thermalStatus", power.getCurrentThermalStatus());
                sample.put("batteryTemperatureTenthsC", battery == null ? -1
                        : battery.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, -1));
                sample.put("screenOn", power.isInteractive());
                append(sample);
            } catch (Exception e) {
                Log.w("MixxxSession", "Cannot sample session", e);
            }
            handler.postDelayed(this, 30000);
        }
    };

    private SessionDiagnostics(Context context) {
        this.context = context.getApplicationContext();
        thread.start();
        handler = new Handler(thread.getLooper());
        handler.post(() -> {
            try {
                File directory = context.getExternalFilesDir("diagnostics");
                if (directory == null) { directory = new File(context.getFilesDir(), "diagnostics"); }
                if (!directory.isDirectory() && !directory.mkdirs()) { throw new IllegalStateException("Diagnostics directory unavailable"); }
                File[] previous = directory.listFiles((dir, name) -> name.startsWith("session-") && name.endsWith(".jsonl"));
                if (previous != null) {
                    Arrays.sort(previous, Comparator.comparingLong(File::lastModified));
                    for (int i = 0; i < previous.length - 4; ++i) { previous[i].delete(); }
                }
                File file = new File(directory, "session-" + System.currentTimeMillis() + ".jsonl");
                output = new FileOutputStream(file);
                Log.i("MixxxSession", "Recording session measurements: " + file);
                snapshot.run();
            } catch (Exception e) {
                Log.w("MixxxSession", "Cannot record session", e);
            }
        });
    }

    public static SessionDiagnostics start(Context context) {
        SessionDiagnostics instance = new SessionDiagnostics(context);
        active = instance;
        return instance;
    }

    public static void record(String json) {
        SessionDiagnostics instance = active;
        if (instance == null) { return; }
        instance.handler.post(() -> {
            try { instance.append(new JSONObject(json)); }
            catch (Exception e) { Log.w("MixxxSession", "Invalid session sample", e); }
        });
    }

    private void append(JSONObject sample) throws Exception {
        if (stopped || output == null || bytes >= 5 * 1024 * 1024) { return; }
        sample.put("timestampMs", System.currentTimeMillis());
        sample.put("elapsedMs", SystemClock.elapsedRealtime() - startMs);
        byte[] data = (sample.toString() + "\n").getBytes(StandardCharsets.UTF_8);
        output.write(data);
        bytes += data.length;
        Log.i("MixxxSession", sample.toString());
    }

    public void stop() {
        if (active == this) { active = null; }
        handler.post(() -> {
            stopped = true;
            handler.removeCallbacks(snapshot);
            try { if (output != null) { output.close(); } }
            catch (Exception e) { Log.w("MixxxSession", "Cannot close session record", e); }
            thread.quitSafely();
        });
    }
}
