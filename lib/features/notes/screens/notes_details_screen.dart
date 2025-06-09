import 'package:barista_helper/core/theme/app_theme.dart';
import 'package:barista_helper/features/notes/bloc/notes_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:get_it/get_it.dart';

class NoteDetailsScreen extends StatelessWidget {
  const NoteDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final noteBloc = GetIt.I<NotesBloc>();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: BlocBuilder<NotesBloc, NotesState>(
          bloc: noteBloc,
          builder: (context, state) {
            if (state is NoteOpenedState) {
              return Text(
                state.note.title,
                style: Theme.of(context).appBarTheme.titleTextStyle,
              );
            }
            return const SizedBox.shrink();
          },
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          ),
          onPressed: () {
            noteBloc.add(ReturnToListEvent());
            Navigator.pop(context);
          },
        ),
      ),
      body: BlocBuilder<NotesBloc, NotesState>(
        bloc: noteBloc,
        builder: (context, state) {
          if (state is NotesLoadingState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Center(
              child: CircularProgressIndicator(
                color: isDark ? AppTheme.primaryGreen : AppTheme.primaryBlue,
              ),
            );
          }
          if (state is NoteOpenedState) {
            return Padding(
              padding: const EdgeInsets.all(16),
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
                child: MarkdownWidget(
                  data: state.note.content,
                  config: MarkdownConfig(
                    configs: [
                      PConfig(
                        textStyle:
                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.6,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ) ??
                            const TextStyle(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return Center(
            child: Text(
              'Note is not available',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        },
      ),
    );
  }
}
