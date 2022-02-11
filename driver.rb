require "csv"
require "./student"
require "./course"

def main()
  
  courses = []
  courses_hash = {}
  students = []
  dropped_courses = []

  # Read in the course info from constraints.csv
  header_read = false
  CSV.foreach("./input-files/constraints.csv") { |row|
    
    # Should ignore the header row from CSV files.
    if not header_read
      header_read = true
      puts "Skipping course header..."
      next
    end

    # Add the course to the course list.
    addedCourse = Course.new(row)
    courses.push(addedCourse)

    # Add the course to the course hash.
    courses_hash[addedCourse.course_number()] = addedCourse
  }

  # Read in the preferences from prefs.csv
  header_read = false
  CSV.foreach("./input-files/prefs.csv") { |row|
    
    # Should ignore the header row from CSV files.
    if not header_read
      header_read = true
      puts "Skipping student header..."
      next
    end

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
  prefs_hash = Hash.new(0)

  # Traverse through each course, remove students from those that are over
  # their max (all courses either at or above min, even if min is 0).
  courses.each { |course|
    
    # Just here for context; can remove eventually.
    if  course.enrolled_students.size() > course.total_max()
      puts "#{course.course_number} has #{course.enrolled_students.size()} students, but a max of #{course.total_max()}. Need to kick some..."
    elsif course.enrolled_students.size() < course.total_min()
      puts "THIS SHOULD NEVER BE REACHED; SECTION COUNTS DECREASED IN UNENROLLMENT!!"
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

  # Tally up all of the unenrolled preferences.
  not_enrolled.each { |student|
    student.prefs.each { |course|
        prefs_hash[course] += 1
    }
  }

  # Tally up the single enrolled non-duplicate preferences.
  single_enrolled.each { |student|
    student.prefs.each { |course|

      # Only consider students with a single enrollment; others are dupes.
      if student.enrolled_courses.size() == 1
        
        # If the student has a preference that they aren't enrolled in.
        if not student.enrolled_courses().include?(course)
          prefs_hash[course] += 1
        end
      
      end
    }
  }
  puts prefs_hash

  # Revive any classes that are capable of it.
  courses.each { |course|
    
    # Determine if it can be revived
    while course.init_num_sections() > course.curr_num_sections() && prefs_hash[course.course_number] > course.min()
      puts "#{course.course_number} can revive a section!"
      
      # Increase the course's section count.
      course.curr_num_sections += 1

      # Enroll up to course.max() students into the course
      total_added = 0
      remove_from_not_enrolled = []
      remove_from_single_enrolled = []
        
      # Start with the unenrolled students.
      not_enrolled.each { |student|
        if student.prefs.include?(course.course_number)
          
          # Enroll this student in the course.
          student.enroll(course.course_number, courses_hash)

          # Subtract one from all of their prefs in the hash.
          student.prefs.each { |pref|
            prefs_hash[pref] -= 1
          }

          # Mark the student to be removed from this array.
          remove_from_not_enrolled.push(student)
          total_added += 1
        end
        if total_added == course.max()
          break
        end
      }

      # Remove each of the marked students from the not_enrolled array.
      remove_from_not_enrolled.each { |student|
        puts "Priority: #{student.priority}, Overenrolled: #{student.overenrolled}, Enrolled: #{student.enrolled_courses}, #{student.student_id}, #{student.student_year}, #{student.courses_taken}, #{student.semesters_left}, #{student.num_requests}, #{student.prefs}"
        not_enrolled.delete(student)
      }

      puts prefs_hash

      # See if we shold continue adding students.
      if total_added == course.max()
        break
      end

      # Continue with the single enrolled students.
      single_enrolled.each { |student|

        # Make sure that they aren't already enrolled in this course.
        if student.prefs.include?(course.course_number) && (not student.enrolled_courses.include?(course.course_number))
          
          # Enroll this student in the course.
          student.enroll(course.course_number, courses_hash)

          # Subtract one from all of their prefs.
          student.prefs.each { |pref|
            prefs_hash[pref] -= 1
          }

          # Mark the student to be removed from this array.
          remove_from_single_enrolled.push(student)
          total_added += 1
        end
        if total_added == course.max()
          break
        end
      }

      # Remove these students from the single enrolled array.
      remove_from_single_enrolled.each { |student|
        puts "Priority: #{student.priority}, Overenrolled: #{student.overenrolled}, Enrolled: #{student.enrolled_courses}, #{student.student_id}, #{student.student_year}, #{student.courses_taken}, #{student.semesters_left}, #{student.num_requests}, #{student.prefs}"
        single_enrolled.delete(student)
      }

    end
  }
  puts prefs_hash

  # Need to try enrolling the not enrolled students.
  

  # Need to try enrolling the single enrolled students.

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

  # Print the courses who dropped sections.
  courses.each { |course|
    puts "#{course.course_number}: #{course.init_num_sections - course.curr_num_sections}"
  }

# Write to the output files.

puts "=================================================="
puts "Let's find the lowest student with 2 enrollments in 325:"

courses_hash["CSC 325"].enrolled_students.each { |student|
  puts "Priority: #{student.priority}, Overenrolled: #{student.overenrolled}, Enrolled: #{student.enrolled_courses}, #{student.student_id}, #{student.student_year}, #{student.courses_taken}, #{student.semesters_left}, #{student.num_requests}, #{student.prefs}"
}

puts "#{lowest_priority_student("CSC 325", courses_hash, 1).student_id()}"

end

# Returns a reference to the student in course_name with the lowest
# priority who is enrolled in num_enrolled courses.
def lowest_priority_student(course_name, courses_hash, num_enrolled)

  # Retrieve the reference to the course.
  course_ref = courses_hash[course_name]

  # Need to keep track of the lowest priority student.
  lowest_student = nil

  # Find the correct student from the class.
  course_ref.enrolled_students.each { |student|
    
    # If lowest_student is nil, track the first student.
    if (not lowest_student) && (student.enrolled_courses.size() == num_enrolled)
      lowest_student = student

    puts "#{not lowest_student}"

    # Compare priorities and course enrollments.
    elsif (lowest_student) && (student.priority() < lowest_student.priority()) && student.enrolled_courses().size() == num_enrolled
      lowest_student = student
    end

  }

  # Return the student. This may be nil if none qualify.
  lowest_student

end

main()
