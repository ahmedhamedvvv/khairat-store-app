// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Khairat';

  @override
  String get appTagline => 'Gulf treasures, to your door';

  @override
  String get welcomeTitle => 'Perfumes, abayas and dates from local makers';

  @override
  String get welcomeBody =>
      'A demo store with two apps in one: a shopper app and a merchant dashboard. Pick one to try.';

  @override
  String get shopAsCustomer => 'Shop as a customer';

  @override
  String get shopAsCustomerBody => 'Browse, add to cart, pay and track';

  @override
  String get enterAsMerchant => 'Enter as merchant';

  @override
  String get enterAsMerchantBody => 'Sales, orders, stock and coupons';

  @override
  String get demoNote => 'Demo build: all data and payments are mock';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginSubtitle => 'We will text you a verification code';

  @override
  String get phoneLabel => 'Mobile number';

  @override
  String get phoneInvalid => 'Enter a 9-digit number starting with 5';

  @override
  String get sendCode => 'Send code';

  @override
  String get otpTitle => 'Enter the code';

  @override
  String otpHint(String phone) {
    return 'We sent a 4-digit code to $phone. Any code works in the demo.';
  }

  @override
  String get verify => 'Verify';

  @override
  String get continueAsGuest => 'Browse as guest';

  @override
  String get navHome => 'Home';

  @override
  String get navCategories => 'Categories';

  @override
  String get navCart => 'Cart';

  @override
  String get navOrders => 'Orders';

  @override
  String get navAccount => 'Account';

  @override
  String greeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get greetingGuest => 'Welcome';

  @override
  String get deliverTo => 'Deliver to';

  @override
  String get searchHint => 'Search perfume, abaya, dates...';

  @override
  String get offerTitle => 'Winter season deals';

  @override
  String get offerBody => 'Up to 15% off oud, bakhoor and selected dates';

  @override
  String get endsIn => 'Ends in';

  @override
  String get shopNow => 'Shop now';

  @override
  String get categories => 'Categories';

  @override
  String get bestSellers => 'Best sellers';

  @override
  String get newArrivals => 'New arrivals';

  @override
  String get giftIdeas => 'Gift ideas';

  @override
  String get seeAll => 'See all';

  @override
  String freeShippingOver(String amount) {
    return 'Free delivery over $amount';
  }

  @override
  String productsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '1 product',
    );
    return '$_temp0';
  }

  @override
  String get sortBy => 'Sort';

  @override
  String get sortPopular => 'Most popular';

  @override
  String get sortPriceLow => 'Price: low to high';

  @override
  String get sortPriceHigh => 'Price: high to low';

  @override
  String get sortRating => 'Top rated';

  @override
  String get sortNewest => 'Newest';

  @override
  String get filter => 'Filter';

  @override
  String get all => 'All';

  @override
  String get inStockOnly => 'In stock only';

  @override
  String get onSaleOnly => 'On sale only';

  @override
  String maxPrice(String amount) {
    return 'Max price: $amount';
  }

  @override
  String get apply => 'Apply';

  @override
  String get reset => 'Reset';

  @override
  String get noResults => 'No results';

  @override
  String get noResultsBody => 'Try another word or browse categories';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get popularSearches => 'Popular searches';

  @override
  String get clear => 'Clear';

  @override
  String get addToCart => 'Add to cart';

  @override
  String get addedToCart => 'Added to cart';

  @override
  String get viewCart => 'View cart';

  @override
  String get outOfStock => 'Out of stock';

  @override
  String onlyLeft(int count) {
    return 'Only $count left';
  }

  @override
  String get inStock => 'In stock';

  @override
  String get description => 'Description';

  @override
  String get reviews => 'Reviews';

  @override
  String reviewsCount(int count) {
    return '$count reviews';
  }

  @override
  String get similar => 'You may also like';

  @override
  String get chooseOption => 'Choose';

  @override
  String get quantity => 'Quantity';

  @override
  String get vatIncluded => 'Price includes VAT';

  @override
  String soldCount(int count) {
    return '$count sold';
  }

  @override
  String get newBadge => 'New';

  @override
  String get favorites => 'Favorites';

  @override
  String get favoritesEmpty => 'No favorites yet';

  @override
  String get favoritesEmptyBody =>
      'Tap the heart on any product to save it here';

  @override
  String get cart => 'Cart';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get cartEmptyBody => 'Start shopping and discover Gulf treasures';

  @override
  String get startShopping => 'Start shopping';

  @override
  String toFreeShipping(String amount) {
    return '$amount more for free delivery';
  }

  @override
  String get freeShippingUnlocked => 'Nice! Your delivery is free';

  @override
  String get couponHint => 'Discount code';

  @override
  String couponApplied(String code) {
    return '$code applied';
  }

  @override
  String get couponNotFound => 'Invalid code';

  @override
  String get couponInactive => 'This code has expired';

  @override
  String couponMin(String amount) {
    return 'This code needs an order of $amount or more';
  }

  @override
  String get remove => 'Remove';

  @override
  String get tryCodes => 'Try KHAIRAT10 or WELCOME50';

  @override
  String get giftWrap => 'Gift wrap';

  @override
  String giftWrapBody(String amount) {
    return 'Luxury box with a gift card for $amount';
  }

  @override
  String get giftMessageHint => 'Gift message (optional)';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get discount => 'Discount';

  @override
  String get shipping => 'Delivery';

  @override
  String get free => 'Free';

  @override
  String get giftWrapFee => 'Gift wrap';

  @override
  String get total => 'Total';

  @override
  String vatLine(String rate, String amount) {
    return 'Includes $rate% VAT: $amount';
  }

  @override
  String get checkout => 'Checkout';

  @override
  String get stockLimit => 'Not enough stock for that quantity';

  @override
  String get stepAddress => 'Address';

  @override
  String get stepDelivery => 'Delivery';

  @override
  String get stepPayment => 'Payment';

  @override
  String get deliveryAddress => 'Delivery address';

  @override
  String get edit => 'Edit';

  @override
  String get fullName => 'Full name';

  @override
  String get city => 'City';

  @override
  String get district => 'District';

  @override
  String get street => 'Street and building';

  @override
  String get nationalAddress => 'National Address short code';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get deliveryTime => 'Delivery time';

  @override
  String get slotExpress => 'Express';

  @override
  String get slotExpressBody => 'Within 3 hours in the city';

  @override
  String get slotStandard => 'Standard';

  @override
  String get slotStandardBody => '1-2 business days';

  @override
  String get slotScheduled => 'Scheduled';

  @override
  String get slotScheduledBody => 'Pick a day that suits you';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get payMada => 'mada / card';

  @override
  String get payMadaBody => 'mada, Visa, Mastercard';

  @override
  String get payApple => 'Apple Pay';

  @override
  String get payAppleBody => 'Pay with one tap';

  @override
  String get paySTC => 'STC Pay';

  @override
  String get paySTCBody => 'Pay from your wallet';

  @override
  String get payTabby => 'Tabby';

  @override
  String payTabbyBody(String amount) {
    return 'Split in 4: $amount a month, no interest';
  }

  @override
  String get payCod => 'Cash on delivery';

  @override
  String get payCodBody => 'Cash or card when it arrives';

  @override
  String get cardNumber => 'Card number';

  @override
  String get cardExpiry => 'Expiry';

  @override
  String get cardCvv => 'CVV';

  @override
  String get cardHolder => 'Name on card';

  @override
  String get next => 'Next';

  @override
  String payAmount(String amount) {
    return 'Pay $amount';
  }

  @override
  String get placeOrderCod => 'Place order';

  @override
  String get processing => 'Processing payment...';

  @override
  String get paymentMock => 'Mock payment, nothing will be charged';

  @override
  String get applePaySheetPay => 'Pay Khairat';

  @override
  String get applePayConfirm => 'Tap to confirm';

  @override
  String get stcOtp => 'Enter the STC Pay code sent to your phone';

  @override
  String get tabbyPlan => 'Payment plan';

  @override
  String get tabbyToday => 'Today';

  @override
  String tabbyInMonths(int count) {
    return 'In $count months';
  }

  @override
  String get orderPlaced => 'Order placed!';

  @override
  String orderPlacedBody(String id) {
    return 'Order $id. We will update you at every step.';
  }

  @override
  String get trackOrder => 'Track order';

  @override
  String get viewInvoice => 'Invoice';

  @override
  String get continueShopping => 'Continue shopping';

  @override
  String get myOrders => 'My orders';

  @override
  String get ordersActive => 'Active';

  @override
  String get ordersPast => 'Past';

  @override
  String get ordersEmpty => 'No orders here';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get statusPlaced => 'Placed';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusPreparing => 'Preparing';

  @override
  String get statusShipped => 'Out for delivery';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusPlacedBody => 'We received your order';

  @override
  String get statusConfirmedBody => 'The merchant confirmed it';

  @override
  String get statusPreparingBody => 'Packing your order';

  @override
  String get statusShippedBody => 'The courier is on the way';

  @override
  String get statusDeliveredBody => 'Delivered. Enjoy!';

  @override
  String get statusCancelledBody => 'Cancelled and refunded';

  @override
  String orderNo(String id) {
    return 'Order $id';
  }

  @override
  String get orderItems => 'Items';

  @override
  String get courier => 'Courier: Salem • 4.9★';

  @override
  String eta(String time) {
    return 'Estimated arrival: $time';
  }

  @override
  String get cancelOrder => 'Cancel order';

  @override
  String get cancelConfirm => 'Cancel this order?';

  @override
  String get cancelYes => 'Yes, cancel';

  @override
  String get keepOrder => 'Keep it';

  @override
  String get orderCancelled => 'Order cancelled';

  @override
  String get reorder => 'Order again';

  @override
  String get reorderDone => 'Items added to your cart';

  @override
  String get rateOrder => 'Rate your order';

  @override
  String get rateTitle => 'How was it?';

  @override
  String get rateThanks => 'Thanks for your rating!';

  @override
  String get submit => 'Submit';

  @override
  String get giftMessage => 'Gift message';

  @override
  String get invoiceTitle => 'Simplified tax invoice';

  @override
  String get seller => 'Seller';

  @override
  String get sellerName => 'Khairat Trading Est.';

  @override
  String get vatNumber => 'VAT number';

  @override
  String get invoiceDate => 'Date';

  @override
  String get paidWith => 'Paid with';

  @override
  String get invoiceQrNote => 'ZATCA-style QR code (demo)';

  @override
  String get demoAdvance => 'Demo: move to next step';

  @override
  String get account => 'Account';

  @override
  String get guest => 'Guest';

  @override
  String get signIn => 'Sign in';

  @override
  String get language => 'Language';

  @override
  String get languageValue => 'English';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get region => 'Country and currency';

  @override
  String get regionSa => 'Saudi Arabia (SAR, 15% VAT)';

  @override
  String get regionAe => 'UAE (AED, 5% VAT)';

  @override
  String get switchToMerchant => 'Switch to merchant';

  @override
  String get switchToCustomer => 'Switch to shopper';

  @override
  String get switchRole => 'Switch app';

  @override
  String get resetDemo => 'Reset demo data';

  @override
  String get resetDone => 'Demo data reset';

  @override
  String get about => 'About';

  @override
  String get aboutBody =>
      'A portfolio demo built with Flutter for Android, iOS and web from one codebase.';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get merchantHello => 'Good morning, Khairat store';

  @override
  String get todaySales => 'Sales today';

  @override
  String get ordersToday => 'Orders today';

  @override
  String get avgOrder => 'Avg. order';

  @override
  String get weekSales => '7-day sales';

  @override
  String get salesChart => 'Sales, last 7 days';

  @override
  String get topProducts => 'Top products';

  @override
  String lowStockAlert(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products running low',
      one: '1 product running low',
    );
    return '$_temp0';
  }

  @override
  String get needsAction => 'Orders waiting for you';

  @override
  String get orders => 'Orders';

  @override
  String get products => 'Products';

  @override
  String get coupons => 'Coupons';

  @override
  String moveTo(String status) {
    return 'Move to: $status';
  }

  @override
  String statusUpdated(String status) {
    return 'Status is now: $status';
  }

  @override
  String get customer => 'Customer';

  @override
  String get stock => 'Stock';

  @override
  String get price => 'Price';

  @override
  String get visible => 'Visible in store';

  @override
  String get hidden => 'Hidden';

  @override
  String get editProduct => 'Edit product';

  @override
  String get saved => 'Saved';

  @override
  String get newCoupon => 'New coupon';

  @override
  String get couponCode => 'Code';

  @override
  String get percentOff => 'Percent';

  @override
  String get fixedOff => 'Fixed amount';

  @override
  String get couponValue => 'Value';

  @override
  String get minOrder => 'Minimum order';

  @override
  String couponUses(int count) {
    return 'Used $count times';
  }

  @override
  String get create => 'Create';

  @override
  String get couponExists => 'That code already exists';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Paused';

  @override
  String get lowStock => 'Low stock';

  @override
  String get sideTitle => 'Khairat: a Gulf local-products store';

  @override
  String get sideBody =>
      'A complete Flutter app for Android, iOS and web. Try it right here in the phone.';

  @override
  String get sideF1 => 'mada, Apple Pay, STC Pay and Tabby checkout';

  @override
  String get sideF2 => '15% VAT invoice with QR code';

  @override
  String get sideF3 => 'Live order tracking';

  @override
  String get sideF4 => 'Merchant dashboard: orders, stock, coupons';

  @override
  String get sideF5 => 'Arabic and English, light and dark';

  @override
  String get bannerGiftBody => 'Luxury wrapping and a gift card with any order';

  @override
  String get bannerDatesTitle => 'Dates season is here';

  @override
  String get bannerDatesBody =>
      'Sukkari, ajwa and khalas straight from the farms';

  @override
  String get allProducts => 'All products';

  @override
  String vatAmount(String rate) {
    return 'VAT $rate%';
  }

  @override
  String get orderNumber => 'Order no.';

  @override
  String get mockData => 'Mock data';
}
