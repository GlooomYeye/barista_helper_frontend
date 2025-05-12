import 'package:barista_helper/domain/models/term.dart';
import 'package:barista_helper/domain/repositories/term_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'dictionary_event.dart';
part 'dictionary_state.dart';

class DictionaryBloc extends Bloc<DictionaryEvent, DictionaryState> {
  DictionaryBloc(this.termRepository) : super(DictionaryLoadingState()) {
    on<LoadDictionaryEvent>(_onLoadDictionary);
    on<SearchDictionaryEvent>(_onSearchDictionary);
  }

  final TermRepository termRepository;
  List<Term> _allTerms = [];

  Future<void> _onLoadDictionary(event, emit) async {
    try {
      emit(DictionaryLoadingState());
      _allTerms =
          await termRepository.getTermsList()
            ..sort(
              (a, b) => a.word.toLowerCase().compareTo(b.word.toLowerCase()),
            );
      emit(DictionaryLoadedState(termsList: _allTerms));
    } catch (e) {
      emit(DictionaryLoadingFailureState(exception: e));
    }
  }

  Future<void> _onSearchDictionary(SearchDictionaryEvent event, emit) async {
    if (_allTerms.isEmpty) return;

    final query = event.query.toLowerCase();
    if (query.isEmpty) {
      emit(DictionaryLoadedState(termsList: _allTerms));
      return;
    }

    final filteredTerms =
        _allTerms
            .where((term) => term.word.toLowerCase().contains(query))
            .toList()
          ..sort(
            (a, b) => a.word.toLowerCase().compareTo(b.word.toLowerCase()),
          );

    emit(DictionaryLoadedState(termsList: filteredTerms));
  }
}
