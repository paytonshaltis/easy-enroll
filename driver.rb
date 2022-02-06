require "csv"
require "./student"
require "./course"

def main()
  courses = []
  courses_hash = {}
  students = []
  dropped_courses = []

  # Read in the course info from constraints.csv
  CSV.foreach("./input-files/constraints.csv") { |row|
    
    # Add the course to the course list.
    addedCourse = Course.new(row)
    courses.push(addedCourse)

    # Add the course to the course hash.
    courses_hash[addedCourse.course_number()] = addedCourse
  }

  # Read in the preferences from prefs.csv
  CSV.foreach("./input-files/prefs.csv") { |row|
    
    # Create the Student object.
    addedStudent = Student.new(row)

    # Enroll the student in all of their preferences.
    addedStudent.enroll(addedStudent.prefs, courses_hash)

    # Add the student to the array of students.
    students.push(addedStudent)
  }

  # Drop sections first as needed.
  courses.each { |course|

    # True if all sections of a course are dropped.
    if course.drop_sections()
      
      puts "Dropping all sections of #{course.course_number()}..."

      # Drop this course for all students.
      course.drop_all_students(courses_hash)

      # Delete the course from the array and hash.
      dropped_courses.push(course)
    end
  }

  # Remove the dropped courses from the array and hash.
  dropped_courses.each { |course|
    courses.delete(course)
    courses_hash.delete(course)
  }

# Need to unenroll students until total overenrollments is 0.
# while Student.overenrollments() > 0
  # Try unenrolling students from courses where min < max < C

  # Try unenrolling students from courses where min < C < max

  # Try unenrolling students from courses where C < min < max (sort by max num_overenrolled)
# end

# Need to kick students from any classes above their total max.
# courses.each { |course| 
#   while course.enrolled_students().size() > course.total_max()
#     # Kick the lowest priority student from the class
#   end
# }

# Need to drop sections for courses below their total mins.
#
#
#
#
#
#

# Write to the output files.

  # Print all of the students in each course.
  courses.each { |course|
    puts "#{course.course_number()}, #{course.num_overenrolled()} overenrolled:"
    course.enrolled_students.each { |student|
      puts student.student_id
    }
  }


  students.each { |student|
    puts "Priority: #{student.priority}, Overenrolled: #{student.overenrolled}, Enrolled: #{student.enrolled_courses}, #{student.student_id}, #{student.student_year}, #{student.courses_taken}, #{student.semesters_left}, #{student.num_requests}, #{student.prefs}"
  }

  puts Student.overenrollments
  students.each { |s|
    puts s
  }

  students[19].unenroll("CSC 315", courses_hash)

  # Print all of the students in each course.
  courses.each { |course|
    puts "#{course.course_number()}, #{course.num_overenrolled()} overenrolled:"
    course.enrolled_students.each { |student|
      puts student.student_id
    }
  }


  students.each { |student|
    puts "Priority: #{student.priority}, Overenrolled: #{student.overenrolled}, Enrolled: #{student.enrolled_courses}, #{student.student_id}, #{student.student_year}, #{student.courses_taken}, #{student.semesters_left}, #{student.num_requests}, #{student.prefs}"
  }

  puts Student.overenrollments
  students.each { |s|
    puts s
  }

  students[19].unenroll("CSC 355", courses_hash)

  # Print all of the students in each course.
  courses.each { |course|
    puts "#{course.course_number()}, #{course.num_overenrolled()} overenrolled:"
    course.enrolled_students.each { |student|
      puts student.student_id
    }
  }


  students.each { |student|
    puts "Priority: #{student.priority}, Overenrolled: #{student.overenrolled}, Enrolled: #{student.enrolled_courses}, #{student.student_id}, #{student.student_year}, #{student.courses_taken}, #{student.semesters_left}, #{student.num_requests}, #{student.prefs}"
  }

  puts Student.overenrollments
  students.each { |s|
    puts s
  }



end

main()