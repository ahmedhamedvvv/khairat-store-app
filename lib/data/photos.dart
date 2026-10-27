import 'models.dart';

/// Products and categories that ship a real photo in assets/photos/.
/// Anything not listed falls back to its vector illustration.
const _productPhotos = <String>{
  'p1',
  'p2',
  'p3',
  'p4',
  'p5',
  'p6',
  'p7',
  'p8',
  'p9',
  'p10',
  'a1',
  'a2',
  'a3',
  'a4',
  'a5',
  'a6',
  'a7',
  'a8',
  'a9',
  'a10',
  'd1',
  'd2',
  'd3',
  'd4',
  'd5',
  'd6',
  'd7',
  'd8',
  'd9',
  'd10',
};
const _categoryPhotos = <CategoryId>{CategoryId.perfumes, CategoryId.abayas, CategoryId.dates};

String? productPhoto(String id) => _productPhotos.contains(id) ? 'assets/photos/$id.jpg' : null;
String? categoryPhoto(CategoryId id) => _categoryPhotos.contains(id) ? 'assets/photos/cat_${id.name}.jpg' : null;
