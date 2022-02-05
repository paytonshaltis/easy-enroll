require "csv";
require "./student";

# Read in the preferences from prefs.csv
students = []
CSV.foreach("./input-files/prefs.csv") { |row|
  addedStudent = Student.new(row)
  students.push(addedStudent)
}

students[19].enroll(["CSC 325", "CSC 335", "CSC 415"])

students.each { |student|
  puts "Priority: #{student.priority}, Overenrolled: #{student.overenrolled}, Enrolled: #{students[19].enrolled_courses}, #{student.student_id}, #{student.student_year}, #{student.courses_taken}, #{student.semesters_left}, #{student.num_requests}, #{student.prefs}"
}

# students[9].enrolled_courses.push("CSC 360", "CSC 415", "CSC 325")
# students[9].reasons.push("The class was filled up.", "I'm not sure.", "Another one.", "A reason.")
# students[0].enrolled_courses.push("CSC 415")
# students[19].reasons.push("We aren't sure.")
# students[19].enroll("CSC 425")
# students[19].enroll(["CSC 325", "CSC 335", "CSC 415"])

students.each { |student| 
  puts student
}

puts Student.overenrollments
puts students[19].unenroll("CSC 335")
puts "Priority: #{students[19].priority}, Overenrolled: #{students[19].overenrolled}, Enrolled: #{students[19].enrolled_courses}, #{students[19].student_id}, #{students[19].student_year}, #{students[19].courses_taken}, #{students[19].semesters_left}, #{students[19].num_requests}, #{students[19].prefs}"
puts Student.overenrollments
puts students[19].unenroll("CSC 325")
puts "Priority: #{students[19].priority}, Overenrolled: #{students[19].overenrolled}, Enrolled: #{students[19].enrolled_courses}, #{students[19].student_id}, #{students[19].student_year}, #{students[19].courses_taken}, #{students[19].semesters_left}, #{students[19].num_requests}, #{students[19].prefs}"
puts Student.overenrollments
puts students[19].unenroll("CSC 415")
puts "Priority: #{students[19].priority}, Overenrolled: #{students[19].overenrolled}, Enrolled: #{students[19].enrolled_courses}, #{students[19].student_id}, #{students[19].student_year}, #{students[19].courses_taken}, #{students[19].semesters_left}, #{students[19].num_requests}, #{students[19].prefs}"
puts Student.overenrollments