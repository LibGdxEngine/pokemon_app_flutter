import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:pokemon_app/core/error/failures.dart';
import 'package:pokemon_app/core/usecases/usecases.dart';
import 'package:pokemon_app/features/pokemon/data/models/pokemons_list.dart';
import 'package:pokemon_app/features/pokemon/domain/repositories/pokemons_repo.dart';

class GetPokemonData implements UseCase<PokemonsList, Params> {
  PokemonRepo pokemonRepo;

  GetPokemonData(this.pokemonRepo);

  @override
  Future<Either<Failure, PokemonsList>> call(Params params) async {
    return await pokemonRepo.getPokemons(params.limit, params.offset);
  }
}

class Params extends Equatable {
  final int limit;
  final int offset;

  Params({@required this.limit, @required this.offset});

  @override
  List<Object> get props => [offset];
}
