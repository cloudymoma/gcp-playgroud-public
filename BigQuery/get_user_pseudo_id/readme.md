# Get `user_pseudo_id` from Firebase client SDK

For `Firebase installation ID` (FID) or migrate from `Instance ID` to `FID`, please consult **[here](https://firebase.google.com/docs/projects/manage-installations)**.

## Mobile clients

Firebase Docs

- Android: [public Task<String> getAppInstanceId ()](https://firebase.google.com/docs/reference/android/com/google/firebase/analytics/FirebaseAnalytics.html#getAppInstanceId())
- iOS: [appInstanceID()](https://firebase.google.com/docs/reference/swift/firebaseanalytics/api/reference/Classes/Analytics#appinstanceid)

Example for Android

```java
FirebaseAnalytics.getInstance(this).getAppInstanceId().addOnCompleteListener(new OnCompleteListener<String>() {
    @Override
    public void onComplete(@NonNull Task<String> task) {
        if (task.isSuccessful()) {
            String user_pseudo_id = task.getResult();
        }
    }
});
```

## Web

JavaScript

```javascript
var gaUserId = document.cookie.match(/_ga=(.+?);/)[1].split('.').slice(-2).join(".")
```

PHP

```php
$gaUserId = preg_replace("/^.+\.(.+?\..+?)$/", "\\1", @$_COOKIE['_ga']);
```