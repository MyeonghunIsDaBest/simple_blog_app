import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../main.dart';
import '../models/blog_model.dart';

const String _blogSelect = '''
  *,
  profiles:user_id (
    id,
    email,
    display_name,
    avatar_url
  )
''';

const String _commentSelect = '''
  *,
  profiles:user_id (
    id,
    email,
    display_name,
    avatar_url
  )
''';

class BlogService {
  static const int pageSize = 10;

  Future<List<BlogModel>> getBlogs({int page = 0}) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;

    final data = await supabase
        .from('blogs')
        .select(_blogSelect)
        .order('created_at', ascending: false)
        .range(from, to);

    final blogList = (data as List)
        .map((e) => BlogModel.fromJson(e as Map<String, dynamic>))
        .toList();

    for (int i = 0; i < blogList.length; i++) {
      final count = await _getCommentCount(blogList[i].id);
      blogList[i] = blogList[i].copyWith(commentCount: count);
    }

    return blogList;
  }

  Future<BlogModel?> getBlogById(String id) async {
    try {
      final data = await supabase
          .from('blogs')
          .select(_blogSelect)
          .eq('id', id)
          .single();

      final blog = BlogModel.fromJson(data);
      final count = await _getCommentCount(id);
      return blog.copyWith(commentCount: count);
    } catch (e) {
      return null;
    }
  }

  Future<BlogModel> createBlog({
    required String userId,
    required String title,
    required String content,
    File? imageFile,
  }) async {
    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await _uploadImage('blog-images', imageFile);
    }

    final data = await supabase
        .from('blogs')
        .insert({
          'user_id': userId,
          'title': title,
          'content': content,
          'image_url': imageUrl,
        })
        .select(_blogSelect)
        .single();

    return BlogModel.fromJson(data);
  }

  Future<BlogModel> updateBlog({
    required String id,
    required String title,
    required String content,
    File? imageFile,
    String? existingImageUrl,
  }) async {
    String? imageUrl = existingImageUrl;
    if (imageFile != null) {
      imageUrl = await _uploadImage('blog-images', imageFile);
    }

    final data = await supabase
        .from('blogs')
        .update({
          'title': title,
          'content': content,
          'image_url': imageUrl,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select(_blogSelect)
        .single();

    return BlogModel.fromJson(data);
  }

  Future<void> deleteBlog(String id) async {
    await supabase.from('blogs').delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> getComments(String blogId) async {
    final data = await supabase
        .from('comments')
        .select(_commentSelect)
        .eq('blog_id', blogId)
        .order('created_at', ascending: true);

    return (data as List).map((e) => e as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>> createComment({
    required String blogId,
    required String userId,
    required String content,
    File? imageFile,
  }) async {
    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await _uploadImage('comment-images', imageFile);
    }

    final data = await supabase
        .from('comments')
        .insert({
          'blog_id': blogId,
          'user_id': userId,
          'content': content,
          'image_url': imageUrl,
        })
        .select(_commentSelect)
        .single();

    return data as Map<String, dynamic>;
  }

  Future<void> deleteComment(String id) async {
    await supabase.from('comments').delete().eq('id', id);
  }

  Future<List<BlogModel>> searchBlogs(String query) async {
    final data = await supabase
        .from('blogs')
        .select(_blogSelect)
        .or('title.ilike.%$query%,content.ilike.%$query%')
        .order('created_at', ascending: false)
        .limit(20);

    return (data as List)
        .map((e) => BlogModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Private helpers

  Future<int> _getCommentCount(String blogId) async {
    final data =
        await supabase.from('comments').select('id').eq('blog_id', blogId);
    return (data as List).length;
  }

  Future<String> _uploadImage(String bucket, File imageFile) async {
    final ext = p.extension(imageFile.path);
    final fileName = '${const Uuid().v4()}$ext';

    await supabase.storage.from(bucket).upload(
          fileName,
          imageFile,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );

    return supabase.storage.from(bucket).getPublicUrl(fileName);
  }
}
