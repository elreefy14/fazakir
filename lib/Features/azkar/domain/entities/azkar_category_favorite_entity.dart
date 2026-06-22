import 'package:fazakir/Features/azkar/data/models/azkar_item_model.dart';
import 'package:fazakir/Features/azkar/domain/entities/azkar_category_entity.dart';
import 'package:fazakir/Features/azkar/domain/entities/azkar_item_entity.dart';
import 'package:fazakir/Features/favorites/domain/entities/favorite_entity.dart';

/// Wraps an entire azkar category so it can be stored as a single favourite.
class AzkarCategoryFavoriteEntity extends FavoriteEntity {
  final int categoryId;
  final String categoryName;
  final List<AzkarItemEntity> azkar;

  AzkarCategoryFavoriteEntity({
    required this.categoryId,
    required this.categoryName,
    required this.azkar,
  });

  /// Create from an [AzkarCategoryEntity].
  factory AzkarCategoryFavoriteEntity.fromCategory(AzkarCategoryEntity cat) {
    return AzkarCategoryFavoriteEntity(
      categoryId: cat.id,
      categoryName: cat.category,
      azkar: cat.azkar,
    );
  }

  /// Convert back to [AzkarCategoryEntity] for navigating to ZikrView.
  AzkarCategoryEntity toCategory() {
    return AzkarCategoryEntity(
      id: categoryId,
      category: categoryName,
      azkar: azkar,
    );
  }

  @override
  String getIdentifier() => 'az_category-$categoryId-$categoryName';

  @override
  Map<String, dynamic> toJson() {
    return {
      'category_name': categoryName,
      'category_id': categoryId,
      'category_azkar': azkar
          .map((e) => (e is AzkarItemModel ? e : AzkarItemModel(id: e.id, text: e.text, count: e.count, source: e.source))
              .toJson())
          .toList(),
    };
  }

  factory AzkarCategoryFavoriteEntity.fromJson(Map<String, dynamic> json) {
    return AzkarCategoryFavoriteEntity(
      categoryId: json['category_id'] as int,
      categoryName: json['category_name'] as String,
      azkar: (json['category_azkar'] as List<dynamic>)
          .map((e) => AzkarItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
