import 'models.dart';

/// Products and categories that ship a real photo in assets/photos/.
/// Anything not listed falls back to its vector illustration.
const _productPhotos = <String>{};
const _categoryPhotos = <CategoryId>{};

String? productPhoto(String id) => _productPhotos.contains(id) ? 'assets/photos/$id.jpg' : null;
String? categoryPhoto(CategoryId id) => _categoryPhotos.contains(id) ? 'assets/photos/cat_${id.name}.jpg' : null;
