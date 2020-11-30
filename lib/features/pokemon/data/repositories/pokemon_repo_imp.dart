import 'package:pokemon_app/core/error/exceptions.dart';
import 'package:pokemon_app/core/network/NetworkInfo.dart';
import 'package:pokemon_app/features/pokemon/data/datasources/pokemon_local_data_source.dart';
import 'package:pokemon_app/features/pokemon/data/datasources/pokemon_remote_data_source.dart';
import 'package:pokemon_app/core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:pokemon_app/features/pokemon/data/models/pokemons_list.dart';
import 'package:pokemon_app/features/pokemon/domain/repositories/pokemons_repo.dart';

class PokemonRepoImp implements PokemonRepo {
  final PokemonRemoteDataSource pokemonRemoteDataSource;
  final PokemonLocalDataSource pokemonLocalDataSource;
  final NetworkInfo networkInfo;

  PokemonRepoImp({
    this.networkInfo,
    this.pokemonLocalDataSource,
    this.pokemonRemoteDataSource,
  });

  @override
  Future<Either<Failure, PokemonsList>> getPokemons(
      int limit, int offset) async {
    if (await networkInfo.isConnected) {
      try {
        final result =
            await pokemonRemoteDataSource.getPokemonsFromApi(limit, offset);
        pokemonLocalDataSource.cacheData(result);
        return Right(result);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final result = await pokemonLocalDataSource.getCachedData();
        return Right(result);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
}
