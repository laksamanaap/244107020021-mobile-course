/// Wi-Fi ini memblok HP → laptop (ping 192.168.1.104 unreachable).
/// Saat `flutter run` lewat USB, tembak localhost HP yang di-forward
/// `adb reverse tcp:8000 tcp:8000` ke Laravel di laptop.
///
/// Laravel: `php artisan serve --host=0.0.0.0 --port=8000`
const campusApiBaseUrl = 'http://127.0.0.1:8000';
