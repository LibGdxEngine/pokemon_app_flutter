import 'dart:convert';
import 'package:matcher/matcher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon_app/core/error/exceptions.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:pokemon_app/features/pokemon/data/datasources/pokemon_remote_data_source.dart';
import 'package:pokemon_app/features/pokemon/data/models/pokemon.dart';
import 'package:pokemon_app/features/pokemon/data/models/pokemons_list.dart';
import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  MockHttpClient mockHttpClient;
  PokemonRemoteDataSourceImp remoteDataSourceImp;
  final int tLimit = 20;
  final int tOffset = 20;
  final int tPokemonId = 2;
  final tPokemon = Pokemon.fromJson(json.decode(fixture('pokemon.json')));
  final tPokemonList =
      PokemonsList.fromJson(json.decode(fixture('pokemons_list.json')));
  setUp(() {
    mockHttpClient = MockHttpClient();
    remoteDataSourceImp =
        PokemonRemoteDataSourceImp(httpClient: mockHttpClient);
  });

  void setUpMockHttpClientSuccess200() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(fixture('pokemon.json'), 200));
  }

  void setUpMockHttpClientForPokemonsListSuccess200() {
    when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(fixture('pokemons_list.json'), 200));
  }

  void setUpMockHttpClientFailure404() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('something went wrong', 404));
  }

  group('get specific Pokemon Details', () {
    test(
      '''should perform a GET request on a URL with number
       being the endpoint and with application/json header''',
      () async {
        // arrange
        setUpMockHttpClientSuccess200();
        // act
        remoteDataSourceImp.getPokemonById(tPokemonId);
        // assert
        verify(mockHttpClient.get(
          'https://pokeapi.co/api/v2/pokemon/$tPokemonId',
          headers: {
            'Content-Type': 'application/json',
          },
        ));
      },
    );

    test(
      'should return pokemon details object when http request successes',
      () async {
        // arrange
        setUpMockHttpClientSuccess200();
        // act
        final result = await remoteDataSourceImp.getPokemonById(tPokemonId);
        // assert
        expect(result, equals(tPokemon));
      },
    );

    test(
      'should return server failure when http request failed',
      () async {
        // arrange
        setUpMockHttpClientFailure404();
        // act
        final call = remoteDataSourceImp.getPokemonById;
        // assert
        expect(() => call(tPokemonId), throwsA(TypeMatcher<ServerException>()));
      },
    );
  });

  group('get pokemons list', () {
    test(
      '''should return pokemons List with limit 20 pokemon 
        , 20 offset when http request success ''',
      () async {
        // arrange
        setUpMockHttpClientForPokemonsListSuccess200();
        // act
        final result =
            await remoteDataSourceImp.getPokemonsFromApi(tLimit, tOffset);
        // assert
        expect(result, equals(tPokemonList));
      },
    );

    test(
      'should return server failure when http request failed ',
      () async {
        // arrange
        setUpMockHttpClientFailure404();
        // act
        final result = remoteDataSourceImp.getPokemonsFromApi;
        // assert
        expect(
          () => result(tLimit, tOffset),
          throwsA(
            TypeMatcher<ServerException>(),
          ),
        );
      },
    );
  });
}
