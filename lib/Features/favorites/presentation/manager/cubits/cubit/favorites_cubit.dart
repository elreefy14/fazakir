import 'package:fazakir/Features/favorites/data/repos/favorite_repository.dart';
import 'package:fazakir/core/utils/extensions/cubit_safe_emit.dart';
import 'package:fazakir/core/utils/func/get_it_setup.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fazakir/Features/favorites/domain/entities/favorite_entity.dart';
import 'package:flutter/material.dart';
part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit() : super(FavoritesInitial());

  final FavoriteRepository _favoriteRepository = getIt<FavoriteRepository>();
  List<FavoriteEntity> favorites = [];

  Future<void> toggleFavorite(FavoriteEntity entity) async {
    safeEmit(FavoritesLoading());
    await _favoriteRepository
        .toggleFavorite(entity)
        .onError((error, stackTrace) {
      safeEmit(FavoritesFailure(message: 'Failed to toggle favorite'));
      return;
    });

    safeEmit(ToggleFavorite());
    getFavorites();
  }

  Future<void> reorderFavorites(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = favorites.removeAt(oldIndex);
    favorites.insert(newIndex, item);
    await _favoriteRepository
        .reorderFavorites(favorites)
        .onError((error, _) {});
    safeEmit(FavoritesSuccess(favorites: List.from(favorites)));
  }

  Future<void> clearAllFavorites() async {
    safeEmit(FavoritesLoading());
    await _favoriteRepository.clearAllFavorites().onError((error, _) {
      safeEmit(FavoritesFailure(message: 'Failed to clear favorites'));
    });
    favorites = [];
    safeEmit(FavoritesSuccess(favorites: []));
  }

  void getFavorites() {
    safeEmit(FavoritesLoading());
    final List<FavoriteEntity> result = _favoriteRepository.getFavorites();
    favorites = result;
    safeEmit(FavoritesSuccess(favorites: result));
  }
}
