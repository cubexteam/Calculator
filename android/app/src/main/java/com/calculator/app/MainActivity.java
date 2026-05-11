package com.calculator.app;

import android.media.AudioManager;
import android.media.ToneGenerator;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

/**
 * Java-сторона: короткий звук нажатия (ToneGenerator), вызывается из Dart через MethodChannel.
 */
public class MainActivity extends FlutterActivity {
    public static final String NATIVE_CHANNEL = "com.calculator.app/native";
    private static final int TONE_DURATION_MS = 25;
    private static final int TONE_VOLUME = 35;

    private ToneGenerator toneGenerator;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), NATIVE_CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if ("playClick".equals(call.method)) {
                        playClickTone();
                        result.success(null);
                    } else {
                        result.notImplemented();
                    }
                });
    }

    private void playClickTone() {
        try {
            if (toneGenerator == null) {
                toneGenerator = new ToneGenerator(AudioManager.STREAM_NOTIFICATION, TONE_VOLUME);
            }
            toneGenerator.startTone(ToneGenerator.TONE_PROP_BEEP, TONE_DURATION_MS);
        } catch (RuntimeException ignored) {
        }
    }

    @Override
    protected void onDestroy() {
        if (toneGenerator != null) {
            toneGenerator.release();
            toneGenerator = null;
        }
        super.onDestroy();
    }
}
