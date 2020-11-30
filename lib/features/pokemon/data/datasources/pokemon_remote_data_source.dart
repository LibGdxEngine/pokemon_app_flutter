import 'dart:convert';
import 'package:pokemon_app/core/error/exceptions.dart';
import 'package:http/http.dart' as http;
import 'package:pokemon_app/features/pokemon/data/models/pokemon.dart';
import 'package:pokemon_app/features/pokemon/data/models/pokemons_list.dart';

abstract class PokemonRemoteDataSource {
  Future<PokemonsList> getPokemonsFromApi(int limit, int offset);
  Future<Pokemon> getPokemonById(int id);
}

class PokemonRemoteDataSourceImp extends PokemonRemoteDataSource {
  http.Client httpClient;
  static const String url = "https://pokeapi.co/api/v2/pokemon";

  PokemonRemoteDataSourceImp({this.httpClient});

  @override
  Future<PokemonsList> getPokemonsFromApi(int limit, int offset) async {
    final result = await httpClient.get(
      '$url/?offset=$offset&limit=$limit',
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (result.statusCode == 200) {
      return PokemonsList.fromJson(json.decode(result.body));
    } else {
      throw ServerException();
    }
  }

  @override
  Future<Pokemon> getPokemonById(int id) async {
    final result = await httpClient.get(
      '$url/$id',
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (result.statusCode == 200) {
      return Pokemon.fromJson(json.decode(result.body));
    } else {
      throw ServerException();
    }
  }
}
