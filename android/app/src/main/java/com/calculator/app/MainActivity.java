package com.calculator.app;

import android.app.PictureInPictureParams;
import android.media.AudioManager;
import android.media.ToneGenerator;
import android.os.Build;
import android.util.Rational;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

/**
 * Java-сторона:
 *  - playClick  — короткий звук нажатия (STREAM_MUSIC, громче чем NOTIFICATION)
 *  - enterPip   — свернуть в режим «картинка в картинке»
 */
public class MainActivity extends FlutterActivity {
    public static final String NATIVE_CHANNEL = "com.calculator.app/native";
    private static final int TONE_DURATION_MS = 25;
    // Увеличили громкость: было 35, стало 80
    private static final int TONE_VOLUME = 80;

    private ToneGenerator toneGenerator;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), NATIVE_CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    switch (call.method) {
                        case "playClick":
                            playClickTone();
                            result.success(null);
                            break;
                        case "enterPip":
                            enterPipMode();
                            result.success(null);
                            break;
                        default:
                            result.notImplemented();
                    }
                });
    }

    private void playClickTone() {
        try {
            if (toneGenerator == null) {
                // STREAM_MUSIC — громче и слышнее чем STREAM_NOTIFICATION
                toneGenerator = new ToneGenerator(AudioManager.STREAM_MUSIC, TONE_VOLUME);
            }
            toneGenerator.startTone(ToneGenerator.TONE_PROP_BEEP, TONE_DURATION_MS);
        } catch (RuntimeException ignored) {
        }
    }

    private void enterPipMode() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                PictureInPictureParams params = new PictureInPictureParams.Builder()
                        // Соотношение сторон калькулятора — примерно 9:16 в портрете
                        .setAspectRatio(new Rational(9, 16))
                        .build();
                enterPictureInPictureMode(params);
            } catch (RuntimeException ignored) {
                // Некоторые производители отключают PiP — игнорируем
            }
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
