void main() {
  bool isNewStudent = true;

  // Two student lists
  List<String> studentList1 = ["Tonmoy", "Sakib", "Rahat"];
  List<String> studentList2 = ["Nafis"];

  // Combine lists using Spread Operator
  List<String> students = [
    ...studentList1,
    ...studentList2,
    if (isNewStudent) "Rahim"
  ];

  // Set of enrolled courses
  Set<String> courses = {"Flutter", "Dart", "Git"};

  // Map of student ages
  Map<String, int> studentAges = {
    "Tonmoy": 22,
    "Sakib": 23,
    "Rahat": 21,
    "Nafis": 24,
    "Rahim": 20,
  };

  print("Students:");
  print(students);

  print("\nCourses:");
  print(courses);

  print("\nStudent Ages:");
  studentAges.forEach((name, age) {
    print("$name -> $age");
  });
}