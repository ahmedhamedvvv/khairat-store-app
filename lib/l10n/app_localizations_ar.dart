// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class SAr extends S {
  SAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'خيرات';

  @override
  String get appTagline => 'خيرات الخليج لين باب بيتك';

  @override
  String get welcomeTitle => 'عطور وعبايات وتمور من أهل الديرة';

  @override
  String get welcomeBody =>
      'متجر تجريبي فيه تطبيقين: واجهة للعميل ولوحة تحكم للتاجر. اختر وش تبي تجرب.';

  @override
  String get shopAsCustomer => 'تسوّق كعميل';

  @override
  String get shopAsCustomerBody => 'تصفح، أضف للسلة، ادفع وتتبع طلبك';

  @override
  String get enterAsMerchant => 'ادخل كتاجر';

  @override
  String get enterAsMerchantBody => 'المبيعات والطلبات والمخزون والكوبونات';

  @override
  String get demoNote => 'نسخة تجريبية: كل البيانات والمدفوعات وهمية';

  @override
  String get loginTitle => 'سجّل دخولك';

  @override
  String get loginSubtitle => 'بنرسل لك رمز تحقق على جوالك';

  @override
  String get phoneLabel => 'رقم الجوال';

  @override
  String get phoneInvalid => 'أدخل رقم جوال من 9 أرقام يبدأ بـ 5';

  @override
  String get sendCode => 'أرسل الرمز';

  @override
  String get otpTitle => 'أدخل رمز التحقق';

  @override
  String otpHint(String phone) {
    return 'أرسلنا رمزًا من 4 أرقام إلى $phone. أي رمز يشتغل في النسخة التجريبية.';
  }

  @override
  String get verify => 'تحقق';

  @override
  String get continueAsGuest => 'تصفح كزائر';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navCategories => 'الأقسام';

  @override
  String get navCart => 'السلة';

  @override
  String get navOrders => 'طلباتي';

  @override
  String get navAccount => 'حسابي';

  @override
  String greeting(String name) {
    return 'هلا $name';
  }

  @override
  String get greetingGuest => 'هلا والله';

  @override
  String get deliverTo => 'التوصيل إلى';

  @override
  String get searchHint => 'ابحث عن عطر، عباية، تمر...';

  @override
  String get offerTitle => 'عروض موسم الشتاء';

  @override
  String get offerBody => 'خصم حتى 15% على العود والبخور والتمور المختارة';

  @override
  String get endsIn => 'ينتهي خلال';

  @override
  String get shopNow => 'تسوّق الآن';

  @override
  String get categories => 'الأقسام';

  @override
  String get bestSellers => 'الأكثر مبيعًا';

  @override
  String get newArrivals => 'وصل حديثًا';

  @override
  String get giftIdeas => 'أفكار هدايا';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String freeShippingOver(String amount) {
    return 'توصيل مجاني فوق $amount';
  }

  @override
  String productsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منتج',
      few: '$count منتجات',
      two: 'منتجين',
      one: 'منتج واحد',
    );
    return '$_temp0';
  }

  @override
  String get sortBy => 'ترتيب';

  @override
  String get sortPopular => 'الأكثر مبيعًا';

  @override
  String get sortPriceLow => 'السعر: من الأقل';

  @override
  String get sortPriceHigh => 'السعر: من الأعلى';

  @override
  String get sortRating => 'الأعلى تقييمًا';

  @override
  String get sortNewest => 'الأحدث';

  @override
  String get filter => 'فلترة';

  @override
  String get all => 'الكل';

  @override
  String get inStockOnly => 'المتوفر فقط';

  @override
  String get onSaleOnly => 'العروض فقط';

  @override
  String maxPrice(String amount) {
    return 'أعلى سعر: $amount';
  }

  @override
  String get apply => 'تطبيق';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get noResults => 'ما لقينا نتائج';

  @override
  String get noResultsBody => 'جرّب كلمة ثانية أو تصفح الأقسام';

  @override
  String get recentSearches => 'عمليات البحث الأخيرة';

  @override
  String get popularSearches => 'الأكثر بحثًا';

  @override
  String get clear => 'مسح';

  @override
  String get addToCart => 'أضف للسلة';

  @override
  String get addedToCart => 'أُضيف للسلة';

  @override
  String get viewCart => 'عرض السلة';

  @override
  String get outOfStock => 'نفدت الكمية';

  @override
  String onlyLeft(int count) {
    return 'باقي $count فقط';
  }

  @override
  String get inStock => 'متوفر';

  @override
  String get description => 'الوصف';

  @override
  String get reviews => 'التقييمات';

  @override
  String reviewsCount(int count) {
    return '$count تقييم';
  }

  @override
  String get similar => 'منتجات مشابهة';

  @override
  String get chooseOption => 'اختر';

  @override
  String get quantity => 'الكمية';

  @override
  String get vatIncluded => 'السعر شامل الضريبة';

  @override
  String soldCount(int count) {
    return '$count مبيع';
  }

  @override
  String get newBadge => 'جديد';

  @override
  String get favorites => 'المفضلة';

  @override
  String get favoritesEmpty => 'ما عندك منتجات في المفضلة';

  @override
  String get favoritesEmptyBody => 'اضغط على القلب في أي منتج عشان تحفظه هنا';

  @override
  String get cart => 'السلة';

  @override
  String get cartEmpty => 'سلتك فاضية';

  @override
  String get cartEmptyBody => 'ابدأ التسوق واكتشف خيرات الخليج';

  @override
  String get startShopping => 'ابدأ التسوق';

  @override
  String toFreeShipping(String amount) {
    return 'باقي $amount وتحصل على توصيل مجاني';
  }

  @override
  String get freeShippingUnlocked => 'مبروك! طلبك صار توصيله مجاني';

  @override
  String get couponHint => 'كود الخصم';

  @override
  String couponApplied(String code) {
    return 'تم تطبيق $code';
  }

  @override
  String get couponNotFound => 'الكود غير صحيح';

  @override
  String get couponInactive => 'الكود منتهي';

  @override
  String couponMin(String amount) {
    return 'الكود يحتاج طلب بقيمة $amount أو أكثر';
  }

  @override
  String get remove => 'إزالة';

  @override
  String get tryCodes => 'جرّب KHAIRAT10 أو WELCOME50';

  @override
  String get giftWrap => 'تغليف هدية';

  @override
  String giftWrapBody(String amount) {
    return 'صندوق فاخر مع بطاقة إهداء بـ $amount';
  }

  @override
  String get giftMessageHint => 'رسالة الإهداء (اختياري)';

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String get discount => 'الخصم';

  @override
  String get shipping => 'التوصيل';

  @override
  String get free => 'مجاني';

  @override
  String get giftWrapFee => 'التغليف';

  @override
  String get total => 'الإجمالي';

  @override
  String vatLine(String rate, String amount) {
    return 'يشمل ضريبة القيمة المضافة $rate%: $amount';
  }

  @override
  String get checkout => 'إتمام الطلب';

  @override
  String get stockLimit => 'الكمية المطلوبة أكثر من المتوفر';

  @override
  String get stepAddress => 'العنوان';

  @override
  String get stepDelivery => 'التوصيل';

  @override
  String get stepPayment => 'الدفع';

  @override
  String get deliveryAddress => 'عنوان التوصيل';

  @override
  String get edit => 'تعديل';

  @override
  String get fullName => 'الاسم';

  @override
  String get city => 'المدينة';

  @override
  String get district => 'الحي';

  @override
  String get street => 'الشارع ورقم المبنى';

  @override
  String get nationalAddress => 'العنوان الوطني المختصر';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get deliveryTime => 'موعد التوصيل';

  @override
  String get slotExpress => 'توصيل سريع';

  @override
  String get slotExpressBody => 'خلال 3 ساعات داخل المدينة';

  @override
  String get slotStandard => 'توصيل عادي';

  @override
  String get slotStandardBody => 'خلال 1-2 يوم عمل';

  @override
  String get slotScheduled => 'توصيل مجدول';

  @override
  String get slotScheduledBody => 'تختار اليوم اللي يناسبك';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get payMada => 'مدى / بطاقة';

  @override
  String get payMadaBody => 'مدى، فيزا، ماستركارد';

  @override
  String get payApple => 'Apple Pay';

  @override
  String get payAppleBody => 'ادفع بلمسة';

  @override
  String get paySTC => 'STC Pay';

  @override
  String get paySTCBody => 'ادفع من محفظتك';

  @override
  String get payTabby => 'تابي';

  @override
  String payTabbyBody(String amount) {
    return 'قسّمها على 4: $amount كل شهر بدون فوائد';
  }

  @override
  String get payCod => 'الدفع عند الاستلام';

  @override
  String get payCodBody => 'نقدًا أو بالشبكة عند وصول الطلب';

  @override
  String get cardNumber => 'رقم البطاقة';

  @override
  String get cardExpiry => 'تاريخ الانتهاء';

  @override
  String get cardCvv => 'CVV';

  @override
  String get cardHolder => 'الاسم على البطاقة';

  @override
  String get next => 'التالي';

  @override
  String payAmount(String amount) {
    return 'ادفع $amount';
  }

  @override
  String get placeOrderCod => 'أكّد الطلب';

  @override
  String get processing => 'جاري معالجة الدفع...';

  @override
  String get paymentMock => 'دفع تجريبي، ما راح ينخصم أي مبلغ';

  @override
  String get applePaySheetPay => 'ادفع لـ خيرات';

  @override
  String get applePayConfirm => 'اضغط للتأكيد';

  @override
  String get stcOtp => 'أدخل رمز STC Pay المرسل لجوالك';

  @override
  String get tabbyPlan => 'خطة الدفع';

  @override
  String get tabbyToday => 'اليوم';

  @override
  String tabbyInMonths(int count) {
    return 'بعد $count شهر';
  }

  @override
  String get orderPlaced => 'تم استلام طلبك!';

  @override
  String orderPlacedBody(String id) {
    return 'رقم الطلب $id. بنعطيك خبر مع كل خطوة.';
  }

  @override
  String get trackOrder => 'تتبع الطلب';

  @override
  String get viewInvoice => 'الفاتورة';

  @override
  String get continueShopping => 'متابعة التسوق';

  @override
  String get myOrders => 'طلباتي';

  @override
  String get ordersActive => 'الحالية';

  @override
  String get ordersPast => 'السابقة';

  @override
  String get ordersEmpty => 'ما عندك طلبات هنا';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منتج',
      few: '$count منتجات',
      two: 'منتجين',
      one: 'منتج واحد',
    );
    return '$_temp0';
  }

  @override
  String get statusPlaced => 'تم الطلب';

  @override
  String get statusConfirmed => 'تم التأكيد';

  @override
  String get statusPreparing => 'قيد التجهيز';

  @override
  String get statusShipped => 'مع المندوب';

  @override
  String get statusDelivered => 'تم التوصيل';

  @override
  String get statusCancelled => 'ملغي';

  @override
  String get statusPlacedBody => 'استلمنا طلبك';

  @override
  String get statusConfirmedBody => 'التاجر أكّد الطلب';

  @override
  String get statusPreparingBody => 'نجهّز ونغلّف طلبك';

  @override
  String get statusShippedBody => 'المندوب في الطريق لك';

  @override
  String get statusDeliveredBody => 'وصل طلبك، بالعافية';

  @override
  String get statusCancelledBody => 'تم إلغاء الطلب ورجعنا المبلغ';

  @override
  String orderNo(String id) {
    return 'طلب $id';
  }

  @override
  String get orderItems => 'المنتجات';

  @override
  String get courier => 'المندوب: سالم • 4.9★';

  @override
  String eta(String time) {
    return 'الوصول المتوقع: $time';
  }

  @override
  String get cancelOrder => 'إلغاء الطلب';

  @override
  String get cancelConfirm => 'متأكد تبي تلغي الطلب؟';

  @override
  String get cancelYes => 'نعم، ألغِ';

  @override
  String get keepOrder => 'تراجع';

  @override
  String get orderCancelled => 'تم إلغاء الطلب';

  @override
  String get reorder => 'اطلب مرة ثانية';

  @override
  String get reorderDone => 'أضفنا المنتجات للسلة';

  @override
  String get rateOrder => 'قيّم طلبك';

  @override
  String get rateTitle => 'كيف كانت تجربتك؟';

  @override
  String get rateThanks => 'شكرًا على تقييمك!';

  @override
  String get submit => 'إرسال';

  @override
  String get giftMessage => 'رسالة الإهداء';

  @override
  String get invoiceTitle => 'فاتورة ضريبية مبسطة';

  @override
  String get seller => 'البائع';

  @override
  String get sellerName => 'مؤسسة خيرات للتجارة';

  @override
  String get vatNumber => 'الرقم الضريبي';

  @override
  String get invoiceDate => 'التاريخ';

  @override
  String get paidWith => 'طريقة الدفع';

  @override
  String get invoiceQrNote => 'رمز QR بصيغة هيئة الزكاة (تجريبي)';

  @override
  String get demoAdvance => 'تجربة: انقل الطلب للخطوة الجاية';

  @override
  String get account => 'حسابي';

  @override
  String get guest => 'زائر';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get language => 'اللغة';

  @override
  String get languageValue => 'العربية';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get region => 'الدولة والعملة';

  @override
  String get regionSa => 'السعودية (ر.س، ضريبة 15%)';

  @override
  String get regionAe => 'الإمارات (د.إ، ضريبة 5%)';

  @override
  String get switchToMerchant => 'الانتقال للوحة التاجر';

  @override
  String get switchToCustomer => 'الانتقال لواجهة العميل';

  @override
  String get switchRole => 'تبديل الواجهة';

  @override
  String get resetDemo => 'إعادة بيانات الديمو';

  @override
  String get resetDone => 'رجعت البيانات للبداية';

  @override
  String get about => 'عن التطبيق';

  @override
  String get aboutBody =>
      'تطبيق تجريبي لمعرض الأعمال، مبني بـ Flutter لأندرويد وiOS والويب من كود واحد.';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get merchantHello => 'صباح الخير، متجر خيرات';

  @override
  String get todaySales => 'مبيعات اليوم';

  @override
  String get ordersToday => 'طلبات اليوم';

  @override
  String get avgOrder => 'متوسط الطلب';

  @override
  String get weekSales => 'مبيعات 7 أيام';

  @override
  String get salesChart => 'المبيعات آخر 7 أيام';

  @override
  String get topProducts => 'الأكثر مبيعًا';

  @override
  String lowStockAlert(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count منتج قارب يخلص',
      few: '$count منتجات قاربت تخلص',
      two: 'منتجين قاربوا يخلصون',
      one: 'منتج واحد قارب يخلص',
    );
    return '$_temp0';
  }

  @override
  String get needsAction => 'طلبات تنتظرك';

  @override
  String get orders => 'الطلبات';

  @override
  String get products => 'المنتجات';

  @override
  String get coupons => 'الكوبونات';

  @override
  String moveTo(String status) {
    return 'نقل إلى: $status';
  }

  @override
  String statusUpdated(String status) {
    return 'الحالة صارت: $status';
  }

  @override
  String get customer => 'العميل';

  @override
  String get stock => 'المخزون';

  @override
  String get price => 'السعر';

  @override
  String get visible => 'معروض في المتجر';

  @override
  String get hidden => 'مخفي';

  @override
  String get editProduct => 'تعديل المنتج';

  @override
  String get saved => 'تم الحفظ';

  @override
  String get newCoupon => 'كوبون جديد';

  @override
  String get couponCode => 'الكود';

  @override
  String get percentOff => 'نسبة %';

  @override
  String get fixedOff => 'مبلغ ثابت';

  @override
  String get couponValue => 'القيمة';

  @override
  String get minOrder => 'الحد الأدنى للطلب';

  @override
  String couponUses(int count) {
    return 'استُخدم $count مرة';
  }

  @override
  String get create => 'إنشاء';

  @override
  String get couponExists => 'الكود موجود من قبل';

  @override
  String get active => 'فعّال';

  @override
  String get inactive => 'موقوف';

  @override
  String get lowStock => 'قارب يخلص';

  @override
  String get sideTitle => 'خيرات: متجر المنتجات الخليجية';

  @override
  String get sideBody =>
      'تطبيق Flutter كامل يشتغل على أندرويد وiOS والويب. جرّبه بنفسك في الجوال جنبك.';

  @override
  String get sideF1 => 'دفع بمدى وApple Pay وSTC Pay وتابي';

  @override
  String get sideF2 => 'فاتورة بضريبة 15% ورمز QR';

  @override
  String get sideF3 => 'تتبع الطلب لحظة بلحظة';

  @override
  String get sideF4 => 'لوحة تاجر للطلبات والمخزون والكوبونات';

  @override
  String get sideF5 => 'عربي وإنجليزي، فاتح وداكن';

  @override
  String get bannerGiftBody => 'تغليف فاخر وبطاقة إهداء مع أي طلب';

  @override
  String get bannerDatesTitle => 'موسم التمور وصل';

  @override
  String get bannerDatesBody => 'سكري وعجوة وخلاص من المزارع مباشرة';

  @override
  String get allProducts => 'كل المنتجات';

  @override
  String vatAmount(String rate) {
    return 'ضريبة القيمة المضافة $rate%';
  }

  @override
  String get orderNumber => 'رقم الطلب';

  @override
  String get mockData => 'بيانات تجريبية';
}
