import 'dart:io';
import 'package:trailapp/models/record_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class CrudRepository {
  final _client = Supabase.instance.client;

  Future<List<RecordModel>> getRecords() async {
    final response = await _client
        .from('user_records')
        .select()
        .order('created_at', ascending: false);
    return (response as List).map((json) => RecordModel.fromJson(json)).toList();
  }

  Future<void> addRecord({
    required String title,
    File? image,
    File? pdf,
  }) async {
    final userId = _client.auth.currentUser!.id;
    String? imageUrl;
    String? pdfUrl;

    if (image != null) {
      final imageExtension = image.path.split('.').last;
      final imagePath = 'images/${const Uuid().v4()}.$imageExtension';
      await _client.storage.from('files').upload(imagePath, image);
      imageUrl = _client.storage.from('files').getPublicUrl(imagePath);
    }

    if (pdf != null) {
      final pdfExtension = pdf.path.split('.').last;
      final pdfPath = 'pdfs/${const Uuid().v4()}.$pdfExtension';
      await _client.storage.from('files').upload(pdfPath, pdf);
      pdfUrl = _client.storage.from('files').getPublicUrl(pdfPath);
    }

    await _client.from('user_records').insert({
      'user_id': userId,
      'title': title,
      'image_url': imageUrl,
      'pdf_url': pdfUrl,
    });
  }

  Future<void> updateRecord({
    required String id,
    required String title,
    File? image,
    File? pdf,
    String? existingImageUrl,
    String? existingPdfUrl,
  }) async {
    String? imageUrl = existingImageUrl;
    String? pdfUrl = existingPdfUrl;

    if (image != null) {
      // Upload new image
      final imageExtension = image.path.split('.').last;
      final imagePath = 'images/${const Uuid().v4()}.$imageExtension';
      await _client.storage.from('files').upload(imagePath, image);
      imageUrl = _client.storage.from('files').getPublicUrl(imagePath);
      
      // Optionally delete old image from storage if it exists
      if (existingImageUrl != null) {
        try {
          final oldPath = existingImageUrl.split('files/').last;
          await _client.storage.from('files').remove([oldPath]);
        } catch (_) {}
      }
    }

    if (pdf != null) {
      // Upload new PDF
      final pdfExtension = pdf.path.split('.').last;
      final pdfPath = 'pdfs/${const Uuid().v4()}.$pdfExtension';
      await _client.storage.from('files').upload(pdfPath, pdf);
      pdfUrl = _client.storage.from('files').getPublicUrl(pdfPath);
      
      // Optionally delete old PDF from storage if it exists
      if (existingPdfUrl != null) {
        try {
          final oldPath = existingPdfUrl.split('files/').last;
          await _client.storage.from('files').remove([oldPath]);
        } catch (_) {}
      }
    }

    await _client.from('user_records').update({
      'title': title,
      'image_url': imageUrl,
      'pdf_url': pdfUrl,
    }).eq('id', id);
  }

  Future<void> deleteRecord(RecordModel record) async {
    // Delete from database
    await _client.from('user_records').delete().eq('id', record.id);

    // Delete files from storage
    final List<String> pathsToDelete = [];
    if (record.imageUrl != null) {
      pathsToDelete.add(record.imageUrl!.split('files/').last);
    }
    if (record.pdfUrl != null) {
      pathsToDelete.add(record.pdfUrl!.split('files/').last);
    }

    if (pathsToDelete.isNotEmpty) {
      await _client.storage.from('files').remove(pathsToDelete);
    }
  }
}
