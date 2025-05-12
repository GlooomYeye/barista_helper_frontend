part of 'notes_bloc.dart';

abstract class NotesEvent extends Equatable {}

class LoadNotesEvent extends NotesEvent {
  @override
  List<Object?> get props => [];
}

class OpenNoteEvent extends NotesEvent {
  OpenNoteEvent({required this.noteName});
  final String noteName;

  @override
  List<Object?> get props => [noteName];
}

class ReturnToListEvent extends NotesEvent {
  @override
  List<Object?> get props => [];
}
