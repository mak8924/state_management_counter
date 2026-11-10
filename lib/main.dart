import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'State Management Counters',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainMenuScreen(),
    );
  }
}

// ==================== الشاشة الرئيسية للتنقل ====================
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تكليف إدارة الحالة المتقدمة'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'اختر نوع إدارة الحالة للعداد:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            // زر الانتقال إلى شاشة GetX
            ElevatedButton.icon(
              onPressed: () => Get.to(() => const GetXCounterScreen()),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('عداد باستخدام GetX', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            // زر الانتقال إلى شاشة Riverpod
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RiverpodCounterScreen()),
              ),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('عداد باستخدام Riverpod', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ==================== 1. تطبيق GetX Counter ====================

class GetXCounterController extends GetxController {
  var counter = 0.obs; // متغير تفاعلي للعداد
  Timer? timer;
  var isRunning = false.obs;

  // بدء تشغيل المؤقت
  void startTimer() {
    if (isRunning.value) return;
    isRunning.value = true;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      counter.value++;
    });
  }

  // إيقاف المؤقت مؤقتاً
  void pauseTimer() {
    timer?.cancel();
    isRunning.value = false;
  }

  // تصفير العداد
  void resetTimer() {
    timer?.cancel();
    counter.value = 0;
    isRunning.value = false;
  }

  @override
  void onClose() {
    // تنظيف الموارد لمنع تسريب الذاكرة عند إغلاق الشاشة
    timer?.cancel();
    super.onClose();
  }
}

class GetXCounterScreen extends StatelessWidget {
  const GetXCounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // تهيئة المتحكم الخاص بـ GetX
    final controller = Get.put(GetXCounterController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('عداد الـ GetX المتقدم'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'قيمة العداد (GetX):',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // تحديث واجهة المستخدم تفاعلياً باستخدام Obx
            Obx(() => Text(
                  '${controller.counter.value}',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue),
                )),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: controller.startTimer,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('تشغيل'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: controller.pauseTimer,
                  icon: const Icon(Icons.pause),
                  label: const Text('إيقاف'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: controller.resetTimer,
                  icon: const Icon(Icons.refresh),
                  label: const Text('تصفير'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


// ==================== 2. تطبيق Riverpod Counter ====================

// تعريف الـ Notifier الخاص بإدارة حالة العداد وإدارة المؤقت
class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);
  Timer? _timer;

  // بدء تشغيل المؤقت
  void startTimer() {
    if (_timer != null && _timer!.isActive) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      state++; // تحديث الحالة في Riverpod
    });
  }

  // إيقاف المؤقت مؤقتاً
  void pauseTimer() {
    _timer?.cancel();
  }

  // تصفير العداد
  void resetTimer() {
    _timer?.cancel();
    state = 0;
  }

  @override
  void dispose() {
    // إيقاف المؤقت نهائياً لمنع تسريب الذاكرة
    _timer?.cancel();
    super.dispose();
  }
}

// تعريف الـ Provider الخاص بالـ Riverpod
final riverpodCounterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

class RiverpodCounterScreen extends ConsumerWidget {
  const RiverpodCounterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // قراءة قيمة العداد والحصول على كائن التحكم (Notifier)
    final counterValue = ref.watch(riverpodCounterProvider);
    final counterNotifier = ref.read(riverpodCounterProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('عداد الـ Riverpod المتقدم'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'قيمة العداد (Riverpod):',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              '$counterValue',
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => counterNotifier.startTimer(),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('تشغيل'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => counterNotifier.pauseTimer(),
                  icon: const Icon(Icons.pause),
                  label: const Text('إيقاف'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => counterNotifier.resetTimer(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('تصفير'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}