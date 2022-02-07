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

  # Print all of the students in each course.
  courses.each { |course|
    puts "  >> #{course.course_number()}, #{course.enrolled_students().size()} total, #{course.total_min} total min, #{course.total_max} total max, #{course.num_overenrolled_students()} overenrolled, "
  }

  # For each course that is over its total max.
  puts "#{Student.overenrollments(students)} overenrollments."
  courses.each { |course|
    if (course.enrolled_students.size() > course.total_max())

      # Determine the max number of successful unenrollments allowed.
      max_unenrollments = course.enrolled_students.size() - course.total_max()
      puts "#{course.course_number}: #{course.enrolled_students.size()} students is GREATER than #{course.total_max} total max."
      puts "Unenrolling a max of #{max_unenrollments}..."

      # Determine which students will be unenrolled.
      unenrolling = []
      course.enrolled_students().each { |student|
        if student.overenrolled()
          unenrolling.push(student)
          max_unenrollments -= 1
        end
        if max_unenrollments == 0
          break
        end
      }

      # Remove these students now.
      unenrolling.each { |student|
        student.unenroll(course.course_number, courses_hash)
        puts "#{student.student_id} was UNENROLLED from #{course.course_number}."
      }
      puts "  >> #{course.course_number()}, #{course.enrolled_students().size()} total, #{course.total_min} total min, #{course.total_max} total max, #{course.num_overenrolled_students()} overenrolled, "

    end
  }


  # For each course that is over its total min.
  puts "#{Student.overenrollments(students)} overenrollments."
  courses.each { |course|
    if (course.enrolled_students.size() > course.total_min())
    
      # Determine the max number of successful unenrollments allowed.
      max_unenrollments = course.enrolled_students.size() - course.total_min()
      puts "#{course.course_number}: #{course.enrolled_students.size()} students is GREATER than #{course.total_min} total min."
      puts "Unenrolling a max of #{max_unenrollments}..."

      # Determine which students will be unenrolled.
      unenrolling = []
      course.enrolled_students().each { |student|
        if student.overenrolled()
          unenrolling.push(student)
          max_unenrollments -= 1
        end
        if max_unenrollments == 0
          break
        end
      }
      
      # Removing these students now.
      unenrolling.each { |student|
        student.unenroll(course.course_number, courses_hash)
        puts "#{student.student_id} was UNENROLLED from #{course.course_number}."
      }
      puts "  >> #{course.course_number()}, #{course.enrolled_students().size()} total, #{course.total_min} total min, #{course.total_max} total max, #{course.num_overenrolled_students()} overenrolled, "


    end
  }

  puts "SO FAR:"
  # Print all of the students in each course.
  courses.each { |course|
    puts "  >> #{course.course_number()}, #{course.enrolled_students().size()} total, #{course.total_min} total min, #{course.total_max} total max, #{course.num_overenrolled_students()} overenrolled, "
  }

  # For each course that is below its total min.
  puts "#{Student.overenrollments(students)} overenrollments."
  courses.each { |course|
    
  }

  # Print each student's enrollments
  students.each { |student|
    puts "Priority: #{student.priority}, Overenrolled: #{student.overenrolled}, Enrolled: #{student.enrolled_courses}, #{student.student_id}, #{student.student_year}, #{student.courses_taken}, #{student.semesters_left}, #{student.num_requests}, #{student.prefs}"
  }

# Need to unenroll students until total overenrollments is 0.
# while Student.overenrollments() > 0
  # Try unenrolling students from courses where min < max < C

  # Try unenrolling students from courses where min < C < max

  # Try unenrolling students from courses where C < min < max (sort by max num_overenrolled_students)
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

# Deal with students removed from classes AFTER unenrollment

# Write to the output files.

#   # Drop sections first as needed.
#   courses.each { |course|

#     # True if all sections of a course are dropped.
#     if course.drop_sections()
      
#       puts "Dropping all sections of #{course.course_number()}..."

#       # Drop this course for all students.
#       course.drop_all_students(courses_hash)

#       # Delete the course from the array and hash.
#       dropped_courses.push(course)
#     end
#   }

#   # Remove the dropped courses from the array and hash.
#   dropped_courses.each { |course|
#     courses.delete(course)
#     courses_hash.delete(course)
#   }


  # students.each { |student|
  #   puts "Priority: #{student.priority}, Overenrolled: #{student.overenrolled}, Enrolled: #{student.enrolled_courses}, #{student.student_id}, #{student.student_year}, #{student.courses_taken}, #{student.semesters_left}, #{student.num_requests}, #{student.prefs}"
  # }

  # puts Student.overenrollments(students)

  # students[19].unenroll("CSC 315", courses_hash)

  # # Print all of the students in each course.
  # courses.each { |course|
  #   puts "#{course.course_number()}, #{course.enrolled_students().size()} total, #{course.total_min} total min, #{course.total_max} total max, #{course.num_overenrolled_students()} overenrolled, "
  #   course.enrolled_students.each { |student|
  #     puts student.student_id
  #   }
  # }


  # students.each { |student|
  #   puts "Priority: #{student.priority}, Overenrolled: #{student.overenrolled}, Enrolled: #{student.enrolled_courses}, #{student.student_id}, #{student.student_year}, #{student.courses_taken}, #{student.semesters_left}, #{student.num_requests}, #{student.prefs}"
  # }

  # puts Student.overenrollments(students)

  # students[19].unenroll("CSC 355", courses_hash)

  # # Print all of the students in each course.
  # courses.each { |course|
  #   puts "#{course.course_number()}, #{course.num_overenrolled_students()} overenrolled:"
  #   course.enrolled_students.each { |student|
  #     puts student.student_id
  #   }
  # }


  # students.each { |student|
  #   puts "Priority: #{student.priority}, Overenrolled: #{student.overenrolled}, Enrolled: #{student.enrolled_courses}, #{student.student_id}, #{student.student_year}, #{student.courses_taken}, #{student.semesters_left}, #{student.num_requests}, #{student.prefs}"
  # }

  # puts Student.overenrollments(students)

  # students[19].unenroll("CSC 325", courses_hash)

  # # Print all of the students in each course.
  # courses.each { |course|
  #   puts "#{course.course_number()}, #{course.num_overenrolled_students()} overenrolled:"
  #   course.enrolled_students.each { |student|
  #     puts student.student_id
  #   }
  # }


  # students.each { |student|
  #   puts "Priority: #{student.priority}, Overenrolled: #{student.overenrolled}, Enrolled: #{student.enrolled_courses}, #{student.student_id}, #{student.student_year}, #{student.courses_taken}, #{student.semesters_left}, #{student.num_requests}, #{student.prefs}"
  # }


end

main()