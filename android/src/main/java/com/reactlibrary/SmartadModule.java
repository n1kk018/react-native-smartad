package com.reactlibrary;

import java.util.HashMap;
import java.util.Map;

import android.util.Log;
import android.os.Bundle;
import android.os.Looper;
import android.os.Handler;
import android.view.ViewGroup;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.smartadserver.android.library.model.SASAdElement;
import com.smartadserver.android.library.model.SASAdPlacement;
import com.smartadserver.android.library.model.SASAdStatus;
import com.smartadserver.android.library.ui.SASInterstitialManager;
import com.smartadserver.android.library.util.SASConfiguration;

import com.facebook.react.ReactActivity;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.modules.core.DeviceEventManagerModule;

public class SmartadModule extends ReactContextBaseJavaModule {

    private final ReactApplicationContext reactContext;

    /****************************
     * Ad Constants
     ****************************/

     private final static String TAG               = "SmartadModule";

    /****************************
     * Ad Variables
     ****************************/

     SASAdPlacement mInterstitialPlacement;
     SASInterstitialManager mInterstitialManager;
     SASInterstitialManager.InterstitialListener mInterstitialListener;
 
    /****************************
     * Members declarations
     ****************************/
    

    public SmartadModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "Smartad";
    }

    @ReactMethod
    public void initializeInterstitial(final @NonNull int SITE_ID, final @NonNull String PAGE_ID, final @NonNull int FORMAT_ID, final @Nullable String TARGET) {
        // Enables output to log.
        SASConfiguration.getSharedInstance().setLoggingEnabled(true);

        // Initializes the SmartAdServer on main thread
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                SASConfiguration.getSharedInstance().configure(reactContext, SITE_ID, "https://mobile.smartadserver.com");
                mInterstitialPlacement = new SASAdPlacement(SITE_ID, PAGE_ID, FORMAT_ID, TARGET);
                mInterstitialManager = new SASInterstitialManager(reactContext, mInterstitialPlacement);
                initInterstitialListener();
                mInterstitialManager.setInterstitialListener(mInterstitialListener);
            }
        });
    }

    @ReactMethod
    public void loadInterstitialAd() {
        if (mInterstitialManager != null) {
            mInterstitialManager.loadAd();
        } else {
            sendEvent("smartInterstitialFailedToLoad", null);
        }
    }

    @ReactMethod
    public void showInterstitialAd() {
        if (mInterstitialManager != null && mInterstitialManager.getAdStatus() == SASAdStatus.READY) {
            mInterstitialManager.show();
        } else {
            Log.e(SmartadModule.TAG, "Interstitial is not ready for the current placement.");
            sendEvent("smartInterstitialNotReady", null);
        }
    }

    private void initInterstitialListener() {
        this.mInterstitialListener = new SASInterstitialManager.InterstitialListener() {
            @Override
            public void onInterstitialAdLoaded(SASInterstitialManager interstitialManager, SASAdElement adElement) {
                Log.i(SmartadModule.TAG, "Interstitial Ad loading completed.");            
                sendEvent("smartAdInterstitialAdLoaded", null);
            }

            @Override
            public void onInterstitialAdFailedToLoad(SASInterstitialManager interstitialManager, Exception exception) {
                Log.i(SmartadModule.TAG, "Interstitial Ad loading failed with exception: " + exception.getLocalizedMessage());
                WritableMap params = Arguments.createMap();
                params.putString("message", exception.getLocalizedMessage());
                sendEvent("smartAdInterstitialAdFailedToLoad", params);
            }

            @Override
            public void onInterstitialAdShown(SASInterstitialManager interstitialManager) {
                Log.i(SmartadModule.TAG, "Interstitial Ad is shown.");
                sendEvent("smartAdInterstitialAdShown", null);
            }

            @Override
            public void onInterstitialAdFailedToShow(SASInterstitialManager interstitialManager, Exception exception) {
                Log.i(SmartadModule.TAG, "Interstitial failed to show with exception: " + exception.getLocalizedMessage());
                sendEvent("smartAdInterstitialAdFailedToShow", null);
            }

            @Override
            public void onInterstitialAdClicked(SASInterstitialManager interstitialManager) {
                Log.i(SmartadModule.TAG, "Interstitial clicked.");
                sendEvent("smartAdInterstitialAdClicked", null);
            }

            @Override
            public void onInterstitialAdDismissed(SASInterstitialManager interstitialManager) {
                Log.i(SmartadModule.TAG, "Interstitial dismissed.");
                sendEvent("smartAdInterstitialAdDismissed", null);
            }

            @Override
            public void onInterstitialAdVideoEvent(SASInterstitialManager interstitialManager, int videoEvent) {
                Log.i(SmartadModule.TAG, "Video event " + videoEvent + " was triggered on Interstitial");
                sendEvent("smartAdInterstitialAdVideoEvent", null);
            }
        };
    }

    @ReactMethod
    protected void reset() {
        mInterstitialManager.reset();
    }

    @ReactMethod
    protected void onDestroy() {
       mInterstitialManager.onDestroy();
    }

    private void sendEvent(String eventName, @Nullable WritableMap params) {
        getReactApplicationContext().getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class).emit(eventName, params);
    }
}