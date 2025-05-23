import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ApiService {
  final Dio _dio;

  ApiService({required String baseUrl, Map<String, dynamic>? headers})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          headers: headers ?? {},
          connectTimeout: const Duration(milliseconds: 10000),
          receiveTimeout: const Duration(milliseconds: 10000),
        ));

  // 全局 loading 状态控制
  static ValueNotifier<bool> isLoading = ValueNotifier(false);

  // 设置全局 loading
  void _setLoading(bool value, {bool? override}) {
    if (override == null || override) {
      isLoading.value = value;
    }
  }

  // GET 请求
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters,
      Map<String, dynamic>? headers,
      bool? showLoading}) async {
    _setLoading(true, override: showLoading);
    try {
      return await _dio.get(path,
          queryParameters: queryParameters, options: Options(headers: headers));
    } finally {
      _setLoading(false, override: showLoading);
    }
  }

  // POST 请求
  Future<Response> post(String path,
      {dynamic data,
      Map<String, dynamic>? headers,
      bool? showLoading,
      bool isFormData = false}) async {
    _setLoading(true, override: showLoading);
    try {
      final options = Options(headers: headers);
      final body = isFormData ? FormData.fromMap(data) : data;
      return await _dio.post(path, data: body, options: options);
    } finally {
      _setLoading(false, override: showLoading);
    }
  }

  // PUT 请求
  Future<Response> put(String path,
      {dynamic data, Map<String, dynamic>? headers, bool? showLoading}) async {
    _setLoading(true, override: showLoading);
    try {
      return await _dio.put(path,
          data: data, options: Options(headers: headers));
    } finally {
      _setLoading(false, override: showLoading);
    }
  }

  // DELETE 请求
  Future<Response> delete(String path,
      {dynamic data, Map<String, dynamic>? headers, bool? showLoading}) async {
    _setLoading(true, override: showLoading);
    try {
      return await _dio.delete(path,
          data: data, options: Options(headers: headers));
    } finally {
      _setLoading(false, override: showLoading);
    }
  }

  // 处理流式传输（单字返回）
  Stream<String> postStreamSingleChar(String path,
      {dynamic data, Map<String, dynamic>? headers}) async* {
    final options =
        Options(headers: headers, responseType: ResponseType.stream);
    final response = await _dio.post(path, data: data, options: options);
    final stream = response.data.stream;

    String buffer = '';
    await for (final chunk in stream) {
      final decodedChunk = utf8.decode(chunk);
      buffer += decodedChunk;
      // 立即处理每个字符
      while (buffer.isNotEmpty) {
        // 处理换行符
        if (buffer.contains('\n')) {
          final lines = buffer.split('\n');
          for (final line in lines) {
            if (line.isNotEmpty) {
              final chunk = line.replaceAll('\\n', '\n');
              if (chunk != '[SUCCESS]') {
                // 逐字返回
                for (var i = 0; i < chunk.length; i++) {
                  yield chunk[i];
                  await Future.delayed(Duration(milliseconds: 50)); // 控制打字速度
                }
              }
            }
          }
          buffer = '';
          break;
        } else {
          // 如果没有换行符，直接返回字符
          yield buffer[0];
          buffer = buffer.substring(1);
        }
      }
    }
  }

// 处理流式传输（data:{} 格式）
  Stream<Map<String, dynamic>> postStreamData(String path,
      {dynamic data, Map<String, dynamic>? headers}) async* {
    final options =
        Options(headers: headers, responseType: ResponseType.stream);
    final response = await _dio.post(path, data: data, options: options);
    final stream = response.data.stream;

    String buffer = '';
    await for (final chunk in stream) {
      final decodedChunk = utf8.decode(chunk); // 直接解码 Uint8List
      buffer += decodedChunk;
      if (buffer.contains('\n')) {
        final lines = buffer.split('\n');
        for (final line in lines) {
          if (line.startsWith('data:')) {
            final jsonData = line.substring(5).trim();
            if (jsonData.isNotEmpty && jsonData != '[DONE]') {
              if (jsonData == '[SUCCESS]') {
                continue;
              }
              if (jsonData.startsWith('[ERROR]')) {
                throw Exception('API 错误: $jsonData');
              }
              yield json.decode(jsonData);
            }
          }
        }
        buffer = '';
      }
    }
  }
}
