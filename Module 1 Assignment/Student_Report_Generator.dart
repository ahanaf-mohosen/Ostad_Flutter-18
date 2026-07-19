void main() {
  String studentName = "Rahim";
  int marks = 75;
  String grade;

  // Determine grade using if-else
  if (marks >= 80) {
    grade = "A";
  } else if (marks >= 70) {
    grade = "B";
  } else if (marks >= 60) {
    grade = "C";
  } else {
    grade = "F";
  }

  // Print report
  print("Student Report\n");
  print("Name: $studentName");
  print("Marks: $marks");
  print("Grade: $grade\n");

  // Grade description using switch-case
  switch (grade) {
    case "A":
      print("Excellent");
      break;
    case "B":
      print("Good Job");
      break;
    case "C":
      print("Needs Improvement");
      break;
    case "F":
      print("Failed");
      break;
    default:
      print("Invalid Grade");
  }
}