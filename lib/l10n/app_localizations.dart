import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'خيرات'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In ar, this message translates to:
  /// **'خيرات الخليج لين باب بيتك'**
  String get appTagline;

  /// No description provided for @welcomeTitle.
  ///
  /// In ar, this message translates to:
  /// **'عطور وعبايات وتمور من أهل الديرة'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In ar, this message translates to:
  /// **'متجر تجريبي فيه تطبيقين: واجهة للعميل ولوحة تحكم للتاجر. اختر وش تبي تجرب.'**
  String get welcomeBody;

  /// No description provided for @shopAsCustomer.
  ///
  /// In ar, this message translates to:
  /// **'تسوّق كعميل'**
  String get shopAsCustomer;

  /// No description provided for @shopAsCustomerBody.
  ///
  /// In ar, this message translates to:
  /// **'تصفح، أضف للسلة، ادفع وتتبع طلبك'**
  String get shopAsCustomerBody;

  /// No description provided for @enterAsMerchant.
  ///
  /// In ar, this message translates to:
  /// **'ادخل كتاجر'**
  String get enterAsMerchant;

  /// No description provided for @enterAsMerchantBody.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات والطلبات والمخزون والكوبونات'**
  String get enterAsMerchantBody;

  /// No description provided for @demoNote.
  ///
  /// In ar, this message translates to:
  /// **'نسخة تجريبية: كل البيانات والمدفوعات وهمية'**
  String get demoNote;

  /// No description provided for @loginTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'بنرسل لك رمز تحقق على جوالك'**
  String get loginSubtitle;

  /// No description provided for @phoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الجوال'**
  String get phoneLabel;

  /// No description provided for @phoneInvalid.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم جوال من 9 أرقام يبدأ بـ 5'**
  String get phoneInvalid;

  /// No description provided for @sendCode.
  ///
  /// In ar, this message translates to:
  /// **'أرسل الرمز'**
  String get sendCode;

  /// No description provided for @otpTitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز التحقق'**
  String get otpTitle;

  /// No description provided for @otpHint.
  ///
  /// In ar, this message translates to:
  /// **'أرسلنا رمزًا من 4 أرقام إلى {phone}. أي رمز يشتغل في النسخة التجريبية.'**
  String otpHint(String phone);

  /// No description provided for @verify.
  ///
  /// In ar, this message translates to:
  /// **'تحقق'**
  String get verify;

  /// No description provided for @continueAsGuest.
  ///
  /// In ar, this message translates to:
  /// **'تصفح كزائر'**
  String get continueAsGuest;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navCategories.
  ///
  /// In ar, this message translates to:
  /// **'الأقسام'**
  String get navCategories;

  /// No description provided for @navCart.
  ///
  /// In ar, this message translates to:
  /// **'السلة'**
  String get navCart;

  /// No description provided for @navOrders.
  ///
  /// In ar, this message translates to:
  /// **'طلباتي'**
  String get navOrders;

  /// No description provided for @navAccount.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get navAccount;

  /// No description provided for @greeting.
  ///
  /// In ar, this message translates to:
  /// **'هلا {name}'**
  String greeting(String name);

  /// No description provided for @greetingGuest.
  ///
  /// In ar, this message translates to:
  /// **'هلا والله'**
  String get greetingGuest;

  /// No description provided for @deliverTo.
  ///
  /// In ar, this message translates to:
  /// **'التوصيل إلى'**
  String get deliverTo;

  /// No description provided for @searchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن عطر، عباية، تمر...'**
  String get searchHint;

  /// No description provided for @offerTitle.
  ///
  /// In ar, this message translates to:
  /// **'عروض موسم الشتاء'**
  String get offerTitle;

  /// No description provided for @offerBody.
  ///
  /// In ar, this message translates to:
  /// **'خصم حتى 15% على العود والبخور والتمور المختارة'**
  String get offerBody;

  /// No description provided for @endsIn.
  ///
  /// In ar, this message translates to:
  /// **'ينتهي خلال'**
  String get endsIn;

  /// No description provided for @shopNow.
  ///
  /// In ar, this message translates to:
  /// **'تسوّق الآن'**
  String get shopNow;

  /// No description provided for @categories.
  ///
  /// In ar, this message translates to:
  /// **'الأقسام'**
  String get categories;

  /// No description provided for @bestSellers.
  ///
  /// In ar, this message translates to:
  /// **'الأكثر مبيعًا'**
  String get bestSellers;

  /// No description provided for @newArrivals.
  ///
  /// In ar, this message translates to:
  /// **'وصل حديثًا'**
  String get newArrivals;

  /// No description provided for @giftIdeas.
  ///
  /// In ar, this message translates to:
  /// **'أفكار هدايا'**
  String get giftIdeas;

  /// No description provided for @seeAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get seeAll;

  /// No description provided for @freeShippingOver.
  ///
  /// In ar, this message translates to:
  /// **'توصيل مجاني فوق {amount}'**
  String freeShippingOver(String amount);

  /// No description provided for @productsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{منتج واحد} =2{منتجين} few{{count} منتجات} other{{count} منتج}}'**
  String productsCount(int count);

  /// No description provided for @sortBy.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب'**
  String get sortBy;

  /// No description provided for @sortPopular.
  ///
  /// In ar, this message translates to:
  /// **'الأكثر مبيعًا'**
  String get sortPopular;

  /// No description provided for @sortPriceLow.
  ///
  /// In ar, this message translates to:
  /// **'السعر: من الأقل'**
  String get sortPriceLow;

  /// No description provided for @sortPriceHigh.
  ///
  /// In ar, this message translates to:
  /// **'السعر: من الأعلى'**
  String get sortPriceHigh;

  /// No description provided for @sortRating.
  ///
  /// In ar, this message translates to:
  /// **'الأعلى تقييمًا'**
  String get sortRating;

  /// No description provided for @sortNewest.
  ///
  /// In ar, this message translates to:
  /// **'الأحدث'**
  String get sortNewest;

  /// No description provided for @filter.
  ///
  /// In ar, this message translates to:
  /// **'فلترة'**
  String get filter;

  /// No description provided for @all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get all;

  /// No description provided for @inStockOnly.
  ///
  /// In ar, this message translates to:
  /// **'المتوفر فقط'**
  String get inStockOnly;

  /// No description provided for @onSaleOnly.
  ///
  /// In ar, this message translates to:
  /// **'العروض فقط'**
  String get onSaleOnly;

  /// No description provided for @maxPrice.
  ///
  /// In ar, this message translates to:
  /// **'أعلى سعر: {amount}'**
  String maxPrice(String amount);

  /// No description provided for @apply.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين'**
  String get reset;

  /// No description provided for @noResults.
  ///
  /// In ar, this message translates to:
  /// **'ما لقينا نتائج'**
  String get noResults;

  /// No description provided for @noResultsBody.
  ///
  /// In ar, this message translates to:
  /// **'جرّب كلمة ثانية أو تصفح الأقسام'**
  String get noResultsBody;

  /// No description provided for @recentSearches.
  ///
  /// In ar, this message translates to:
  /// **'عمليات البحث الأخيرة'**
  String get recentSearches;

  /// No description provided for @popularSearches.
  ///
  /// In ar, this message translates to:
  /// **'الأكثر بحثًا'**
  String get popularSearches;

  /// No description provided for @clear.
  ///
  /// In ar, this message translates to:
  /// **'مسح'**
  String get clear;

  /// No description provided for @addToCart.
  ///
  /// In ar, this message translates to:
  /// **'أضف للسلة'**
  String get addToCart;

  /// No description provided for @addedToCart.
  ///
  /// In ar, this message translates to:
  /// **'أُضيف للسلة'**
  String get addedToCart;

  /// No description provided for @viewCart.
  ///
  /// In ar, this message translates to:
  /// **'عرض السلة'**
  String get viewCart;

  /// No description provided for @outOfStock.
  ///
  /// In ar, this message translates to:
  /// **'نفدت الكمية'**
  String get outOfStock;

  /// No description provided for @onlyLeft.
  ///
  /// In ar, this message translates to:
  /// **'باقي {count} فقط'**
  String onlyLeft(int count);

  /// No description provided for @inStock.
  ///
  /// In ar, this message translates to:
  /// **'متوفر'**
  String get inStock;

  /// No description provided for @description.
  ///
  /// In ar, this message translates to:
  /// **'الوصف'**
  String get description;

  /// No description provided for @reviews.
  ///
  /// In ar, this message translates to:
  /// **'التقييمات'**
  String get reviews;

  /// No description provided for @reviewsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} تقييم'**
  String reviewsCount(int count);

  /// No description provided for @similar.
  ///
  /// In ar, this message translates to:
  /// **'منتجات مشابهة'**
  String get similar;

  /// No description provided for @chooseOption.
  ///
  /// In ar, this message translates to:
  /// **'اختر'**
  String get chooseOption;

  /// No description provided for @quantity.
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get quantity;

  /// No description provided for @vatIncluded.
  ///
  /// In ar, this message translates to:
  /// **'السعر شامل الضريبة'**
  String get vatIncluded;

  /// No description provided for @soldCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} مبيع'**
  String soldCount(int count);

  /// No description provided for @newBadge.
  ///
  /// In ar, this message translates to:
  /// **'جديد'**
  String get newBadge;

  /// No description provided for @favorites.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get favorites;

  /// No description provided for @favoritesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'ما عندك منتجات في المفضلة'**
  String get favoritesEmpty;

  /// No description provided for @favoritesEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على القلب في أي منتج عشان تحفظه هنا'**
  String get favoritesEmptyBody;

  /// No description provided for @cart.
  ///
  /// In ar, this message translates to:
  /// **'السلة'**
  String get cart;

  /// No description provided for @cartEmpty.
  ///
  /// In ar, this message translates to:
  /// **'سلتك فاضية'**
  String get cartEmpty;

  /// No description provided for @cartEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ التسوق واكتشف خيرات الخليج'**
  String get cartEmptyBody;

  /// No description provided for @startShopping.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ التسوق'**
  String get startShopping;

  /// No description provided for @toFreeShipping.
  ///
  /// In ar, this message translates to:
  /// **'باقي {amount} وتحصل على توصيل مجاني'**
  String toFreeShipping(String amount);

  /// No description provided for @freeShippingUnlocked.
  ///
  /// In ar, this message translates to:
  /// **'مبروك! طلبك صار توصيله مجاني'**
  String get freeShippingUnlocked;

  /// No description provided for @couponHint.
  ///
  /// In ar, this message translates to:
  /// **'كود الخصم'**
  String get couponHint;

  /// No description provided for @couponApplied.
  ///
  /// In ar, this message translates to:
  /// **'تم تطبيق {code}'**
  String couponApplied(String code);

  /// No description provided for @couponNotFound.
  ///
  /// In ar, this message translates to:
  /// **'الكود غير صحيح'**
  String get couponNotFound;

  /// No description provided for @couponInactive.
  ///
  /// In ar, this message translates to:
  /// **'الكود منتهي'**
  String get couponInactive;

  /// No description provided for @couponMin.
  ///
  /// In ar, this message translates to:
  /// **'الكود يحتاج طلب بقيمة {amount} أو أكثر'**
  String couponMin(String amount);

  /// No description provided for @remove.
  ///
  /// In ar, this message translates to:
  /// **'إزالة'**
  String get remove;

  /// No description provided for @tryCodes.
  ///
  /// In ar, this message translates to:
  /// **'جرّب KHAIRAT10 أو WELCOME50'**
  String get tryCodes;

  /// No description provided for @giftWrap.
  ///
  /// In ar, this message translates to:
  /// **'تغليف هدية'**
  String get giftWrap;

  /// No description provided for @giftWrapBody.
  ///
  /// In ar, this message translates to:
  /// **'صندوق فاخر مع بطاقة إهداء بـ {amount}'**
  String giftWrapBody(String amount);

  /// No description provided for @giftMessageHint.
  ///
  /// In ar, this message translates to:
  /// **'رسالة الإهداء (اختياري)'**
  String get giftMessageHint;

  /// No description provided for @subtotal.
  ///
  /// In ar, this message translates to:
  /// **'المجموع الفرعي'**
  String get subtotal;

  /// No description provided for @discount.
  ///
  /// In ar, this message translates to:
  /// **'الخصم'**
  String get discount;

  /// No description provided for @shipping.
  ///
  /// In ar, this message translates to:
  /// **'التوصيل'**
  String get shipping;

  /// No description provided for @free.
  ///
  /// In ar, this message translates to:
  /// **'مجاني'**
  String get free;

  /// No description provided for @giftWrapFee.
  ///
  /// In ar, this message translates to:
  /// **'التغليف'**
  String get giftWrapFee;

  /// No description provided for @total.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get total;

  /// No description provided for @vatLine.
  ///
  /// In ar, this message translates to:
  /// **'يشمل ضريبة القيمة المضافة {rate}%: {amount}'**
  String vatLine(String rate, String amount);

  /// No description provided for @checkout.
  ///
  /// In ar, this message translates to:
  /// **'إتمام الطلب'**
  String get checkout;

  /// No description provided for @stockLimit.
  ///
  /// In ar, this message translates to:
  /// **'الكمية المطلوبة أكثر من المتوفر'**
  String get stockLimit;

  /// No description provided for @stepAddress.
  ///
  /// In ar, this message translates to:
  /// **'العنوان'**
  String get stepAddress;

  /// No description provided for @stepDelivery.
  ///
  /// In ar, this message translates to:
  /// **'التوصيل'**
  String get stepDelivery;

  /// No description provided for @stepPayment.
  ///
  /// In ar, this message translates to:
  /// **'الدفع'**
  String get stepPayment;

  /// No description provided for @deliveryAddress.
  ///
  /// In ar, this message translates to:
  /// **'عنوان التوصيل'**
  String get deliveryAddress;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @fullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get fullName;

  /// No description provided for @city.
  ///
  /// In ar, this message translates to:
  /// **'المدينة'**
  String get city;

  /// No description provided for @district.
  ///
  /// In ar, this message translates to:
  /// **'الحي'**
  String get district;

  /// No description provided for @street.
  ///
  /// In ar, this message translates to:
  /// **'الشارع ورقم المبنى'**
  String get street;

  /// No description provided for @nationalAddress.
  ///
  /// In ar, this message translates to:
  /// **'العنوان الوطني المختصر'**
  String get nationalAddress;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @deliveryTime.
  ///
  /// In ar, this message translates to:
  /// **'موعد التوصيل'**
  String get deliveryTime;

  /// No description provided for @slotExpress.
  ///
  /// In ar, this message translates to:
  /// **'توصيل سريع'**
  String get slotExpress;

  /// No description provided for @slotExpressBody.
  ///
  /// In ar, this message translates to:
  /// **'خلال 3 ساعات داخل المدينة'**
  String get slotExpressBody;

  /// No description provided for @slotStandard.
  ///
  /// In ar, this message translates to:
  /// **'توصيل عادي'**
  String get slotStandard;

  /// No description provided for @slotStandardBody.
  ///
  /// In ar, this message translates to:
  /// **'خلال 1-2 يوم عمل'**
  String get slotStandardBody;

  /// No description provided for @slotScheduled.
  ///
  /// In ar, this message translates to:
  /// **'توصيل مجدول'**
  String get slotScheduled;

  /// No description provided for @slotScheduledBody.
  ///
  /// In ar, this message translates to:
  /// **'تختار اليوم اللي يناسبك'**
  String get slotScheduledBody;

  /// No description provided for @paymentMethod.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع'**
  String get paymentMethod;

  /// No description provided for @payMada.
  ///
  /// In ar, this message translates to:
  /// **'مدى / بطاقة'**
  String get payMada;

  /// No description provided for @payMadaBody.
  ///
  /// In ar, this message translates to:
  /// **'مدى، فيزا، ماستركارد'**
  String get payMadaBody;

  /// No description provided for @payApple.
  ///
  /// In ar, this message translates to:
  /// **'Apple Pay'**
  String get payApple;

  /// No description provided for @payAppleBody.
  ///
  /// In ar, this message translates to:
  /// **'ادفع بلمسة'**
  String get payAppleBody;

  /// No description provided for @paySTC.
  ///
  /// In ar, this message translates to:
  /// **'STC Pay'**
  String get paySTC;

  /// No description provided for @paySTCBody.
  ///
  /// In ar, this message translates to:
  /// **'ادفع من محفظتك'**
  String get paySTCBody;

  /// No description provided for @payTabby.
  ///
  /// In ar, this message translates to:
  /// **'تابي'**
  String get payTabby;

  /// No description provided for @payTabbyBody.
  ///
  /// In ar, this message translates to:
  /// **'قسّمها على 4: {amount} كل شهر بدون فوائد'**
  String payTabbyBody(String amount);

  /// No description provided for @payCod.
  ///
  /// In ar, this message translates to:
  /// **'الدفع عند الاستلام'**
  String get payCod;

  /// No description provided for @payCodBody.
  ///
  /// In ar, this message translates to:
  /// **'نقدًا أو بالشبكة عند وصول الطلب'**
  String get payCodBody;

  /// No description provided for @cardNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم البطاقة'**
  String get cardNumber;

  /// No description provided for @cardExpiry.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الانتهاء'**
  String get cardExpiry;

  /// No description provided for @cardCvv.
  ///
  /// In ar, this message translates to:
  /// **'CVV'**
  String get cardCvv;

  /// No description provided for @cardHolder.
  ///
  /// In ar, this message translates to:
  /// **'الاسم على البطاقة'**
  String get cardHolder;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @payAmount.
  ///
  /// In ar, this message translates to:
  /// **'ادفع {amount}'**
  String payAmount(String amount);

  /// No description provided for @placeOrderCod.
  ///
  /// In ar, this message translates to:
  /// **'أكّد الطلب'**
  String get placeOrderCod;

  /// No description provided for @processing.
  ///
  /// In ar, this message translates to:
  /// **'جاري معالجة الدفع...'**
  String get processing;

  /// No description provided for @paymentMock.
  ///
  /// In ar, this message translates to:
  /// **'دفع تجريبي، ما راح ينخصم أي مبلغ'**
  String get paymentMock;

  /// No description provided for @applePaySheetPay.
  ///
  /// In ar, this message translates to:
  /// **'ادفع لـ خيرات'**
  String get applePaySheetPay;

  /// No description provided for @applePayConfirm.
  ///
  /// In ar, this message translates to:
  /// **'اضغط للتأكيد'**
  String get applePayConfirm;

  /// No description provided for @stcOtp.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز STC Pay المرسل لجوالك'**
  String get stcOtp;

  /// No description provided for @tabbyPlan.
  ///
  /// In ar, this message translates to:
  /// **'خطة الدفع'**
  String get tabbyPlan;

  /// No description provided for @tabbyToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get tabbyToday;

  /// No description provided for @tabbyInMonths.
  ///
  /// In ar, this message translates to:
  /// **'بعد {count} شهر'**
  String tabbyInMonths(int count);

  /// No description provided for @orderPlaced.
  ///
  /// In ar, this message translates to:
  /// **'تم استلام طلبك!'**
  String get orderPlaced;

  /// No description provided for @orderPlacedBody.
  ///
  /// In ar, this message translates to:
  /// **'رقم الطلب {id}. بنعطيك خبر مع كل خطوة.'**
  String orderPlacedBody(String id);

  /// No description provided for @trackOrder.
  ///
  /// In ar, this message translates to:
  /// **'تتبع الطلب'**
  String get trackOrder;

  /// No description provided for @viewInvoice.
  ///
  /// In ar, this message translates to:
  /// **'الفاتورة'**
  String get viewInvoice;

  /// No description provided for @continueShopping.
  ///
  /// In ar, this message translates to:
  /// **'متابعة التسوق'**
  String get continueShopping;

  /// No description provided for @myOrders.
  ///
  /// In ar, this message translates to:
  /// **'طلباتي'**
  String get myOrders;

  /// No description provided for @ordersActive.
  ///
  /// In ar, this message translates to:
  /// **'الحالية'**
  String get ordersActive;

  /// No description provided for @ordersPast.
  ///
  /// In ar, this message translates to:
  /// **'السابقة'**
  String get ordersPast;

  /// No description provided for @ordersEmpty.
  ///
  /// In ar, this message translates to:
  /// **'ما عندك طلبات هنا'**
  String get ordersEmpty;

  /// No description provided for @itemsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{منتج واحد} =2{منتجين} few{{count} منتجات} other{{count} منتج}}'**
  String itemsCount(int count);

  /// No description provided for @statusPlaced.
  ///
  /// In ar, this message translates to:
  /// **'تم الطلب'**
  String get statusPlaced;

  /// No description provided for @statusConfirmed.
  ///
  /// In ar, this message translates to:
  /// **'تم التأكيد'**
  String get statusConfirmed;

  /// No description provided for @statusPreparing.
  ///
  /// In ar, this message translates to:
  /// **'قيد التجهيز'**
  String get statusPreparing;

  /// No description provided for @statusShipped.
  ///
  /// In ar, this message translates to:
  /// **'مع المندوب'**
  String get statusShipped;

  /// No description provided for @statusDelivered.
  ///
  /// In ar, this message translates to:
  /// **'تم التوصيل'**
  String get statusDelivered;

  /// No description provided for @statusCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغي'**
  String get statusCancelled;

  /// No description provided for @statusPlacedBody.
  ///
  /// In ar, this message translates to:
  /// **'استلمنا طلبك'**
  String get statusPlacedBody;

  /// No description provided for @statusConfirmedBody.
  ///
  /// In ar, this message translates to:
  /// **'التاجر أكّد الطلب'**
  String get statusConfirmedBody;

  /// No description provided for @statusPreparingBody.
  ///
  /// In ar, this message translates to:
  /// **'نجهّز ونغلّف طلبك'**
  String get statusPreparingBody;

  /// No description provided for @statusShippedBody.
  ///
  /// In ar, this message translates to:
  /// **'المندوب في الطريق لك'**
  String get statusShippedBody;

  /// No description provided for @statusDeliveredBody.
  ///
  /// In ar, this message translates to:
  /// **'وصل طلبك، بالعافية'**
  String get statusDeliveredBody;

  /// No description provided for @statusCancelledBody.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء الطلب ورجعنا المبلغ'**
  String get statusCancelledBody;

  /// No description provided for @orderNo.
  ///
  /// In ar, this message translates to:
  /// **'طلب {id}'**
  String orderNo(String id);

  /// No description provided for @orderItems.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات'**
  String get orderItems;

  /// No description provided for @courier.
  ///
  /// In ar, this message translates to:
  /// **'المندوب: سالم • 4.9★'**
  String get courier;

  /// No description provided for @eta.
  ///
  /// In ar, this message translates to:
  /// **'الوصول المتوقع: {time}'**
  String eta(String time);

  /// No description provided for @cancelOrder.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الطلب'**
  String get cancelOrder;

  /// No description provided for @cancelConfirm.
  ///
  /// In ar, this message translates to:
  /// **'متأكد تبي تلغي الطلب؟'**
  String get cancelConfirm;

  /// No description provided for @cancelYes.
  ///
  /// In ar, this message translates to:
  /// **'نعم، ألغِ'**
  String get cancelYes;

  /// No description provided for @keepOrder.
  ///
  /// In ar, this message translates to:
  /// **'تراجع'**
  String get keepOrder;

  /// No description provided for @orderCancelled.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء الطلب'**
  String get orderCancelled;

  /// No description provided for @reorder.
  ///
  /// In ar, this message translates to:
  /// **'اطلب مرة ثانية'**
  String get reorder;

  /// No description provided for @reorderDone.
  ///
  /// In ar, this message translates to:
  /// **'أضفنا المنتجات للسلة'**
  String get reorderDone;

  /// No description provided for @rateOrder.
  ///
  /// In ar, this message translates to:
  /// **'قيّم طلبك'**
  String get rateOrder;

  /// No description provided for @rateTitle.
  ///
  /// In ar, this message translates to:
  /// **'كيف كانت تجربتك؟'**
  String get rateTitle;

  /// No description provided for @rateThanks.
  ///
  /// In ar, this message translates to:
  /// **'شكرًا على تقييمك!'**
  String get rateThanks;

  /// No description provided for @submit.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get submit;

  /// No description provided for @giftMessage.
  ///
  /// In ar, this message translates to:
  /// **'رسالة الإهداء'**
  String get giftMessage;

  /// No description provided for @invoiceTitle.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة ضريبية مبسطة'**
  String get invoiceTitle;

  /// No description provided for @seller.
  ///
  /// In ar, this message translates to:
  /// **'البائع'**
  String get seller;

  /// No description provided for @sellerName.
  ///
  /// In ar, this message translates to:
  /// **'مؤسسة خيرات للتجارة'**
  String get sellerName;

  /// No description provided for @vatNumber.
  ///
  /// In ar, this message translates to:
  /// **'الرقم الضريبي'**
  String get vatNumber;

  /// No description provided for @invoiceDate.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get invoiceDate;

  /// No description provided for @paidWith.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع'**
  String get paidWith;

  /// No description provided for @invoiceQrNote.
  ///
  /// In ar, this message translates to:
  /// **'رمز QR بصيغة هيئة الزكاة (تجريبي)'**
  String get invoiceQrNote;

  /// No description provided for @demoAdvance.
  ///
  /// In ar, this message translates to:
  /// **'تجربة: انقل الطلب للخطوة الجاية'**
  String get demoAdvance;

  /// No description provided for @account.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get account;

  /// No description provided for @guest.
  ///
  /// In ar, this message translates to:
  /// **'زائر'**
  String get guest;

  /// No description provided for @signIn.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get signIn;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @languageValue.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get languageValue;

  /// No description provided for @darkMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الداكن'**
  String get darkMode;

  /// No description provided for @region.
  ///
  /// In ar, this message translates to:
  /// **'الدولة والعملة'**
  String get region;

  /// No description provided for @regionSa.
  ///
  /// In ar, this message translates to:
  /// **'السعودية (ر.س، ضريبة 15%)'**
  String get regionSa;

  /// No description provided for @regionAe.
  ///
  /// In ar, this message translates to:
  /// **'الإمارات (د.إ، ضريبة 5%)'**
  String get regionAe;

  /// No description provided for @switchToMerchant.
  ///
  /// In ar, this message translates to:
  /// **'الانتقال للوحة التاجر'**
  String get switchToMerchant;

  /// No description provided for @switchToCustomer.
  ///
  /// In ar, this message translates to:
  /// **'الانتقال لواجهة العميل'**
  String get switchToCustomer;

  /// No description provided for @switchRole.
  ///
  /// In ar, this message translates to:
  /// **'تبديل الواجهة'**
  String get switchRole;

  /// No description provided for @resetDemo.
  ///
  /// In ar, this message translates to:
  /// **'إعادة بيانات الديمو'**
  String get resetDemo;

  /// No description provided for @resetDone.
  ///
  /// In ar, this message translates to:
  /// **'رجعت البيانات للبداية'**
  String get resetDone;

  /// No description provided for @about.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get about;

  /// No description provided for @aboutBody.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق تجريبي لمعرض الأعمال، مبني بـ Flutter لأندرويد وiOS والويب من كود واحد.'**
  String get aboutBody;

  /// No description provided for @dashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get dashboard;

  /// No description provided for @merchantHello.
  ///
  /// In ar, this message translates to:
  /// **'صباح الخير، متجر خيرات'**
  String get merchantHello;

  /// No description provided for @todaySales.
  ///
  /// In ar, this message translates to:
  /// **'مبيعات اليوم'**
  String get todaySales;

  /// No description provided for @ordersToday.
  ///
  /// In ar, this message translates to:
  /// **'طلبات اليوم'**
  String get ordersToday;

  /// No description provided for @avgOrder.
  ///
  /// In ar, this message translates to:
  /// **'متوسط الطلب'**
  String get avgOrder;

  /// No description provided for @weekSales.
  ///
  /// In ar, this message translates to:
  /// **'مبيعات 7 أيام'**
  String get weekSales;

  /// No description provided for @salesChart.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات آخر 7 أيام'**
  String get salesChart;

  /// No description provided for @topProducts.
  ///
  /// In ar, this message translates to:
  /// **'الأكثر مبيعًا'**
  String get topProducts;

  /// No description provided for @lowStockAlert.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{منتج واحد قارب يخلص} =2{منتجين قاربوا يخلصون} few{{count} منتجات قاربت تخلص} other{{count} منتج قارب يخلص}}'**
  String lowStockAlert(int count);

  /// No description provided for @needsAction.
  ///
  /// In ar, this message translates to:
  /// **'طلبات تنتظرك'**
  String get needsAction;

  /// No description provided for @orders.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات'**
  String get orders;

  /// No description provided for @products.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات'**
  String get products;

  /// No description provided for @coupons.
  ///
  /// In ar, this message translates to:
  /// **'الكوبونات'**
  String get coupons;

  /// No description provided for @moveTo.
  ///
  /// In ar, this message translates to:
  /// **'نقل إلى: {status}'**
  String moveTo(String status);

  /// No description provided for @statusUpdated.
  ///
  /// In ar, this message translates to:
  /// **'الحالة صارت: {status}'**
  String statusUpdated(String status);

  /// No description provided for @customer.
  ///
  /// In ar, this message translates to:
  /// **'العميل'**
  String get customer;

  /// No description provided for @stock.
  ///
  /// In ar, this message translates to:
  /// **'المخزون'**
  String get stock;

  /// No description provided for @price.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get price;

  /// No description provided for @visible.
  ///
  /// In ar, this message translates to:
  /// **'معروض في المتجر'**
  String get visible;

  /// No description provided for @hidden.
  ///
  /// In ar, this message translates to:
  /// **'مخفي'**
  String get hidden;

  /// No description provided for @editProduct.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المنتج'**
  String get editProduct;

  /// No description provided for @saved.
  ///
  /// In ar, this message translates to:
  /// **'تم الحفظ'**
  String get saved;

  /// No description provided for @newCoupon.
  ///
  /// In ar, this message translates to:
  /// **'كوبون جديد'**
  String get newCoupon;

  /// No description provided for @couponCode.
  ///
  /// In ar, this message translates to:
  /// **'الكود'**
  String get couponCode;

  /// No description provided for @percentOff.
  ///
  /// In ar, this message translates to:
  /// **'نسبة %'**
  String get percentOff;

  /// No description provided for @fixedOff.
  ///
  /// In ar, this message translates to:
  /// **'مبلغ ثابت'**
  String get fixedOff;

  /// No description provided for @couponValue.
  ///
  /// In ar, this message translates to:
  /// **'القيمة'**
  String get couponValue;

  /// No description provided for @minOrder.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى للطلب'**
  String get minOrder;

  /// No description provided for @couponUses.
  ///
  /// In ar, this message translates to:
  /// **'استُخدم {count} مرة'**
  String couponUses(int count);

  /// No description provided for @create.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء'**
  String get create;

  /// No description provided for @couponExists.
  ///
  /// In ar, this message translates to:
  /// **'الكود موجود من قبل'**
  String get couponExists;

  /// No description provided for @active.
  ///
  /// In ar, this message translates to:
  /// **'فعّال'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In ar, this message translates to:
  /// **'موقوف'**
  String get inactive;

  /// No description provided for @lowStock.
  ///
  /// In ar, this message translates to:
  /// **'قارب يخلص'**
  String get lowStock;

  /// No description provided for @sideTitle.
  ///
  /// In ar, this message translates to:
  /// **'خيرات: متجر المنتجات الخليجية'**
  String get sideTitle;

  /// No description provided for @sideBody.
  ///
  /// In ar, this message translates to:
  /// **'تطبيق Flutter كامل يشتغل على أندرويد وiOS والويب. جرّبه بنفسك في الجوال جنبك.'**
  String get sideBody;

  /// No description provided for @sideF1.
  ///
  /// In ar, this message translates to:
  /// **'دفع بمدى وApple Pay وSTC Pay وتابي'**
  String get sideF1;

  /// No description provided for @sideF2.
  ///
  /// In ar, this message translates to:
  /// **'فاتورة بضريبة 15% ورمز QR'**
  String get sideF2;

  /// No description provided for @sideF3.
  ///
  /// In ar, this message translates to:
  /// **'تتبع الطلب لحظة بلحظة'**
  String get sideF3;

  /// No description provided for @sideF4.
  ///
  /// In ar, this message translates to:
  /// **'لوحة تاجر للطلبات والمخزون والكوبونات'**
  String get sideF4;

  /// No description provided for @sideF5.
  ///
  /// In ar, this message translates to:
  /// **'عربي وإنجليزي، فاتح وداكن'**
  String get sideF5;

  /// No description provided for @bannerGiftBody.
  ///
  /// In ar, this message translates to:
  /// **'تغليف فاخر وبطاقة إهداء مع أي طلب'**
  String get bannerGiftBody;

  /// No description provided for @bannerDatesTitle.
  ///
  /// In ar, this message translates to:
  /// **'موسم التمور وصل'**
  String get bannerDatesTitle;

  /// No description provided for @bannerDatesBody.
  ///
  /// In ar, this message translates to:
  /// **'سكري وعجوة وخلاص من المزارع مباشرة'**
  String get bannerDatesBody;

  /// No description provided for @allProducts.
  ///
  /// In ar, this message translates to:
  /// **'كل المنتجات'**
  String get allProducts;

  /// No description provided for @vatAmount.
  ///
  /// In ar, this message translates to:
  /// **'ضريبة القيمة المضافة {rate}%'**
  String vatAmount(String rate);

  /// No description provided for @orderNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الطلب'**
  String get orderNumber;

  /// No description provided for @mockData.
  ///
  /// In ar, this message translates to:
  /// **'بيانات تجريبية'**
  String get mockData;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return SAr();
    case 'en':
      return SEn();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
