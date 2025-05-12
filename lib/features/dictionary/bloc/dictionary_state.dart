part of 'dictionary_bloc.dart';

abstract class DictionaryState extends Equatable {}

class DictionaryLoadingState extends DictionaryState {
  @override
  List<Object?> get props => [];
}

class DictionaryLoadedState extends DictionaryState {
  DictionaryLoadedState({required this.termsList});
  final List<Term> termsList;
  @override
  List<Object?> get props => [termsList];
}

class DictionaryLoadingFailureState extends DictionaryState {
  DictionaryLoadingFailureState({this.exception});
  final Object? exception;
  @override
  List<Object?> get props => [exception];
}
