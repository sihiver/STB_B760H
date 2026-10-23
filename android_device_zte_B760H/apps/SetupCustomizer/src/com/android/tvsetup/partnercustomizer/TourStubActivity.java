package com.google.android.tvsetup.partnercustomizer;

import android.app.Activity;
import android.os.Bundle;

public class TourStubActivity extends Activity {
    @Override protected void onCreate(Bundle b) {
        super.onCreate(b);
        setResult(RESULT_OK);
        finish();
    }
}