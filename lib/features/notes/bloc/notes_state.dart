part of 'notes_bloc.dart';

abstract class NotesState extends Equatable {}

class NotesLoadingState extends NotesState {
  @override
  List<Object?> get props => [];
}

class NotesLoadedState extends NotesState {
  NotesLoadedState({required this.notesList});

  final List<String> notesList;
  @override
  List<Object?> get props => [notesList];
}

class NotesLoadingFailureState extends NotesState {
  NotesLoadingFailureState({required this.exception});

  final Object exception;
  @override
  List<Object?> get props => [exception];
}

class NoteOpenedState extends NotesState {
  NoteOpenedState({required this.note});

  final Note note;
  @override
  List<Object?> get props => [note];
}
