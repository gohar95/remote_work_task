import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:trailapp/models/record_model.dart';
import 'package:trailapp/logic/crud_bloc.dart';
import 'package:animate_do/animate_do.dart';

class CrudEntryScreen extends StatefulWidget {
  final RecordModel? record;
  const CrudEntryScreen({super.key, this.record});

  @override
  State<CrudEntryScreen> createState() => _CrudEntryScreenState();
}

class _CrudEntryScreenState extends State<CrudEntryScreen> {
  late TextEditingController _titleController;
  File? _selectedImage;
  File? _selectedPdf;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.record != null;
    _titleController = TextEditingController(text: widget.record?.title ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    
    // Show premium selection dialog
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      elevation: 10,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 20),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Upload Image',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSourceOption(
                    context,
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    color: Colors.blue[600]!,
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                  _buildSourceOption(
                    context,
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    color: Colors.green[600]!,
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );


    if (source != null) {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path); // Always replaces existing (single selection)
        });
      }
    }
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false, // Explicitly set to single selection
    );
    if (result != null && result.files.isNotEmpty && result.files.single.path != null) {
      setState(() {
        _selectedPdf = File(result.files.single.path!); // Always replaces existing (single selection)
      });
    }
  }


  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    if (_isEditing) {
      context.read<CrudBloc>().add(UpdateRecord(
            id: widget.record!.id,
            title: title,
            image: _selectedImage,
            pdf: _selectedPdf,
            existingImageUrl: widget.record!.imageUrl,
            existingPdfUrl: widget.record!.pdfUrl,
          ));
    } else {
      context.read<CrudBloc>().add(AddRecord(
            title: title,
            image: _selectedImage,
            pdf: _selectedPdf,
          ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Record' : 'Add New Record'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FadeInDown(
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter a name for this record',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.title),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Image Picker Section
            FadeInLeft(
              delay: const Duration(milliseconds: 100),
              child: _buildFilePickerCard(
                title: 'Record Image',
                icon: Icons.image,
                subtitle: _selectedImage != null 
                    ? 'Selected: ${_selectedImage!.path.split('/').last}'
                    : widget.record?.imageUrl != null 
                        ? 'Keep existing image'
                        : 'No image selected',
                onTap: _pickImage,
                preview: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_selectedImage!, height: 100, fit: BoxFit.cover),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            // PDF Picker Section
            FadeInLeft(
              delay: const Duration(milliseconds: 200),
              child: _buildFilePickerCard(
                title: 'Record PDF',
                icon: Icons.picture_as_pdf,
                subtitle: _selectedPdf != null
                    ? 'Selected: ${_selectedPdf!.path.split('/').last}'
                    : widget.record?.pdfUrl != null
                        ? 'Keep existing PDF'
                        : 'No PDF selected',
                onTap: _pickPdf,
                preview: _selectedPdf != null
                    ? const Icon(Icons.check_circle, color: Colors.green, size: 40)
                    : null,
              ),
            ),
            const SizedBox(height: 48),

            // Submit Button
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  _isEditing ? 'Update Record' : 'Save Record',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePickerCard({
    required String title,
    required IconData icon,
    required String subtitle,
    required VoidCallback onTap,
    Widget? preview,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
              if (preview != null) preview,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

