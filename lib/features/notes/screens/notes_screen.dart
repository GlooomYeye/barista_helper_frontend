import 'package:barista_helper/core/theme/app_theme.dart';
import 'package:barista_helper/features/notes/bloc/notes_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _notesScreenBloc = GetIt.I<NotesBloc>();

  @override
  void initState() {
    _notesScreenBloc.add(LoadNotesEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Конспекты',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: BlocBuilder<NotesBloc, NotesState>(
        bloc: _notesScreenBloc,
        builder: (context, state) {
          if (state is NotesLoadingState) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primaryBlue),
            );
          }
          if (state is NotesLoadedState) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.notesList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder:
                  (context, index) =>
                      _buildNoteItem(context, state.notesList[index]),
            );
          }
          if (state is NotesLoadingFailureState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Что-то пошло не так',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => _notesScreenBloc.add(LoadNotesEvent()),
                    child: Text(
                      'Повторить',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return Center(
            child: Text(
              'Нет конспектов',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoteItem(BuildContext context, String noteName) {
    return GestureDetector(
      onTap: () {
        _notesScreenBloc.add(OpenNoteEvent(noteName: noteName));
        Navigator.of(
          context,
          rootNavigator: false,
        ).pushNamed('/noteDetails', arguments: noteName);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: AppTheme.iconDecoration(),
              child: Icon(Icons.notes, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                noteName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Theme.of(context).hintColor),
          ],
        ),
      ),
    );
  }
}
