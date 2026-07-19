import 'dart:io';

// Abstract Class
abstract class Person {
  void displayInfo();
}

// Student Class
class Student extends Person {
  // Encapsulation (Private Fields)
  String _id;
  String _name;
  int _age;

  // Constructor
  Student(this._id, this._name, this._age);

  // Getters
  String get id => _id;
  String get name => _name;
  int get age => _age;

  // Arrow Function
  String get studentInfo => "$_id | $_name | Age: $_age";

  @override
  void displayInfo() {
    print(studentInfo);
  }
}

// Student List
List<Student> students = [];

// Add Student
void addStudent() {
  stdout.write("Enter Student ID: ");
  String id = stdin.readLineSync()!;

  stdout.write("Enter Student Name: ");
  String name = stdin.readLineSync()!;

  stdout.write("Enter Student Age: ");
  int age = int.parse(stdin.readLineSync()!);

  students.add(Student(id, name, age));

  print("\nStudent Added Successfully!\n");
}

// View Students
void viewStudents() {
  if (students.isEmpty) {
    print("\nNo students found.\n");
    return;
  }

  print("\n===== Student List =====");

  // Anonymous Function
  students.forEach((student) {
    student.displayInfo();
  });

  print("");
}

// Search Student
void searchStudent() {
  stdout.write("Enter Student ID: ");
  String id = stdin.readLineSync()!;

  Student? found;

  for (var student in students) {
    if (student.id == id) {
      found = student;
      break;
    }
  }

  if (found != null) {
    print("\nStudent Found:");
    found.displayInfo();
  } else {
    print("\nStudent Not Found.");
  }

  print("");
}

// Delete Student
void deleteStudent() {
  stdout.write("Enter Student ID to Delete: ");
  String id = stdin.readLineSync()!;

  int before = students.length;

  students.removeWhere((student) => student.id == id);

  if (students.length < before) {
    print("\nStudent Deleted Successfully.");
  } else {
    print("\nStudent Not Found.");
  }

  print("");
}

// Main Function
void main() {
  while (true) {
    print("===== Student Information Manager =====");
    print("1. Add Student");
    print("2. View Students");
    print("3. Search Student");
    print("4. Delete Student");
    print("5. Exit");

    stdout.write("\nEnter your choice: ");
    String? choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        addStudent();
        break;

      case '2':
        viewStudents();
        break;

      case '3':
        searchStudent();
        break;

      case '4':
        deleteStudent();
        break;

      case '5':
        print("\nThank you!");
        return;

      default:
        print("\nInvalid Choice!\n");
    }
  }
}