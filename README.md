# خيرات · Khairat

متجر إلكتروني للمنتجات الخليجية المحلية (عطور وعود، عبايات، تمور وقهوة) مبني بـ Flutter، عربي أولاً مع دعم كامل للإنجليزية، وفيه لوحة تحكم للتاجر.

An Arabic-first Flutter storefront for Gulf local products (perfumes & oud, abayas, dates & coffee) with a full merchant dashboard. All data is mocked and stored on the device, so the demo runs with no backend.

**Live demo:** https://ahmedhamedvvv.github.io/khairat-store-app/ · **Android APK:** https://ahmedhamedvvv.github.io/khairat-store-app/khairat.apk

<p>
  <img src="docs/screenshots/home.png" width="200">
  <img src="docs/screenshots/product.png" width="200">
  <img src="docs/screenshots/cart.png" width="200">
  <img src="docs/screenshots/track.png" width="200">
</p>

## المميزات · Features

**العميل · Customer**
- Home with offer carousel and countdown, category rails, skeleton loading
- Categories with brand chips, sort and price/rating filters, search with recent searches, favorites
- Product page with hero transition, variants (size, color, weight), reviews and similar products
- Animated add-to-cart (the item flies into the cart icon)
- Cart with free-shipping progress, coupons (`KHAIRAT10`, `WELCOME50`), gift wrap and gift message
- 3-step checkout: address on a map, delivery slot, payment
- Mocked payments: **Mada** (card BIN detection), **Apple Pay**, STC Pay (OTP), Tabby (4 installments), cash on delivery
- Order tracking timeline, cancel, reorder, rating, and a ZATCA-style VAT invoice with QR code
- Saudi (SAR, 15% VAT) and UAE (AED, 5% VAT) regions
- Arabic / English, RTL / LTR, light / dark

**التاجر · Merchant**
- Dashboard with KPIs, a 7-day sales chart, low-stock alert, top products
- Orders by status, moving an order through placed → confirmed → preparing → shipped → delivered
- Product management: price, stock, visibility
- Coupon creation and toggling

## التقنيات · Stack

Flutter 3.47 · Riverpod 3 · go_router · flutter_animate · fl_chart · qr_flutter · intl / gen-l10n · shared_preferences · IBM Plex Sans Arabic

## الهيكل · Structure

```
lib/
  core/       theme tokens, formatting, desktop phone frame
  data/       models, seed data, pricing & VAT rules, local repository
  state/      Riverpod providers (catalog, cart, checkout, orders, settings)
  features/   welcome, home, catalog, product, cart, checkout, orders, account, merchant
  widgets/    shared UI (product card, vector product art, shells)
  l10n/       Arabic and English strings
test/         pricing, VAT, coupon and order-flow tests
```

## التشغيل · Run

```bash
flutter pub get
flutter run                 # mobile or desktop
flutter run -d chrome       # web
flutter test
```

On wide screens the web build shows the app inside a phone frame with a side panel. Add `?embed=1` to the URL to show the app alone (used for embedding in the portfolio site), and `?lang=en` or `?lang=ar` to pick the starting language.

## لقطات · Screenshots

| | | | |
|---|---|---|---|
| ![](docs/screenshots/welcome.png) | ![](docs/screenshots/co3.png) | ![](docs/screenshots/apple.png) | ![](docs/screenshots/success.png) |
| ![](docs/screenshots/invoice.png) | ![](docs/screenshots/orders.png) | ![](docs/screenshots/dash.png) | ![](docs/screenshots/mcoup.png) |
| ![](docs/screenshots/en_home.png) | ![](docs/screenshots/en_product.png) | ![](docs/screenshots/en_cat.png) | ![](docs/screenshots/en_account.png) |

![Desktop](docs/screenshots/d1.png)

## الصور · Photo credits

Product and category photos are free stock photos from [Pexels](https://www.pexels.com) under the [Pexels License](https://www.pexels.com/license/), resized and cropped to squares. Source photo per item:

- `p1`: [pexels.com/photo/16239693](https://www.pexels.com/photo/16239693/)
- `p2`: [pexels.com/photo/12402366](https://www.pexels.com/photo/12402366/)
- `p3`: [pexels.com/photo/8450248](https://www.pexels.com/photo/8450248/)
- `p4`: [pexels.com/photo/4041392](https://www.pexels.com/photo/4041392/)
- `p5`: [pexels.com/photo/7947731](https://www.pexels.com/photo/7947731/)
- `p6`: [pexels.com/photo/8054395](https://www.pexels.com/photo/8054395/)
- `p7`: [pexels.com/photo/12741172](https://www.pexels.com/photo/12741172/)
- `p8`: [pexels.com/photo/25525915](https://www.pexels.com/photo/25525915/)
- `p9`: [pexels.com/photo/10487658](https://www.pexels.com/photo/10487658/)
- `p10`: [pexels.com/photo/7249217](https://www.pexels.com/photo/7249217/)
- `a1`: [pexels.com/photo/8526255](https://www.pexels.com/photo/8526255/)
- `a2`: [pexels.com/photo/34658761](https://www.pexels.com/photo/34658761/)
- `a3`: [pexels.com/photo/13791336](https://www.pexels.com/photo/13791336/)
- `a4`: [pexels.com/photo/35324626](https://www.pexels.com/photo/35324626/)
- `a5`: [pexels.com/photo/9218640](https://www.pexels.com/photo/9218640/)
- `a6`: [pexels.com/photo/7249214](https://www.pexels.com/photo/7249214/)
- `a7`: [pexels.com/photo/8911826](https://www.pexels.com/photo/8911826/)
- `a8`: [pexels.com/photo/7249759](https://www.pexels.com/photo/7249759/)
- `a9`: [pexels.com/photo/9218394](https://www.pexels.com/photo/9218394/)
- `a10`: [pexels.com/photo/19987022](https://www.pexels.com/photo/19987022/)
- `d1`: [pexels.com/photo/4469611](https://www.pexels.com/photo/4469611/)
- `d2`: [pexels.com/photo/15913420](https://www.pexels.com/photo/15913420/)
- `d3`: [pexels.com/photo/15913411](https://www.pexels.com/photo/15913411/)
- `d4`: [pexels.com/photo/3993529](https://www.pexels.com/photo/3993529/)
- `d5`: [pexels.com/photo/20488301](https://www.pexels.com/photo/20488301/)
- `d6`: [pexels.com/photo/2291592](https://www.pexels.com/photo/2291592/)
- `d7`: [pexels.com/photo/12042620](https://www.pexels.com/photo/12042620/)
- `d8`: [pexels.com/photo/9762169](https://www.pexels.com/photo/9762169/)
- `d9`: [pexels.com/photo/30361023](https://www.pexels.com/photo/30361023/)
- `d10`: [pexels.com/photo/30146018](https://www.pexels.com/photo/30146018/)
- `cat_perfumes`: [pexels.com/photo/16722501](https://www.pexels.com/photo/16722501/)
- `cat_abayas`: [pexels.com/photo/2911204](https://www.pexels.com/photo/2911204/)
- `cat_dates`: [pexels.com/photo/4499229](https://www.pexels.com/photo/4499229/)
