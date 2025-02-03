// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyAPJpeO2iKyrq5jZw7GL15PP11RSKNZpuY',
      appId: '1:848131969900:android:d021939595743edb331949',
      messagingSenderId: '848131969900',
      projectId: 'fir-project-6f5c7',
    ),
  );

  runApp(const MaterialApp(home: FirstPage()));
}

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final TextEditingController studentIDController = TextEditingController();
  final TextEditingController studentNameController = TextEditingController();
  final TextEditingController studentStageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Database',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Manage Students',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: studentIDController,
              hint: 'Student ID',
              icon: Icons.perm_identity,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: studentNameController,
              hint: 'Student Name',
              icon: Icons.person,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: studentStageController,
              hint: 'Student Stage',
              icon: Icons.school,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton('Insert', Colors.green, insertData),
                _buildActionButton('Select', Colors.blue, selectData),
                _buildActionButton('Update', Colors.orange, updateData),
                _buildActionButton('Delete', Colors.red, deleteData),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("StudentCollection")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No data found.'));
                    }
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot documentSnapshot =
                            snapshot.data!.docs[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Text(
                                documentSnapshot['studentID']
                                    .toString()
                                    .substring(0, 1),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              documentSnapshot['studentName'],
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                                'Stage: ${documentSnapshot['studentStage']}'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  void insertData() {
    FirebaseFirestore.instance
        .collection('StudentCollection')
        .doc(studentNameController.text.trim())
        .set({
      "studentID": studentIDController.text.trim(),
      "studentName": studentNameController.text.trim(),
      "studentStage": studentStageController.text.trim(),
    });
    clearFields();
  }

  void selectData() {
    FirebaseFirestore.instance
        .collection('StudentCollection')
        .doc(studentNameController.text.trim())
        .get()
        .then((document) {
      if (document.exists) {
        studentIDController.text = document['studentID'];
        studentStageController.text = document['studentStage'];
      }
    });
  }

  void updateData() {
    FirebaseFirestore.instance
        .collection('StudentCollection')
        .doc(studentNameController.text.trim())
        .update({
      "studentID": studentIDController.text.trim(),
      "studentStage": studentStageController.text.trim(),
    });
    clearFields();
  }

  void deleteData() {
    FirebaseFirestore.instance
        .collection('StudentCollection')
        .doc(studentNameController.text.trim())
        .delete();
    clearFields();
  }

  void clearFields() {
    studentIDController.clear();
    studentNameController.clear();
    studentStageController.clear();
  }
}
