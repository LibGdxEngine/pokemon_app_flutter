

import 'package:pokemon_app/features/pokemon/data/models/pokemons_list.dart';

abstract class PokemonLocalDataSource {
  Future<void> cacheData(PokemonsList pokemonsList);
  Future<PokemonsList> getCachedData();
}

class PokemonLocalDataSourceImp implements PokemonLocalDataSource {
  @override
  Future<void> cacheData(PokemonsList pokemonsList) {
    return Future.value(null);
  }

  @override
  Future<PokemonsList> getCachedData() {
    return Future.value(null);
  }
}
