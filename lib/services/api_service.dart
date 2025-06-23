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

  // 统一处理响应
  dynamic _handleResponse(Response response, BuildContext? context) {
    final data = response.data;
    if (data is Map && data.containsKey('msg')) {
      if (data['msg'] == '请先登录' || data['code'] == 401) {
        // TODO: 清理本地用户信息，跳转登录页
        // 例如：UserStore.instance.logout();
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('请先登录')),
          );
        }
        throw Exception('请先登录');
      }
      if (data['code'] == 400) {
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['msg'].toString())),
          );
        }
        throw Exception(data['msg'].toString());
      }
    }
    return data;
  }

  // GET 请求
  Future<dynamic> get(String path,
      {Map<String, dynamic>? queryParameters,
      Map<String, dynamic>? headers,
      bool? showLoading,
      BuildContext? context}) async {
    _setLoading(true, override: showLoading);
    try {
      final response = await _dio.get(path,
          queryParameters: queryParameters, options: Options(headers: headers));
      return _handleResponse(response, context);
    } finally {
      _setLoading(false, override: showLoading);
    }
  }

  // POST 请求
  Future<dynamic> post(String path,
      {dynamic data,
      Map<String, dynamic>? headers,
      bool? showLoading,
      bool isFormData = false,
      BuildContext? context}) async {
    _setLoading(true, override: showLoading);
    try {
      final options = Options(headers: headers);
      final body = isFormData ? FormData.fromMap(data) : data;
      final response = await _dio.post(path, data: body, options: options);
      return _handleResponse(response, context);
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

final ApiService api = ApiService(baseUrl: '你的后端地址');
// 获取公共请求头（如需 token，可自行扩展）
Map<String, dynamic> getHeaders(
    {String? token, String? uid, String? accessToken}) {
  return {
    'uid': uid ?? '',
    'token': token ?? '',
    'access-token': accessToken ?? '',
  };
}

// 登录接口
Future<dynamic> login(String phone, {String? code, String? pass}) {
  if (phone.isEmpty) throw Exception('手机号不能为空');
  if ((code == null || code.isEmpty) && (pass == null || pass.isEmpty)) {
    throw Exception('登录失败');
  }
  final data = {
    'phone': phone,
    if (code != null) 'code': code,
    if (pass != null) 'pass': pass
  };
  return api.post('/v1/user/login', data: data);
}

// 登录调试接口
Future<dynamic> testLogin() {
  return api.get('/v1/user/loginDebug');
}

// 发送验证码
Future<dynamic> sendCode(String phone) {
  if (phone.isEmpty) throw Exception('手机号不能为空');
  return api.post('/v1/user/send_sms', data: {'phone': phone});
}

// 小岛列表
Future<dynamic> getIslandList(Map<String, dynamic> data) {
  return api.post('/v1/island/myCreate', data: data);
}

// 创建小岛
Future<dynamic> createIsland(Map<String, dynamic> data) {
  return api.post('/v1/island/create', data: data);
}

// 获取小岛信息
Future<dynamic> getIslandInfo(dynamic id) {
  return api.post('/v1/island/info', data: {'id': id});
}

// 标记小岛
Future<dynamic> editIsland(Map<String, dynamic> data) {
  return api.post('/v1/island/editor', data: data);
}

// 获取个人主页小岛
Future<dynamic> getUserIsland(dynamic uid) {
  return api.post('/v1/user/islands', data: {'uid': uid});
}

// 解散小岛
Future<dynamic> deleteIsland(dynamic id) {
  return api.post('/v1/island/disband', data: {'id': id});
}

// 关注/取消关注个人
Future<dynamic> followUser(int uid) {
  return api.post('/v1/user/follow', data: {'uid': uid});
}

// 举报用户
Future<dynamic> reportUser(Map<String, dynamic> data) {
  return api.post('/v1/user/report', data: data);
}

// 获取关注列表
Future<dynamic> getFollowList(Map<String, dynamic> data) {
  return api.post('/v1/user/follow_list', data: data);
}

// 点赞动态
Future<dynamic> likePost(int id) {
  return api.post('/v1/island/post/like', data: {'id': id});
}

// 申请查看别人微信
Future<dynamic> applySeeWechat(Map<String, dynamic> data) {
  return api.post('/v1/balance/applyWechatOrder', data: data);
}

// 申请微信列表
Future<dynamic> applyWechatList(Map<String, dynamic> data) {
  return api.post('/v1/wechat/apply_list', data: data);
}

// 获取个人主页动态
Future<dynamic> getUserDynamics(dynamic uid) {
  return api.post('/v1/user/posts', data: {'uid': uid});
}

// 上传签名url
Future<dynamic> uploadSignature(String type, String contentType) {
  if (type.isEmpty) throw Exception('参数错误');
  final data = {'type': type, 'content_type': contentType};
  return api.post('/v1/file/upload', data: data, headers: getHeaders());
}

// 通用响应体
class ResponseBody<T> {
  final int code;
  final T data;
  final String msg;

  ResponseBody({required this.code, required this.data, required this.msg});

  factory ResponseBody.fromJson(
      Map<String, dynamic> json, T Function(dynamic) fromData) {
    return ResponseBody(
      code: json['code'] as int,
      data: fromData(json['data']),
      msg: json['msg'] as String,
    );
  }
}

// 分页
class Paging {
  final int page;
  final int rows;

  Paging({required this.page, required this.rows});

  factory Paging.fromJson(Map<String, dynamic> json) {
    return Paging(
      page: json['page'] as int,
      rows: json['rows'] as int,
    );
  }
}

// 用户信息
class UserInfo {
  final int uid;
  final String nick;
  final String? avatar;
  final List<String>? tags;
  final int loginTime;

  UserInfo({
    required this.uid,
    required this.nick,
    this.avatar,
    this.tags,
    required this.loginTime,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      uid: json['uid'] as int,
      nick: json['nick'] as String,
      avatar: json['avatar'] as String?,
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList(),
      loginTime: json['login_time'] as int,
    );
  }
}

// 小岛创建 DTO
class CreateIslandDto {
  final String name;
  final String bio;
  final List<String> cover;
  final int memberVisible;
  final String classify;
  final List<String> album;
  final int perm;
  final int memberPost;
  final int auditApplyFor;
  final int inviteMember;
  final num? vipPrice;
  final String? vipExpire;
  final String? vipBio;
  final int vipViewing;
  final int planArticle;
  final int planArticleComment;
  final int planPhoto;
  final int planPhotoOriginal;
  final int planPhotoWaterfall;
  final int planVideo;
  final int planVideoComment;
  final int planVideoDown;
  final int planWechat;
  final int planWechatFree;
  final int proxy;
  final String? proxyUid;
  final int proxyDividend;

  CreateIslandDto({
    required this.name,
    required this.bio,
    required this.cover,
    required this.memberVisible,
    required this.classify,
    required this.album,
    required this.perm,
    required this.memberPost,
    required this.auditApplyFor,
    required this.inviteMember,
    this.vipPrice,
    this.vipExpire,
    this.vipBio,
    required this.vipViewing,
    required this.planArticle,
    required this.planArticleComment,
    required this.planPhoto,
    required this.planPhotoOriginal,
    required this.planPhotoWaterfall,
    required this.planVideo,
    required this.planVideoComment,
    required this.planVideoDown,
    required this.planWechat,
    required this.planWechatFree,
    required this.proxy,
    this.proxyUid,
    required this.proxyDividend,
  });

  factory CreateIslandDto.fromJson(Map<String, dynamic> json) {
    return CreateIslandDto(
      name: json['name'],
      bio: json['bio'],
      cover: List<String>.from(json['cover'] ?? []),
      memberVisible: json['member_visible'],
      classify: json['classify'],
      album: List<String>.from(json['album'] ?? []),
      perm: json['perm'],
      memberPost: json['member_post'],
      auditApplyFor: json['audit_apply_for'],
      inviteMember: json['invite_member'],
      vipPrice: json['vip_price'],
      vipExpire: json['vip_expire'],
      vipBio: json['vip_bio'],
      vipViewing: json['vip_viewing'],
      planArticle: json['plan_article'],
      planArticleComment: json['plan_article_comment'],
      planPhoto: json['plan_photo'],
      planPhotoOriginal: json['plan_photo_original'],
      planPhotoWaterfall: json['plan_photo_waterfall'],
      planVideo: json['plan_video'],
      planVideoComment: json['plan_video_comment'],
      planVideoDown: json['plan_video_down'],
      planWechat: json['plan_wechat'],
      planWechatFree: json['plan_wechat_free'],
      proxy: json['proxy'],
      proxyUid: json['proxy_uid'],
      proxyDividend: json['proxy_dividend'],
    );
  }
}

// 你可以继续为其它接口定义类似的 DTO/实体类...
