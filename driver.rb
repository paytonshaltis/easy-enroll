require "csv"
require "./student"
require "./course"

def main()
  
  courses = []
  courses_hash = {}
  students = []

  # Read in the course info from constraints.csv
  header_read = false
  CSV.foreach("./input-files/course_constraints.csv") { |row|
    
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
  CSV.foreach("./input-files/student_prefs.csv") { |row|
    
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

  # Call the revive_courses method to see if any courses can be revived. Enroll
  # students into these courses accordingly.
  revive_courses(courses, courses_hash, not_enrolled, single_enrolled)

  # Print the list of unenrolled students and kicked students with a single course.
  puts "UNENROLLED STUDENTS:"
  not_enrolled.each { |student|
    puts "Priority: #{student.priority}, Overenrolled: #{student.overenrolled}, Enrolled: #{student.enrolled_courses}, #{student.student_id}, #{student.student_year}, #{student.courses_taken}, #{student.semesters_left}, #{student.num_requests}, #{student.prefs}"
  }
  puts "ONLY 1 COURSE / KICKED:"
  single_enrolled.each { |student|
    puts "Priority: #{student.priority}, Overenrolled: #{student.overenrolled}, Enrolled: #{student.enrolled_courses}, #{student.student_id}, #{student.student_year}, #{student.courses_taken}, #{student.semesters_left}, #{student.num_requests}, #{student.prefs}"
  }

  puts "========================================================================================================================"

  # Next, try swapping the lowest priority student from a 
  # course who is enrolled in two courses with a student that
  # is not enrolled in any.
  puts "UNENROLLED --> 2X ENROLLED"
  remove_from_not_enrolled = []
  not_enrolled.each { |student|
    
    puts " >> Priority: #{student.priority}, Overenrolled: #{student.overenrolled}, Enrolled: #{student.enrolled_courses}, #{student.student_id}, #{student.student_year}, #{student.courses_taken}, #{student.semesters_left}, #{student.num_requests}, #{student.prefs}"
    student.prefs.each { |pref|
      puts "#{pref}"
    }

    # Mark the lowest priority student enrolled in 2 courses.
    done_checking = false
    marked_student = nil
    marked_course = nil

    # Look through all of the student's preferences.
    student.prefs.each { |pref|
    
      # If a course has a spot open, enroll the student.
      if courses_hash[pref].enrolled_students.size() < courses_hash[pref].total_max()
        
        puts "#{courses_hash[pref].course_number} has room for student #{student.student_id}!"
        
        # Mark the student to be removed from their array.
        remove_from_not_enrolled.push(student)

        # Enroll the student.
        student.enroll(pref, courses_hash)

        # We are done with this student now.
        done_checking = true
        break

      end

    }

    # See if we were able to just add the student.
    if done_checking
      next
    end

    # Look through all of the student's preferences.
    student.prefs.each { |pref|

      # Get the lowest priority student in this preference.
      lowest_student = lowest_priority_student(pref, courses_hash, 2)
      
      # See if the lowest student found is lower priority than 
      # the currently marked student.
      if lowest_student && ((not marked_student) || lowest_student.priority() < marked_student.priority())
        marked_student = lowest_student
        marked_course = pref
      end

    }

    # We don't care about the unenrolled student's priority; no
    # student should be enrolled in two courses while there are
    # still students unenrolled.
    if marked_student
      puts " ### FOUND STUDENTS TO SWAP: "
      puts " >> Priority: #{student.priority}, Overenrolled: #{student.overenrolled}, Enrolled: #{student.enrolled_courses}, #{student.student_id}, #{student.student_year}, #{student.courses_taken}, #{student.semesters_left}, #{student.num_requests}, #{student.prefs}"
      puts " >> Priority: #{marked_student.priority}, Overenrolled: #{marked_student.overenrolled}, Enrolled: #{marked_student.enrolled_courses}, #{marked_student.student_id}, #{marked_student.student_year}, #{marked_student.courses_taken}, #{marked_student.semesters_left}, #{marked_student.num_requests}, #{marked_student.prefs}"
      puts " >> #{marked_course}"
      puts " ###"

      # Drop the student from this course, adding them to the appropriate array.
      marked_student.drop(marked_course, "Removed from #{marked_course} due to higher priority student needing enrollment.", courses_hash)
      single_enrolled.push(marked_student)

      # Enroll the current student in this course, marking them for 
      # removal from the not enrolled array.
      student.enroll(marked_course, courses_hash)
      remove_from_not_enrolled.push(student)

    end
  }

  # Removed each of the students who were swapped in.
  remove_from_not_enrolled.each { |student|
    not_enrolled.delete(student)
  }

  # Next, try swapping the lowest priority student from a 
  # course who is enrolled one course with a student who is
  # unenrolled. Priority comparisons should be considered here.
  puts "UNENROLLED --> 1X ENROLLED"
  remove_from_not_enrolled = []
  not_enrolled.each { |student|
    
    puts " >> Priority: #{student.priority}, Overenrolled: #{student.overenrolled}, Enrolled: #{student.enrolled_courses}, #{student.student_id}, #{student.student_year}, #{student.courses_taken}, #{student.semesters_left}, #{student.num_requests}, #{student.prefs}"
    student.prefs.each { |pref|
      puts "#{pref}"
    }

    # Mark the lowest priority student enrolled in 1 course.
    done_checking = false
    marked_student = nil
    marked_course = nil

    # Look through all of the student's preferences.
    student.prefs.each { |pref|
    
      # If a course has a spot open, enroll the student.
      if courses_hash[pref].enrolled_students.size() < courses_hash[pref].total_max()
        
        puts "#{courses_hash[pref].course_number} has room for student #{student.student_id}!"
        
        # Mark the student to be removed from their array.
        remove_from_not_enrolled.push(student)

        # Enroll the student.
        student.enroll(pref, courses_hash)

        # We are done with this student now.
        done_checking = true
        break

      end

    }

    # See if we were able to just add the student.
    if done_checking
      next
    end

    # Look through all of the student's preferences.
    student.prefs.each { |pref|

      # Get the lowest priority student in this preference.
      lowest_student = lowest_priority_student(pref, courses_hash, 1)
      
      # See if the lowest student found is lower priority than 
      # the currently marked student.
      if lowest_student && ((not marked_student) || lowest_student.priority() < marked_student.priority())
        marked_student = lowest_student
        marked_course = pref
      end

    }

    # Here, we must consider student priority. Since the marked student will
    # potentially be unenrolled, we need to make sure that they really have
    # a lower priority than the student being swapped in.
    if marked_student && (student.priority() > marked_student.priority())
      puts " ### FOUND STUDENTS TO SWAP: "
      puts " >> Priority: #{student.priority}, Overenrolled: #{student.overenrolled}, Enrolled: #{student.enrolled_courses}, #{student.student_id}, #{student.student_year}, #{student.courses_taken}, #{student.semesters_left}, #{student.num_requests}, #{student.prefs}"
      puts " >> Priority: #{marked_student.priority}, Overenrolled: #{marked_student.overenrolled}, Enrolled: #{marked_student.enrolled_courses}, #{marked_student.student_id}, #{marked_student.student_year}, #{marked_student.courses_taken}, #{marked_student.semesters_left}, #{marked_student.num_requests}, #{marked_student.prefs}"
      puts " >> #{marked_course}"
      puts " ###"

      # Drop the student from this course, adding them to the appropriate array.
      marked_student.drop(marked_course, "Removed from #{marked_course} due to higher priority student needing enrollment.", courses_hash)
      not_enrolled.push(marked_student)

      # Enroll the current student in this course, marking them for 
      # removal from the not enrolled array.
      student.enroll(marked_course, courses_hash)
      remove_from_not_enrolled.push(student)

    else
      puts "This student could not be swapped into any courses."
      remove_from_not_enrolled.push(student)
    end
  }

  # Removed each of the students who were either swapped in, or could
  # not be enrolled this semester.
  remove_from_not_enrolled.each { |student|
    not_enrolled.delete(student)
  }

  # Finally, we must consider the students that are only enrolled in a single
  # course, but would like another. This should be done by comparing the
  # priorities of all students in their preferences to see if any can drop
  # one of their courses to make room for the higher-priority student. Note that
  # only students enrolled in 2 courses will be compared, so by this point, NO 
  # more students will become unenrolled.

  # Prove that no students become unenrolled after this process.
  count = 0
  students.each { |student|

    # Only count students that are not enrolled in any course, as long
    # as they have requested a course
    if student.enrolled_courses.size() == 0 && student.num_requests > 0
      count += 1
    end
  }
  puts "Total unenrolled students: #{count}"

  # Consider all of the students who are single enrolled
  puts "SINGLE ENROLLED --> 2X ENROLLED"
  remove_from_single_enrolled = []
  single_enrolled.each { |student|
    
    puts " >> Priority: #{student.priority}, Overenrolled: #{student.overenrolled}, Enrolled: #{student.enrolled_courses}, #{student.student_id}, #{student.student_year}, #{student.courses_taken}, #{student.semesters_left}, #{student.num_requests}, #{student.prefs}"
    student.prefs.each { |pref|
      puts "#{pref}"
    }

    # Mark the lowest priority student enrolled in 2 courses.
    done_checking = false
    marked_student = nil
    marked_course = nil

    # Look through all of the student's preferences.
    student.prefs.each { |pref|    

      # If a course has a spot open, and the student is not
      # already enrolled in this course, enroll the student.
      if (courses_hash[pref].enrolled_students.size() < courses_hash[pref].total_max()) && (not student.enrolled_courses.include?(pref))
        
        puts "#{courses_hash[pref].course_number} has room for student #{student.student_id}!"
        
        # Mark the student to be removed from their array.
        remove_from_single_enrolled.push(student)

        # Enroll the student.
        student.enroll(pref, courses_hash)

        # We are done with this student now.
        done_checking = true
        break

      end

    }

    # See if we were able to just add the student.
    if done_checking
      next
    end

    # Look through all of the student's preferences.
    student.prefs.each { |pref|

      # Get the lowest priority student in this preference if the student is not
      # already enrolled in this course.
      if not student.enrolled_courses.include?(pref)
        lowest_student = lowest_priority_student(pref, courses_hash, 2)
      end  
      
        # See if the lowest student found is lower priority than 
        # the currently marked student.
        if lowest_student && ((not marked_student) || lowest_student.priority() < marked_student.priority())
          marked_student = lowest_student
          marked_course = pref
        end

    }

    # Here, we must consider student priority. Since the marked student will
    # lose a class, we need to make sure that they really have a lower 
    # priority than the student being swapped in.
    if marked_student && (student.priority() > marked_student.priority())
      puts " ### FOUND STUDENTS TO SWAP: "
      puts " >> Priority: #{student.priority}, Overenrolled: #{student.overenrolled}, Enrolled: #{student.enrolled_courses}, #{student.student_id}, #{student.student_year}, #{student.courses_taken}, #{student.semesters_left}, #{student.num_requests}, #{student.prefs}"
      puts " >> Priority: #{marked_student.priority}, Overenrolled: #{marked_student.overenrolled}, Enrolled: #{marked_student.enrolled_courses}, #{marked_student.student_id}, #{marked_student.student_year}, #{marked_student.courses_taken}, #{marked_student.semesters_left}, #{marked_student.num_requests}, #{marked_student.prefs}"
      puts " >> #{marked_course}"
      puts " ###"

      # Drop the student from this course, adding them to the appropriate array.
      marked_student.drop(marked_course, "Removed from #{marked_course} due to higher priority student wanting 2 courses.", courses_hash)
      single_enrolled.push(marked_student)

      # Enroll the current student in this course, marking them for 
      # removal from the not enrolled array.
      student.enroll(marked_course, courses_hash)
      remove_from_single_enrolled.push(student)

    else
      puts "This student could not be swapped into any ADDITIONAL courses."
      remove_from_single_enrolled.push(student)
    end
  }

  # Removed each of the students who were either swapped into an additional
  # course, or could not be added to 2 courses.
  remove_from_single_enrolled.each { |student|
    single_enrolled.delete(student)
  }

  # Prove that no students become unenrolled after this process.
  count = 0
  students.each { |student|

    # Only count students that are not enrolled in any course, as long
    # as they have requested a course
    if student.enrolled_courses.size() == 0 && student.num_requests > 0
      count += 1
    end
  }
  puts "Total unenrolled students: #{count}"

  # The final thing to do is try reviving a course with students who are unenrolled
  # and single enrolled.
  single_enrolled = []
  not_enrolled = []

  students.each { |student|
    if student.enrolled_courses.size() == 0 && (student.num_requests >= 1 && student.prefs.size() >= 1)
      not_enrolled.push(student)
    elsif student.enrolled_courses.size() == 1 && (student.num_requests == 2 && student.prefs.size() >= 2)
      single_enrolled.push(student)
    end
  }

  puts "Single enrolled: #{single_enrolled.size()}"
  puts "Not enrolled: #{not_enrolled.size()}"

  # Call the revive_courses method to see if any courses can be revived. Enroll
  # students into these courses accordingly.
  revive_courses(courses, courses_hash, not_enrolled, single_enrolled)

  # Write to the output files.

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

  # Print out some final results.
  puts "============================================================================="
  puts "FINAL RESULTS:"
  puts "COURSES:"
  courses.each { |course|
    puts "  >> #{course.course_number()}, #{course.enrolled_students().size()} total, #{course.total_min} total min, #{course.total_max} total max, #{course.num_overenrolled_students()} overenrolled, "
    course.enrolled_students.each { |student|
      puts "Priority: #{student.priority}, Overenrolled: #{student.overenrolled}, Enrolled: #{student.enrolled_courses}, #{student.student_id}, #{student.student_year}, #{student.courses_taken}, #{student.semesters_left}, #{student.num_requests}, #{student.prefs}"
    }
  }

  puts "BAD STUDENTS:"
  students.each { |student|
    if (student.prefs.include?("CSC 471")) && (not student.enrolled_courses.include?("CSC 471")) && (student.enrolled_courses.size() < 2) && student.num_requests() == 2
      puts "Priority: #{student.priority}, Overenrolled: #{student.overenrolled}, Enrolled: #{student.enrolled_courses}, #{student.student_id}, #{student.student_year}, #{student.courses_taken}, #{student.semesters_left}, #{student.num_requests}, #{student.prefs}"
    end
  }

  puts "ENROLLMENT STATS:"
  filled_2 = 0
  filled_1 = 0
  empty_2 = 0
  empty_1 = 0
  total_empty_2 = 0
  requested_0 = 0
  students.each { |student|
    if student.enrolled_courses().size() == 3
      puts "****************************MAJOR ERROR! STUDENT ENROLLED IN 3 COURSES!!"
    elsif student.enrolled_courses().size() == 2
      filled_2 += 1
    elsif student.enrolled_courses().size() == 1 && student.num_requests == 2 && student.prefs.size() >= 2
      empty_2 += 1
      puts "Priority: #{student.priority}, Overenrolled: #{student.overenrolled}, Enrolled: #{student.enrolled_courses}, #{student.student_id}, #{student.student_year}, #{student.courses_taken}, #{student.semesters_left}, #{student.num_requests}, #{student.prefs}"
    elsif student.enrolled_courses().size() == 1 && student.num_requests == 1
      filled_1 += 1
    elsif student.enrolled_courses().size() == 0 && student.num_requests == 1 && student.prefs.size() >= 1
      empty_1 += 1
    elsif student.enrolled_courses().size() == 0 && student.num_requests == 2 && student.prefs.size() >= 2
      total_empty_2 += 1
    elsif student.num_requests == 0
      requested_0 += 1
    end

  }
  puts "Legitimate students who requested courses correctly (num requests >= prefs)"
  puts "Students enrolled in 2/2 courses: #{filled_2}"
  puts "Students enrolled in 1/2 courses: #{empty_2}"
  puts "Students enrolled in 0/2 courses: #{total_empty_2}"
  puts "Students enrolled in 1/1 courses: #{filled_1}"
  puts "Students enrolled in 0/1 courses: #{empty_1}"
  puts "Students who requested 0 courses: #{requested_0}"
  
  puts "TOTAL: #{filled_1 + filled_2 + empty_1 + empty_2 + total_empty_2 + requested_0}"

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

    # Compare priorities and course enrollments to update the tracked student.
    elsif (lowest_student) && (student.priority() < lowest_student.priority()) && student.enrolled_courses().size() == num_enrolled
      lowest_student = student
    end

  }

  # Return the student. This may be nil if none qualify.
  lowest_student

end

# Attempts to revive courses based on the contents of the an array on unenrolled
# students and an array of singly-enrolled students who can take another course.
def revive_courses(courses, courses_hash, not_enrolled, single_enrolled)
  
  # Need to keep track of how many students can be enrolled in each course.
  prefs_hash = Hash.new(0)

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

  # Need to keep track of which students will be removed after they are enrolled.
  # Removing during each() iterations causes issues; best to wait until the end.
  remove_from_not_enrolled = []
  remove_from_single_enrolled = []

  # Need to traverse through each course.
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
end

main()