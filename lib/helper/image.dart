import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

final ImagePicker _picker = ImagePicker();

class ImageHelper {
  Future<Map<String, dynamic>?> selectImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      return {"data": await image.readAsBytes(), "file": image};
    }

    return null;
  }
}
