package com.measureme.measure_me

import io.flutter.embedding.android.FlutterFragmentActivity

// FlutterFragmentActivity (not FlutterActivity) is required by package:health
// for its permission-request flow (registerForActivityResult) on Android 14+.
class MainActivity : FlutterFragmentActivity()
