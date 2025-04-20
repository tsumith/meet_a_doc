import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meet_a_doc/services/api_service.dart';
import 'package:meet_a_doc/views/patients_view/patient_dash.dart';

class PatientDetailsPage extends StatefulWidget {
  @override
  _PatientDetailsPageState createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers to store user health-related input
  final TextEditingController _diseasesController = TextEditingController();
  final TextEditingController _medicationsController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _familyHistoryController =
      TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _bloodTypeController = TextEditingController();
  final TextEditingController _surgicalHistoryController =
      TextEditingController();
  final TextEditingController _otherConditionsController =
      TextEditingController();

  void _submitForm() async {
    // Process the form data here
    await addPatientDetails(FirebaseAuth.instance.currentUser!.uid, {
      'diseases': _diseasesController.text,
      'medications': _medicationsController.text,
      'allergies': _allergiesController.text,
      'familyHistory': _familyHistoryController.text,
      'height': _heightController.text,
      'weight': _weightController.text,
      'bloodType': _bloodTypeController.text,
      'surgicalHistory': _surgicalHistoryController.text,
      'otherConditions': _otherConditionsController.text,
    }).then((onValue) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => PatientHomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("General Health Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Health Data Section
                Text("Health Data",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 16),

                // Diseases
                TextFormField(
                  controller: _diseasesController,
                  decoration: InputDecoration(labelText: 'Current Diseases'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please mention any current diseases';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Medications
                TextFormField(
                  controller: _medicationsController,
                  decoration: InputDecoration(labelText: 'Current Medications'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please list any current medications';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Allergies
                TextFormField(
                  controller: _allergiesController,
                  decoration: InputDecoration(labelText: 'Known Allergies'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please list any known allergies';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Family History
                TextFormField(
                  controller: _familyHistoryController,
                  decoration:
                      InputDecoration(labelText: 'Family Health History'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please provide family health history';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Height
                TextFormField(
                  controller: _heightController,
                  decoration: InputDecoration(labelText: 'Height (in cm)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your height';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Weight
                TextFormField(
                  controller: _weightController,
                  decoration: InputDecoration(labelText: 'Weight (in kg)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your weight';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Blood Type
                TextFormField(
                  controller: _bloodTypeController,
                  decoration: InputDecoration(labelText: 'Blood Type'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your blood type';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Surgical History
                TextFormField(
                  controller: _surgicalHistoryController,
                  decoration:
                      InputDecoration(labelText: 'Past Surgical History'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please provide your surgical history';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Other Health Conditions
                TextFormField(
                  controller: _otherConditionsController,
                  decoration:
                      InputDecoration(labelText: 'Other Health Conditions'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please mention any other health conditions';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Submit Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      // Form is valid, you can process the data

                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Submitting form...')));
                      _submitForm();
                    }
                  },
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _diseasesController.dispose();
    _medicationsController.dispose();
    _allergiesController.dispose();
    _familyHistoryController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _bloodTypeController.dispose();
    _surgicalHistoryController.dispose();
    _otherConditionsController.dispose();
    super.dispose();
  }
}
