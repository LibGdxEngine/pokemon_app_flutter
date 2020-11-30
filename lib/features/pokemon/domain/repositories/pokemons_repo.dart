import 'package:dartz/dartz.dart';
import 'package:pokemon_app/core/error/failures.dart';
import 'package:pokemon_app/features/pokemon/data/models/pokemons_list.dart';

abstract class PokemonRepo {
  Future<Either<Failure, PokemonsList>> getPokemons(int limit, int offset);
}
