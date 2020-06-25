import { NativeModules, NativeEventEmitter } from 'react-native';

const RNSmartInterstitial = NativeModules.Smartad;
const SmartAdInterstitialEventEmitter = new NativeEventEmitter(RNSmartInterstitial);

const eventHandlers = {
  smartAdInterstitialAdNotReady: new Map(),
  smartAdInterstitialAdLoaded: new Map(),
  smartAdInterstitialAdFailedToLoad: new Map(),
  smartAdInterstitialAdShown: new Map(),
  smartAdInterstitialAdFailedToShow: new Map(),
  smartAdInterstitialAdClicked: new Map(),
  smartAdInterstitialAdDismissed: new Map(),
  smartAdInterstitialAdVideoEvent: new Map(),
}

const addEventListener = (type, handler) => {
  switch (type) {
    case 'smartAdInterstitialAdFailedToLoad':
    case 'smartAdInterstitialAdNotReady':
    case 'smartAdInterstitialAdLoaded':
    case 'smartAdInterstitialAdShown':
    case 'smartAdInterstitialAdFailedToShow':
    case 'smartAdInterstitialAdClicked':
    case 'smartAdInterstitialAdDismissed':
    case 'smartAdInterstitialAdVideoEvent':
      eventHandlers[type].set(handler, SmartAdInterstitialEventEmitter.addListener(type, handler));
      break;
    default:
      console.log(`Event with type ${type} does not exist.`);
  }
};

const removeEventListener = (type, handler) => {
  if (!eventHandlers[type].has(handler)) {
    return;
  }
  eventHandlers[type].get(handler).remove();
  eventHandlers[type].delete(handler);
};

const removeAllListeners = () => {
  SmartAdInterstitialEventEmitter.removeAllListeners('smartAdInterstitialAdNotReady');
  SmartAdInterstitialEventEmitter.removeAllListeners('smartAdInterstitialAdLoaded');
  SmartAdInterstitialEventEmitter.removeAllListeners('smartAdInterstitialAdFailedToLoad');
  SmartAdInterstitialEventEmitter.removeAllListeners('smartAdInterstitialAdShown');
  SmartAdInterstitialEventEmitter.removeAllListeners('smartAdInterstitialAdFailedToShow');
  SmartAdInterstitialEventEmitter.removeAllListeners('smartAdInterstitialAdClicked');
  SmartAdInterstitialEventEmitter.removeAllListeners('smartAdInterstitialAdDismissed');
  SmartAdInterstitialEventEmitter.removeAllListeners('smartAdInterstitialAdVideoEvent');
}

const loadAndShowInterstitial = () => {
  const showAndDelete = () => {
    RNSmartInterstitial.showInterstitialAd();
    removeEventListener('smartAdInterstitialAdLoaded', showAndDelete);
    removeEventListener('smartAdInterstitialAdFailedToLoad', errorDelete);
  }
  const errorDelete = () => {
    removeEventListener('smartAdInterstitialAdLoaded', showAndDelete);
    removeEventListener('smartAdInterstitialAdFailedToLoad', errorDelete);
  }

  addEventListener('smartAdInterstitialAdLoaded', showAndDelete);
  addEventListener('smartAdInterstitialAdFailedToLoad', errorDelete);
  RNSmartInterstitial.loadInterstitialAd();
}

module.exports = {
  ...RNSmartInterstitial,
  initializeRewardedVideo: (siteId, pageId, formatId, target) => RNSmartInterstitial.initializeInterstitial(siteId, pageId, formatId, target),
  showInterstitial: () => RNSmartInterstitial.showInterstitialAd(),
  loadInterstitial: () => RNSmartInterstitial.loadInterstitialAd(),
  loadAndShowInterstitial,
  addEventListener,
  removeEventListener,
  removeAllListeners
};