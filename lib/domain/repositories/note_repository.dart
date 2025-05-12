import 'package:barista_helper/domain/models/note.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:barista_helper/core/config/app_config.dart';

class NoteRepository {
  final Dio dio = GetIt.I<Dio>();
  final String baseUrl = AppConfig.baseUrl;
  NoteRepository();

  Future<List<String>> getNotesList() async {
    try {
      final response = await Dio().get('$baseUrl/api/notes');
      if (response.statusCode == 200) {
        return (response.data as List).map((item) => item.toString()).toList();
      } else {
        throw Exception('Error getting notes: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Connection error: ${e.message}');
    }
  }

  Future<Note> getNote(String name) async {
    try {
      final response = await Dio().get('$baseUrl/api/notes/$name');
      if (response.statusCode == 200) {
        return Note.fromJson(response.data);
      } else {
        throw Exception('Error getting note: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Connection error: ${e.message}');
    }
  }
}
