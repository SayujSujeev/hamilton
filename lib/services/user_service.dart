import 'api_client.dart';
import '../models/user_model.dart';
import '../models/vehicle_model.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  /// Get the current user profile
  Future<UserModel> getCurrentUser() async {
    return await _apiClient.handleAuthErrors(() async {
      return await _apiClient.getCurrentUserModel();
    });
  }

  /// Update the current user profile
  /// Accepted fields: firstname, lastname, gender, dob, image_url,
  ///                  mobile_no, whatsapp_no, note, address
  Future<UserModel> updateUserProfile({
    String? firstname,
    String? lastname,
    String? gender,
    String? dob,
    String? imageUrl,
    String? mobileNo,
    String? whatsappNo,
    String? note,
    String? address,
  }) async {
    final data = <String, dynamic>{};
    
    if (firstname != null) data['firstname'] = firstname;
    if (lastname != null) data['lastname'] = lastname;
    if (gender != null) data['gender'] = gender;
    if (dob != null) data['dob'] = dob;
    if (imageUrl != null) data['image_url'] = imageUrl;
    if (mobileNo != null) data['mobile_no'] = mobileNo;
    if (whatsappNo != null) data['whatsapp_no'] = whatsappNo;
    if (note != null) data['note'] = note;
    if (address != null) data['address'] = address;

    return await _apiClient.handleAuthErrors(() async {
      return await _apiClient.updateCurrentUserModel(data);
    });
  }

  /// Get all vehicles for the current user
  Future<List<VehicleModel>> getUserVehicles() async {
    return await _apiClient.handleAuthErrors(() async {
      return await _apiClient.getUserVehicles();
    });
  }
}
