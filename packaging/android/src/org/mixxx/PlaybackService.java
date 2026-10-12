package org.mixxx;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ServiceInfo;
import android.media.session.MediaSession;
import android.media.session.PlaybackState;
import android.os.IBinder;
import android.os.PowerManager;
import android.os.Debug;
import android.os.BatteryManager;
import android.os.Handler;
import android.os.Looper;
import android.content.IntentFilter;
import android.util.Log;
import java.util.concurrent.atomic.AtomicInteger;

public final class PlaybackService extends Service {
    private static final String CHANNEL = "mixxx_playback";
    private static final String PAUSE = "org.mixxx.PAUSE_SESSION";
    private static volatile boolean desired;
    private static final AtomicInteger generation = new AtomicInteger();
    private int serviceGeneration;
    private SessionDiagnostics diagnostics;
    private PowerManager.WakeLock wakeLock;
    private MediaSession session;

    public static boolean setActive(Context context, boolean active) {
        desired = active;
        generation.incrementAndGet();
        try {
            Intent intent = new Intent(context, PlaybackService.class);
            if (active) { context.startForegroundService(intent); }
            else { context.stopService(intent); }
            return true;
        } catch (RuntimeException e) {
            desired = false;
            Log.e("MixxxPlayback", "Playback service unavailable", e);
            return false;
        }
    }

    @Override public void onCreate() {
        super.onCreate();
        NotificationManager notifications = getSystemService(NotificationManager.class);
        NotificationChannel channel = new NotificationChannel(CHANNEL,
                getString(R.string.mixxx_session), NotificationManager.IMPORTANCE_LOW);
        channel.setSound(null, null);
        notifications.createNotificationChannel(channel);
        session = new MediaSession(this, "Mixxx");
        session.setCallback(new MediaSession.Callback() {
            @Override public void onPause() { pauseSession(); }
            @Override public void onStop() { pauseSession(); }
        });
        session.setPlaybackState(new PlaybackState.Builder()
                .setActions(PlaybackState.ACTION_PAUSE | PlaybackState.ACTION_STOP)
                .setState(PlaybackState.STATE_PLAYING, PlaybackState.PLAYBACK_POSITION_UNKNOWN, 1f)
                .build());
        session.setActive(true);
        PowerManager power = getSystemService(PowerManager.class);
        wakeLock = power.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "Mixxx:Playback");
        wakeLock.setReferenceCounted(false);
        diagnostics = SessionDiagnostics.start(this);
        AudioTrackBridge.logAll();
    }

    @Override public int onStartCommand(Intent intent, int flags, int startId) {
        serviceGeneration = generation.get();
        PendingIntent open = PendingIntent.getActivity(this, 0,
                new Intent(this, MainActivity.class), PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT);
        PendingIntent pause = PendingIntent.getService(this, 1,
                new Intent(this, PlaybackService.class).setAction(PAUSE), PendingIntent.FLAG_IMMUTABLE);
        Notification notification = new Notification.Builder(this, CHANNEL)
                .setSmallIcon(android.R.drawable.ic_media_play)
                .setContentTitle(getString(R.string.mixxx_session))
                .setContentText(getString(R.string.mixxx_session_running))
                .setContentIntent(open)
                .setOngoing(true)
                .setCategory(Notification.CATEGORY_TRANSPORT)
                .setStyle(new Notification.MediaStyle().setMediaSession(session.getSessionToken())
                        .setShowActionsInCompactView(0))
                .addAction(new Notification.Action.Builder(android.R.drawable.ic_media_pause,
                        getString(R.string.mixxx_pause_session), pause).build())
                .build();
        startForeground(400, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK);
        if (!desired || (intent != null && PAUSE.equals(intent.getAction()))) {
            pauseSession();
            return START_NOT_STICKY;
        }
        wakeLock.acquire();
        return START_NOT_STICKY;
    }

    private void pauseSession() {
        desired = false;
        onPauseSession();
        stopSelf();
    }

    @Override public void onTaskRemoved(Intent intent) { pauseSession(); }
    @Override public void onDestroy() {
        if (diagnostics != null) { diagnostics.stop(); }
        if (wakeLock != null && wakeLock.isHeld()) { wakeLock.release(); }
        if (session != null) { session.release(); }
        if (desired && serviceGeneration == generation.get()) { desired = false; onPauseSession(); }
        super.onDestroy();
    }
    @Override public IBinder onBind(Intent intent) { return null; }
    private static native void onPauseSession();
}
