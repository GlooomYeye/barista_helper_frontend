import 'package:barista_helper/domain/models/term.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:barista_helper/core/config/app_config.dart';

class TermRepository {
  final Dio dio = GetIt.I<Dio>();
  final String baseUrl = AppConfig.baseUrl;
  TermRepository();

  Future<List<Term>> getTermsList() async {
    final response = await Dio().get('$baseUrl/api/terms');
    List<Term> terms =
        (response.data as List).map((item) => Term.fromJson(item)).toList();
    return terms;
  }
}
