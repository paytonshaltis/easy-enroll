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
    if course.enrolled_students.size() > course.total_max()

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
    if course.enrolled_students.size() > course.total_min()
    
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

  # For each course that is below its total min.
  puts "#{Student.overenrollments(students)} overenrollments."
  courses.each { |course|

    # Start with courses already below their minimum.
    while course.enrolled_students.size() < course.total_min()
      
      # Get rid of sections until they can all be filled
      puts "#{course.course_number}: #{course.enrolled_students.size} students, #{course.total_min} total min. Deleting a section..."
      course.curr_num_sections -= 1
    end
    
    # Now, unenroll as many as possible above the minimum.
    if course.enrolled_students.size() > course.total_min()
    
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

  # For each course that is at its total min.
  until Student.overenrollments(students) == 0
  
    # Determine the course with the greatest (overenrollemnts:min) ratio.
    selected_course = nil
    courses.each { |course|
      if ((not selected_course) || (course.num_overenrolled_students().to_f / course.min()) > (selected_course.num_overenrolled_students().to_f / selected_course.min()))
        selected_course = course
        puts "Selected #{selected_course.course_number()} with #{course.num_overenrolled_students().to_f / course.min()} to unenroll from."
      end
    }
    
    # Get rid of a section of this course
    selected_course.curr_num_sections -= 1
    puts "#{selected_course.course_number} was selected. Deleting a section..."

    # Determine the max number of successful unenrollments allowed.
    max_unenrollments = selected_course.enrolled_students.size() - selected_course.total_min()
    puts "#{selected_course.course_number}: #{selected_course.enrolled_students.size()} students is GREATER than #{selected_course.total_min} total min."
    puts "Unenrolling a max of #{max_unenrollments}..."

    # Determine which students will be unenrolled.
    unenrolling = []
    selected_course.enrolled_students().each { |student|
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
      student.unenroll(selected_course.course_number, courses_hash)
      puts "#{student.student_id} was UNENROLLED from #{selected_course.course_number}."
    }
    puts "  >> #{selected_course.course_number()}, #{selected_course.enrolled_students().size()} total, #{selected_course.total_min} total min, #{selected_course.total_max} total max, #{selected_course.num_overenrolled_students()} overenrolled, "

    puts "SO FAR:"
    # Print all of the students in each course.
    courses.each { |course|
      puts "  >> #{course.course_number()}, #{course.enrolled_students().size()} total, #{course.total_min} total min, #{course.total_max} total max, #{course.num_overenrolled_students()} overenrolled, "
    }
    puts " *** Total Overenrollments: #{Student.overenrollments(students)}"
  
  end

  puts "SO FAR:"
  # Print all of the students in each course.
  courses.each { |course|
    puts "  >> #{course.course_number()}, #{course.enrolled_students().size()} total, #{course.total_min} total min, #{course.total_max} total max, #{course.num_overenrolled_students()} overenrolled, "
  }
  puts " *** Total Overenrollments: #{Student.overenrollments(students)}"

  # Print each student's enrollments
  students.each { |student|
    puts "Priority: #{student.priority}, Overenrolled: #{student.overenrolled}, Enrolled: #{student.enrolled_courses}, #{student.student_id}, #{student.student_year}, #{student.courses_taken}, #{student.semesters_left}, #{student.num_requests}, #{student.prefs}"
  }

  # At this point, all students will be in their requested number of
  # courses, unless that had less preferences (example: student wants
  # 2 courses but only lists 1 preference; he is enrolled in that course).

  # Need to kick students from any classes above their total max. These
  # students should be stored in the appropriate array; either they are
  # still enrolled in 1 course, or they are enrolled in 0.
  single_enrolled = []
  not_enrolled = []
  
  # Traverse through each course over its total max
  courses.each { |course|
    
    # Just here for context; can remove eventually.
    if  course.enrolled_students.size() > course.total_max()
      puts "#{course.course_number} has #{course.enrolled_students.size()} students, but a max of #{course.total_max()}. Need to kick some..."
    end

    while course.enrolled_students.size() > course.total_max()

      # It actually doesn't matter which student we kick for
      # now, since this is audited at the end of the process.
      kicked_student = course.enrolled_students.pop()
      puts "#{kicked_student.student_id} has been KICKED from #{course.course_number}."
      kicked_student.drop(course.course_number, "#{course.course_number} filled up.", courses_hash)

      # Determine where to put this student. We can be certain that 
      # these students either have 0 or 1 enrollment, since they were
      # just kicked from a class, so they cannot possibly have 2.
      # Duplicates are OK; we focus on the unenrolled first.
      if kicked_student.enrolled_courses.size() == 0
        not_enrolled.push(kicked_student)
      else
        single_enrolled.push(kicked_student)
      end

    end
  }

  # Need to drop kids from sections below their total mins.

  # Print the list of unenrolled students and kicked students with a single course.
  puts "UNENROLLED STUDENTS:"
  not_enrolled.each { |student|
    puts "Priority: #{student.priority}, Overenrolled: #{student.overenrolled}, Enrolled: #{student.enrolled_courses}, #{student.student_id}, #{student.student_year}, #{student.courses_taken}, #{student.semesters_left}, #{student.num_requests}, #{student.prefs}"
  }
  puts "ONLY 1 COURSE / KICKED:"
  single_enrolled.each { |student|
    puts "Priority: #{student.priority}, Overenrolled: #{student.overenrolled}, Enrolled: #{student.enrolled_courses}, #{student.student_id}, #{student.student_year}, #{student.courses_taken}, #{student.semesters_left}, #{student.num_requests}, #{student.prefs}"
  }

  puts "SO FAR:"
  # Print all of the students in each course.
  courses.each { |course|
    puts "  >> #{course.course_number()}, #{course.enrolled_students().size()} total, #{course.total_min} total min, #{course.total_max} total max, #{course.num_overenrolled_students()} overenrolled, "
  }
  puts " *** Total Overenrollments: #{Student.overenrollments(students)}"

  # Print each student's enrollments
  students.each { |student|
    puts "Priority: #{student.priority}, Overenrolled: #{student.overenrolled}, Enrolled: #{student.enrolled_courses}, #{student.student_id}, #{student.student_year}, #{student.courses_taken}, #{student.semesters_left}, #{student.num_requests}, #{student.prefs}"
  }

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
