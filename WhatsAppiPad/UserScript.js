/**
 * Incomplete Notification API override to enable native notifications.
 */
class NotificationOverride {
    
    static get permission() {
        return "granted";
    }
    
    static requestPermission (callback) {
        callback("granted");
    }
    
    constructor (messageText, options) {
        window.webkit.messageHandlers.notify.postMessage(messageText + "|" + options.body);
    }
}

// Override the global browser notification object.
window.Notification = NotificationOverride;
