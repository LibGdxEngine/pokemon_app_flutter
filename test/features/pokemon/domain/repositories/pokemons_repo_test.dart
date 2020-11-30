import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pokemon_app/core/error/failures.dart';
import 'package:pokemon_app/core/network/NetworkInfo.dart';
import 'package:pokemon_app/features/pokemon/data/datasources/pokemon_local_data_source.dart';
import 'package:pokemon_app/features/pokemon/data/datasources/pokemon_remote_data_source.dart';
import 'package:pokemon_app/features/pokemon/data/models/pokemons_list.dart';
import 'package:pokemon_app/features/pokemon/data/repositories/pokemon_repo_imp.dart';
import '../../../../fixtures/fixture_reader.dart';
import 'package:pokemon_app/core/error/exceptions.dart';

class MockPokemoneRemoteDataSource extends Mock
    implements PokemonRemoteDataSource {}

class MockLocalDataSource extends Mock implements PokemonLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  PokemonRepoImp repository;
  MockPokemoneRemoteDataSource mockPokemoneRemoteDataSource;
  MockLocalDataSource mockLocalDataSource;
  MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockNetworkInfo = MockNetworkInfo();
    mockLocalDataSource = MockLocalDataSource();
    mockPokemoneRemoteDataSource = MockPokemoneRemoteDataSource();
    repository = PokemonRepoImp(
      networkInfo: mockNetworkInfo,
      pokemonLocalDataSource: mockLocalDataSource,
      pokemonRemoteDataSource: mockPokemoneRemoteDataSource,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('getPokemons', () {
    final int tLimit = 20;
    final int tOffset = 20;
    final Map<String, dynamic> jsonMap =
        json.decode(fixture('pokemons_list.json'));
    final tPokemons = PokemonsList.fromJson(jsonMap);
    test(
      'should check if device is online ',
      () async {
        // arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        // act
        repository.getPokemons(tLimit, tOffset);
        // assert
        verify(mockNetworkInfo.isConnected);
      },
    );

    runTestsOnline(() {
      test(
        'should return list of pokemons when device is online and result code is 200',
        () async {
          // arrange
          when(mockPokemoneRemoteDataSource.getPokemonsFromApi(any, any))
              .thenAnswer((_) async => tPokemons);
          // act
          final result = await repository.getPokemons(tLimit, tOffset);
          // assert
          verify(
              mockPokemoneRemoteDataSource.getPokemonsFromApi(tLimit, tOffset));
          expect(result, equals(Right(tPokemons)));
        },
      );

      test(
        'should cache pokemons data when device is online and result code is 200',
        () async {
          // arrange
          when(mockPokemoneRemoteDataSource.getPokemonsFromApi(any, any))
              .thenAnswer((_) async => tPokemons);
          // act
          await repository.getPokemons(tLimit, tOffset);
          // assert
          verify(
            mockPokemoneRemoteDataSource.getPokemonsFromApi(tLimit, tOffset),
          );
          verify(mockLocalDataSource.cacheData(tPokemons));
        },
      );

      test(
        'should return server failure when the call to remote data source is unsuccessful',
        () async {
          // arrange
          when(mockPokemoneRemoteDataSource.getPokemonsFromApi(any, any))
              .thenThrow(ServerException());
          // act
          final result = await repository.getPokemons(tLimit, tOffset);
          // assert
          expect(result, equals(Left(ServerFailure())));
          verifyZeroInteractions(mockLocalDataSource);
        },
      );
    });

    runTestsOffline(() {
      test(
        'should load cached data when device is offline and cached data is present ',
        () async {
          // arrange
          when(mockLocalDataSource.getCachedData())
              .thenAnswer((_) async => tPokemons);
          // act
          final result = await repository.getPokemons(tLimit, tOffset);
          // assert
          expect(result, equals(Right(tPokemons)));
          verify(mockLocalDataSource.getCachedData());
          verifyNoMoreInteractions(mockPokemoneRemoteDataSource);
        },
      );

      test(
        'should return cache failure when device is offline and data is not exist',
        () async {
          // arrange
          when(mockLocalDataSource.getCachedData())
          .thenThrow(CacheException());
          // act
          final result = await repository.getPokemons(tLimit , tOffset);
          // assert
          verify(mockLocalDataSource.getCachedData());  
          verifyZeroInteractions(mockPokemoneRemoteDataSource);
          expect(result, equals(Left(CacheFailure())));
        },
      );
    });
  });
}
