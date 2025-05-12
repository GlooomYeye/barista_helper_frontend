import 'package:barista_helper/domain/models/note.dart';
import 'package:barista_helper/domain/repositories/note_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'notes_event.dart';
part 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  NotesBloc(this.noteRepository) : super(NotesLoadingState()) {
    on<LoadNotesEvent>(_onLoadNotes);
    on<OpenNoteEvent>(_onOpenNote);
    on<ReturnToListEvent>(_onReturnToList);
  }

  final NoteRepository noteRepository;

  List<String> _cachedNotes = [];

  void _onLoadNotes(event, emit) async {
    try {
      emit(NotesLoadingState());
      final notesList = await noteRepository.getNotesList();
      _cachedNotes = notesList;
      emit(NotesLoadedState(notesList: notesList));
    } catch (e) {
      emit(NotesLoadingFailureState(exception: e));
    }
  }

  void _onOpenNote(event, emit) async {
    try {
      emit(NotesLoadingState());
      final note = await noteRepository.getNote(event.noteName);
      emit(NoteOpenedState(note: note));
    } catch (e) {
      emit(NotesLoadingFailureState(exception: e));
    }
  }

  void _onReturnToList(ReturnToListEvent event, Emitter<NotesState> emit) {
    if (_cachedNotes.isNotEmpty) {
      emit(NotesLoadingState());
      emit(NotesLoadedState(notesList: _cachedNotes));
    } else {
      emit(NotesLoadingState());
    }
  }
}
