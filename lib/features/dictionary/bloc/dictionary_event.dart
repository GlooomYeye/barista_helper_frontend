part of 'dictionary_bloc.dart';

abstract class DictionaryEvent extends Equatable {}

class LoadDictionaryEvent extends DictionaryEvent {
  @override
  List<Object?> get props => [];
}

class SearchDictionaryEvent extends DictionaryEvent {
  final String query;

  SearchDictionaryEvent(this.query);

  @override
  List<Object?> get props => [query];
}
