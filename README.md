# 🌌 Aether — CloudStream for iOS (IPA & Extension Engine)

> تطبيق وسائط وبث فائق الأناقة لأجهزة الآيفون والآيباد (iOS/iPadOS)، مستوحى من فلسفة **CloudStream** ومصمم بأعلى معايير **Apple Design (WWDC Fluid Interfaces)** بواسطة SwiftUI و JavaScriptCore المدمج.

---

## ✨ المميزات الرئيسية والابتكار التقني

### 1. حل معضلة "تحويل إضافات الكوتلين إلى JSON"
* إضافات CloudStream الأصلية مصممة بلغة Kotlin وملفات DEX الخاصة بنظام أندرويد فقط.
* في **Aether**، قمنا بإنشاء **محرك إضافات موحد (Extension Engine)** يعتمد على:
  * **Apple JavaScriptCore Framework:** يعمل داخل نظام iOS مباشرة بدون الحاجة لسيرفر خارجي وبسرعة معالجة عالية جداً.
  * **صيغة JSON موحدة:** تقوم الإضافات بفك تشفير الروابط وتجاوز الحمايات (AES Decryption / Packer JS / Cloudflare Headers) ثم إرجاع بيانات الأفلام والسيرفرات كـ JSON نقي يقرأه تطبيق الآيفون فوراً.
  * **مستودع إضافات مركزي (`repo.json`):** يمكن للمستخدم إضافة أي مستودع برابط واحد لتثبيت وتحديث الإضافات بنقرة واحدة.

### 2. واجهة مستخدم استثنائية (Apple Human Interface Guidelines)
* مصممة بناءً على مبادئ **Emil Kowalski's Apple Design**:
  * **الاستجابة اللحظية (Kill Latency):** تفاعل الأزرار بالضغط الفوري (`transform: scale(0.96)`) مع فيزياء النوابض (`Critically Damped Springs`).
  * **تأثيرات الزجاج السائل (Fluid Glassmorphism):** استخدام `.ultraThinMaterial` مع تدرجات لونية خلفية تتغير ديناميكياً بحسب بوستر الفيلم المعروض.
  * **مفتش السيرفرات (Stream Source Inspector):** عرض الروابط المفكوكة بدقة، مع تمييز جودة 4K HDR، ونوع الكوديك (HEVC/H264)، وسرعة استجابة السيرفر بالملي ثانية (Ping ms).
  * **مشغل فيديو مدمج احترافي:** مدعوم بـ AVPlayer، مع دعم HLS m3u8، والترجمات، وPicture-in-Picture (صورة داخل صورة).

---

## 🚀 كيفية بناء ملف الـ IPA عبر GitHub Actions (بدون جهاز Mac)

بما أنك لا تحتاج لامتلاك جهاز ماك، فإن سيرفرات GitHub المجهزة بنظام macOS ستقوم بتجميع التطبيق نيابةً عنك:

1. **أنشئ مستودعاً جديداً على حسابك في GitHub** (مثلاً باسم `Aether` أو `Ztv`).
2. **ارفع ملفات المشروع من جهازك:**
   ```bash
   git init
   git add .
   git commit -m "Initial commit of Aether iOS"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
   git push -u origin main
   ```
3. **التجميع التلقائي:**
   * بمجرد رفع الكود، توجه إلى تبويب **Actions** في صفحة المستودع.
   * ستجد سير عمل باسم **`Build iOS IPA`** قد بدأ العمل تلقائياً على خادم `macos-14`.
   * سيقوم الخادم بتثبيت `xcodegen`، وتوليد ملف المشروع، وتجميع التطبيق، وحزمه داخل ملف **`Aether-Unsigned.ipa`**.
4. **تحميل وتثبيت الـ IPA:**
   * بعد انتهاء الـ Action (يستغرق حوالي 2-3 دقائق)، ستجد ملف الـ `.ipa` جاهزاً للتحميل في قسم **Artifacts** أو **Releases**.
   * يمكنك تثبيته مباشرة على جهاز الآيفون الخاص بك باستخدام أي من الأدوات التالية:
     * **TrollStore** (إذا كان مدعوماً على إصدارك).
     * **AltStore** أو **SideStore** (بدون كمبيوتر عبر WiFi).
     * **Scarlet** أو **Sideloadly**.

---

## 📁 هيكلية المشروع

```
Ztv/
├── .github/
│   └── workflows/
│       └── build-ios.yml         # سير عمل تجميع الـ IPA على macOS
├── Aether/
│   ├── App/
│   │   └── AetherApp.swift       # نقطة الانطلاق الرئيسية للتطبيق
│   ├── Engine/
│   │   ├── JSRuntime.swift       # محرك تشغيل الإضافات وفك التشفير عبر JavaScriptCore
│   │   └── ExtensionManager.swift# إدارة مستودع الإضافات وتثبيتها
│   ├── Models/
│   │   └── MediaModels.swift     # نماذج البيانات (MediaItem, StreamSource, Manifest)
│   ├── Views/
│   │   ├── Common/               # عناصر الزجاج وفيزياء اللمس التفاعلية
│   │   ├── Details/              # صفحة تفاصيل الفيلم ومفتش السيرفرات
│   │   ├── Extensions/           # شاشة إدارة الإضافات ووحدة الاختبار الحي
│   │   ├── Home/                 # الواجهة الرئيسية مع البانر السينمائي
│   │   ├── Player/               # مشغل الفيديو الاحترافي
│   │   └── RootView.swift        # شريط التبويب السفلي الفاخر
│   └── Resources/
│       └── Info.plist            # إعدادات الصلاحيات والبث في الخلفية
├── extensions/                   # مستودع الإضافات النموذجي
│   ├── providers/                # سورس الإضافات المكتوبة بـ JavaScript
│   ├── tools/                    # سكربت Node.js لتوليد ملف repo.json
│   └── repo.json                 # فهرس الإضافات المتاح للأجهزة
└── project.yml                   # ملف إعدادات XcodeGen
```

---

## 🧪 تجربة المعاينة التفاعلية الفورية (Interactive Prototype)

تم إنشاء ملف معاينة تفاعلي حي كامل في مسار المحادثة:
* يحتوي على كامل حركات اللمس، والـ Dynamic Island، وشاشة تفاصيل الفيلم المنزلقة، ومفتش السيرفرات، ووحدة اختبار السكرابر وفك الروابط بلغة JSON لحظياً.
