package com.ashishkudale.expense_tracker

import io.flutter.embedding.android.FlutterActivity
import android.os.Build
import android.os.Bundle
import androidx.core.view.WindowCompat

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Enable edge-to-edge display
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            WindowCompat.setDecorFitsSystemWindows(window, false)
        }
    }
}
