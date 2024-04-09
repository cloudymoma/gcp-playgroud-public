# Get `user_pseudo_id` from Firebase client SDK

For `Firebase installation ID` (FID) or migrate from `Instance ID` to `FID`, please consult **[here](https://firebase.google.com/docs/projects/manage-installations)**.

## Retrive client ID (a.k.a. user_pseudo_id or instance id)

### Swift

```swift
do {
  let id = try await Installations.installations().installationID()
  print("Installation ID: \(id)")
} catch {
  print("Error fetching id: \(error)")
}
```

### Objective-C

```
[[FIRInstallations installations] installationIDWithCompletion:^(NSString *identifier, NSError *error) {
  if (error != nil) {
    NSLog(@"Error fetching Installation ID %@", error);
    return;
  }
  NSLog(@"Installation ID: %@", identifier);
}];
```

### Java Android

```java
FirebaseInstallations.getInstance().getId()
        .addOnCompleteListener(new OnCompleteListener<String>() {
    @Override
    public void onComplete(@NonNull Task<String> task) {
        if (task.isSuccessful()) {
            Log.d("Installations", "Installation ID: " + task.getResult());
        } else {
            Log.e("Installations", "Unable to get Installation ID");
        }
    }
});
```

### Kotlin+KTX Android

```kotlin
FirebaseInstallations.getInstance().id.addOnCompleteListener { task ->
    if (task.isSuccessful) {
        Log.d("Installations", "Installation ID: " + task.result)
    } else {
        Log.e("Installations", "Unable to get Installation ID")
    }
}
```

### JavaScript

```javascript
const installationId = await firebase.installations().getId();
console.log(installationId);
```

### Dart Flutter

```dart
String id = await FirebaseInstallations.instance.getId();
```

---

## Deprecated methods

### Mobile clients

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

### Web

JavaScript

```javascript
var gaUserId = document.cookie.match(/_ga=(.+?);/)[1].split('.').slice(-2).join(".")
```

PHP

```php
$gaUserId = preg_replace("/^.+\.(.+?\..+?)$/", "\\1", @$_COOKIE['_ga']);
```