import 'dart:convert';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon_app/features/pokemon/data/models/pokemons_list.dart';
import 'package:pokemon_app/features/pokemon/domain/repositories/pokemons_repo.dart';
import 'package:pokemon_app/features/pokemon/domain/usecases/get_pokemons_data.dart';
import '../../../../fixtures/fixture_reader.dart';

class MockPokemonRepo extends Mock implements PokemonRepo {}

void main() {
  GetPokemonData usecase;
  MockPokemonRepo mockPokemonRepo;

  setUp(() {
    mockPokemonRepo = MockPokemonRepo();
    usecase = GetPokemonData(mockPokemonRepo);
  });

  int tOffset = 20;
  int tLimit = 20;

  test(
    'should get pokemon list limited with 20 results',
    () async {
      final Map<String, dynamic> jsonMap =
          json.decode(fixture('pokemons_list.json'));
      final tPokemons = PokemonsList.fromJson(jsonMap);
      // arrange
      when(mockPokemonRepo.getPokemons(any , any))
          .thenAnswer((_) async => Right(tPokemons));
      // act
      final result = await usecase(Params(limit: tLimit , offset: tOffset));
      // assert
      expect(result, Right(tPokemons));
      verify(mockPokemonRepo.getPokemons(tLimit, tOffset));
      verifyNoMoreInteractions(mockPokemonRepo);
    },
  );
}
