import 'package:http/http.dart' as http;
import 'dart:convert';

//https://meet-a-doc-server.onrender.com
const uri = "https://meet-a-doc-server.onrender.com";
Future<void> registerPatient(Map<String, dynamic> data) async {
  final url = Uri.parse('$uri/patient/register'); // Use your actual backend URL
  final headers = {"Content-Type": "application/json"};
  final body = jsonEncode(data);

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 201) {
      print('patient saved successfully: ${response.body}');
    } else {
      print('Failed to save patient: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

Future<void> registerDoctor(Map<String, dynamic> data) async {
  final url = Uri.parse('$uri/doctor/register'); // Use your actual backend URL
  final headers = {"Content-Type": "application/json"};
  final body = jsonEncode(data);

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 201) {
      print('doctor saved successfully: ${response.body}');
    } else {
      print('Failed to save doctor: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

Future<void> addPatientDetails(String id, Map<String, dynamic> data) async {
  final url = Uri.parse(
      '$uri/patient/addPatientDetails'); // Use your actual backend URL
  final headers = {"Content-Type": "application/json"};
  final body = jsonEncode({'patientId': id, 'details': data});
  try {
    final response = await http.post(url, headers: headers, body: body);
  } catch (e) {
    print('Error: $e');
  }
}

Future<void> addPatientsToDoctor(String doctorId, String patientId) async {
  final url = Uri.parse(
      '$uri/doctor/addPatientToDoctor'); // Use your actual backend URL
  final headers = {"Content-Type": "application/json"};
  final body = jsonEncode({'doctorId': doctorId, 'patientId': patientId});
  try {
    final response = await http.post(url, headers: headers, body: body);
  } catch (e) {
    print('Error: $e');
  }
}

Future<String> getDoctorId(String patientId) async {
  final url =
      Uri.parse('$uri/patient/getDoctorId'); // Use your actual backend URL
  final headers = {"Content-Type": "application/json"};
  final body = jsonEncode({'patientId': patientId});
  try {
    final response = await http.post(url, headers: headers, body: body);
    final patientId = jsonDecode(response.body);
    return patientId['doctorId'];
  } catch (e) {
    print('Error: $e');
  }
  return '';
}

Future<List<dynamic>> getChats(String patientId) async {
  final url = Uri.parse('$uri/chat/getChats'); // Use your actual backend URL
  final headers = {"Content-Type": "application/json"};
  final body = jsonEncode({'patientId': patientId});
  try {
    final response = await http.post(url, headers: headers, body: body);
    final chats = jsonDecode(response.body);
    return chats['chats'];
  } catch (e) {
    print('Error: $e');
  }
  return [];
}

Future<List<Map<String, dynamic>>> getReports(String doctorId) async {
  final url = Uri.parse(
      '$uri/doctor/getChats/:$doctorId'); // Use your actual backend URL
  final headers = {"Content-Type": "application/json"};

  try {
    final response = await http.get(url, headers: headers);
    final reports = jsonDecode(response.body);
    print(reports);
    return List<Map<String, dynamic>>.from(reports['chats']);
  } catch (e) {
    print('Error: $e');
  }
  return [];
}

Future<List<Map<String, dynamic>>> getReportsforPatient(
    String doctorId, String patientId) async {
  final url = Uri.parse(
      '$uri/doctor/getChatsforPatient'); // Use your actual backend URL
  final headers = {"Content-Type": "application/json"};

  try {
    final response = await http.post(url,
        headers: headers,
        body: jsonEncode({'doctorId': doctorId, 'patientId': patientId}));
    final reports = jsonDecode(response.body);
    print(reports);
    return List<Map<String, dynamic>>.from(reports['chats']);
  } catch (e) {
    print('Error: $e');
  }
  return [];
}

Future<Map<String, dynamic>> getPatientDetails(String id) async {
  final url = Uri.parse('$uri/patient/getDetails/:$id');
  final headers = {"Content-Type": "application/json"};
  try {
    final response = await http.get(url, headers: headers);
    print(response);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load patient details');
    }
  } catch (e) {
    print(e.toString());
  }
  return {};
}

Future<void> createAppointsment(String doctorId, String patientId) async {
  final url = Uri.parse('$uri/appointment/create');
  final headers = {"Content-Type": "application/json"};
  final body = jsonEncode({
    'doctorId': doctorId,
    'patientId': patientId,
  });
  try {
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      print('Appointment created successfully: ${response.body}');
    } else {
      print('Failed to create appointment: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

Future<List<Map<String, dynamic>>> getAppointsmentsForPatients(
    String patientId) async {
  final url = Uri.parse(
      '$uri/appointment/getAppointmentsForPatient'); // Use your actual backend URL
  final headers = {"Content-Type": "application/json"};
  final body = jsonEncode({
    'patientId': patientId,
  });
  print("called ....");
  try {
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load appointments');
    }
  } catch (e) {
    print(e.toString());
  }
  return [];
}

Future<List<Map<String, dynamic>>> getAppointsmentsForDoctors(
    String doctorId) async {
  final url = Uri.parse(
      '$uri/appointment/getAppointmentsForDoctor'); // Use your actual backend URL
  final headers = {"Content-Type": "application/json"};
  final body = jsonEncode({
    'doctorId': doctorId,
  });
  try {
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load appointments');
    }
  } catch (e) {
    print(e.toString());
  }
  return [];
}

Future<Map<String, dynamic>> getPatientName(String id) async {
  final url = Uri.parse('$uri/patient/getPatientName/:$id');
  final headers = {"Content-Type": "application/json"};
  try {
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load patient name');
    }
  } catch (e) {
    print(e.toString());
  }
  return {};
}

Future<void> setDatetoAppointment(Map<String, dynamic> appointment) async {
  print("-----------------working-------------");
  final url = Uri.parse('$uri/appointment/setDate');
  final headers = {"Content-Type": "application/json"};
  final body = jsonEncode({
    'id': appointment['_id'],
    'date': appointment['date'].toIso8601String()
  });
  try {
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      print('Date set successfully: ${response.body}');
    } else {
      print('Failed to set date: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
