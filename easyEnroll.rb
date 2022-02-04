require "csv";
require "./student";

# Read in the preferences from prefs.csv
students = []
CSV.foreach("./input-files/prefs.csv") { |row| 
  addedStudent = Student.new(row)
  students.push(addedStudent)
}

students.each { |student|
  puts "#{student.student_id}, #{student.student_year}, #{student.courses_taken}, #{student.semesters_left}, #{student.num_prefs}, #{student.prefs}"
}