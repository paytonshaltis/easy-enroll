# Name: Payton Shaltis
# Project name: Assignment 1: EasyEnroll
# Description: An algorithm that determines the best college course enrollment strategy according to a set of student preferences and course constraings.
# Filename: easyenroll.rb
# Description: Contains the main() method with the actual algorithm implementation.
# Last modified on: February 13, 2022

require "csv"
require "./student"
require "./course"

def main()
  
  # Input and output file names.
  pref_file_name = ""
  constraint_file_name = ""
  student_output_file_name = ""
  course_output_file_name = ""

  # Data structures used for keeping track of all students and courses.
  courses = []
  students = []
  courses_hash = {}                          # Hashes String => Course.

  # Get the name of the constraints input file.
  puts "Enter course constraints input file name:"
  while true
    constraint_file_name = gets().chomp()
    if not File.file?(constraint_file_name)
      puts "File does not exist. Enter a valid file name:"
    else
      break
    end
  end
  
  # Get the name of the preferences input file.
  puts "Enter student preference input file name:"
  while true
    pref_file_name = gets().chomp()
    if not File.file?(pref_file_name)
      puts "File does not exist. Enter a valid file name:"
    else
      break
    end
  end

  # Gets the name of the courses output file.
  puts "Enter course output file name (will be overwritten if it already exists):"
  while true
    course_output_file_name = gets().chomp()
    if course_output_file_name == ""
      puts "Output file name cannot be blank. Enter a valid file name:"
    else
      break
    end
  end

  # Gets the name of the students output file.
  puts "Enter student output file name (will be overwritten if it already exists):"
  while true
    student_output_file_name = gets().chomp()
    if student_output_file_name == course_output_file_name
      puts "Output file names must not be the same. Enter a valid file name:"
    elsif student_output_file_name == ""
      puts "Output file name cannot be blank. Enter a valid file name:"
    else
      break
    end
  end

  # Enroll all students into all of their preferences.
  process_courses(constraint_file_name, courses, courses_hash)
  process_students(pref_file_name, students, courses_hash)

  # Unenroll from courses until there are no overenrolled students remaining.
  unenroll_above_max(courses, students, courses_hash)
  unenroll_above_min(courses, students, courses_hash)
  unenroll_below_min(courses, students, courses_hash)
  unenroll_at_min(courses, students, courses_hash)

  # Kick students from courses over their maximum, storing them temporarily.
  not_enrolled = []
  single_enrolled = []
  kick_students(courses, courses_hash, not_enrolled, single_enrolled)

  # Try reviving course sections with these kicked students.
  revive_courses(courses, courses_hash, not_enrolled, single_enrolled)

  # Swap these kicked students out for lower-priority ones.
  unenrolled_swap_double(courses, courses_hash, not_enrolled, single_enrolled)
  unenrolled_swap_single(courses, courses_hash, not_enrolled, single_enrolled)
  single_swap_double(courses, courses_hash, not_enrolled, single_enrolled)

  # Check for one final course-section revival using the remaining students.
  not_enrolled = []
  single_enrolled = []
  students.each { |student|
    if student.enrolled_courses().size() == 0 && (student.num_requests() >= 1 && student.prefs().size() >= 1)
      not_enrolled.push(student)
    elsif student.enrolled_courses().size() == 1 && (student.num_requests() == 2 && student.prefs().size() >= 2)
      single_enrolled.push(student)
    end
  }
  revive_courses(courses, courses_hash, not_enrolled, single_enrolled)

  # Add resons to each student who is not enrolled in their max courses.
  create_reasons(courses_hash, students)

  # Write the courses to the desired output file.
  CSV.open(course_output_file_name, "w") { |csv|
    csv.puts(["Course Number", "Section Number", "IDs of Students to be Enrolled in this Course/Section", "Number of seats filled", "Number of open seats", "Can run?"])
    courses.each { |course|
      
      # Add the course's running sections first.
      for i in (1..course.curr_num_sections) do
        csv.puts(course.to_csv(i))
      end

      # Add the course's non-running sections next.
      for i in (course.curr_num_sections()...course.init_num_sections())
        csv.puts([course.course_number(), "0#{i + 1}", "None", 0, course.max(), "No"])
      end

    }
  }

  # Write the students to the desired output file.
  CSV.open(student_output_file_name, "w") { |csv|
    csv.puts(["Student ID", "Courses in which enrolled", "Reason"])
    students.each { |student|
      csv.puts(student.to_csv())
    }
  }

  # Tally up the totals for enrolled and unenrolled students.
  enrolled_2_2 = 0
  enrolled_1_2 = 0
  enrolled_0_2 = 0
  enrolled_1_1 = 0
  enrolled_0_1 = 0
  enrolled_0_0 = 0
  enrolled_m_l = 0
  students.each { |student|
    if student.enrolled_courses().size() == 2
      enrolled_2_2 += 1
    elsif student.enrolled_courses().size() == 1 && student.num_requests == 2 && student.prefs.size() >= 2
      enrolled_1_2 += 1
    elsif student.enrolled_courses().size() == 1 && student.num_requests == 1
      enrolled_1_1 += 1
    elsif student.enrolled_courses().size() == 0 && student.num_requests == 1 && student.prefs.size() >= 1
      enrolled_0_1 += 1
    elsif student.enrolled_courses().size() == 0 && student.num_requests == 2 && student.prefs.size() >= 2
      enrolled_0_2 += 1
    elsif student.num_requests == 0
      enrolled_0_0 += 1
    elsif student.num_requests() > student.prefs().size()
      enrolled_m_l += 1
    end

  }

  # Print out the final statistics to the standard output.
  puts "=============================="
  puts "ENROLLMENT TOTALS:"
  puts "Students enrolled in 2/2 courses: #{enrolled_2_2}"
  puts "Students enrolled in 1/2 courses: #{enrolled_1_2}"
  puts "Students enrolled in 0/2 courses: #{enrolled_0_2}"
  puts "Students enrolled in 1/1 courses: #{enrolled_1_1}"
  puts "Students enrolled in 0/1 courses: #{enrolled_0_1}"
  puts "Students who requested 0 courses: #{enrolled_0_0}"
  puts "Students who requested more courses than preferences: #{enrolled_m_l}"
  puts "TOTAL: #{enrolled_2_2 + enrolled_1_2 + enrolled_0_2 + enrolled_1_1 + enrolled_0_1 + enrolled_0_0 + enrolled_m_l}"

  # Print out all students and their priorities.
  students.each { |student|
    puts "Priority: #{student.priority}: #{student.student_id}, #{student.student_year}, #{student.courses_taken}, #{student.semesters_left}, #{student.num_requests}, #{student.prefs}"
  }

end

# Reads in all course constraint entries from the provided CSV filename.
# Creates the Course objects and stores them into the provided array and
# hash for later use in the algorithm.
def process_courses(file_name, courses, courses_hash)

  header_read = false
  CSV.foreach("./#{file_name}") { |row|

    # Should ignore the header row from CSV files.
    if not header_read
      header_read = true
      next
    end

    # See if the user mixed up preferences and constraints.
    if row[4] != nil
      puts "Please make sure you input a CONSTRAINT file and a PREFERENCE file, in that order. Exiting..."
      exit()
    end

    # Add the course to the course list.
    addedCourse = Course.new(row)
    courses.push(addedCourse)

    # Add the course to the course hash.
    courses_hash[addedCourse.course_number()] = addedCourse
  }

end

# Reads in all student preference entries from the provided CSV filename. 
# Creates and enrolls each Student object into all of their preferences,
# storing them into the provided array for later use in the algorithm.
def process_students(file_name, students, courses_hash)

  header_read = false
  CSV.foreach("./#{file_name}") { |row|

    # Should ignore the header row from CSV files.
    if not header_read
      header_read = true
      next
    end

    # See if the user mixed up preferences and constraints.
    if row[4] == nil
      puts "Please make sure you input a CONSTRAINT file and a PREFERENCE file, in that order. Exiting..."
      exit()
    end

    # Create the Student object.
    addedStudent = Student.new(row)

    # Enroll the student in all of their preferences.
    addedStudent.enroll(addedStudent.prefs, courses_hash)

    # Add the student to the array of students.
    students.push(addedStudent)
  }

end

# Unenrolls as many students as possible that are overenrolled from courses that
# are currently above their maximum number of students.
def unenroll_above_max(courses, students, courses_hash)

  # For each course that is over its total max.
  courses.each { |course|
    if course.enrolled_students.size() > course.total_max()

      # Determine the max number of successful unenrollments allowed.
      max_unenrollments = course.enrolled_students.size() - course.total_max()

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
      }

    end
  }

end

# Unenrolls as many students as possible that are overenrolled from courses that
# are currently above their minimum number of students.
def unenroll_above_min(courses, students, courses_hash)

  # For each course that is over its total min.
  courses.each { |course|
    if course.enrolled_students.size() > course.total_min()
    
      # Determine the max number of successful unenrollments allowed.
      max_unenrollments = course.enrolled_students.size() - course.total_min()

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
      }

    end
  }

end

# Unenrolls as many students as possible that are overenrolled from courses that
# are currently below their minimum number of students.
def unenroll_below_min(courses, students, courses_hash)

  # For each course that is below its total min.
  courses.each { |course|

    # Start with courses already below their minimum.
    while course.enrolled_students.size() < course.total_min()
      
      # Get rid of sections until they can all be filled
      course.curr_num_sections -= 1
    end
    
    # Now, unenroll as many as possible above the minimum.
    if course.enrolled_students.size() > course.total_min()
    
      # Determine the max number of successful unenrollments allowed.
      max_unenrollments = course.enrolled_students.size() - course.total_min()

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
      }

    end

  }

end

# Unenrolls as many students as possible that are overenrolled from courses that
# are currently at their minimum number of students. A 'best course' is selected
# to drop a section until there are no more overenrolled students.
def unenroll_at_min(courses, students, courses_hash)

  # For each course that is at its total min.
  until Student.overenrollments(students) == 0
  
    # Determine the course with the greatest (overenrollemnts:min) ratio.
    selected_course = nil
    courses.each { |course|
      if ((not selected_course) || (course.num_overenrolled_students().to_f / course.min()) > (selected_course.num_overenrolled_students().to_f / selected_course.min()))
        selected_course = course
      end
    }
    
    # Get rid of a section of this course
    selected_course.curr_num_sections -= 1

    # Determine the max number of successful unenrollments allowed.
    max_unenrollments = selected_course.enrolled_students.size() - selected_course.total_min()

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
    }
  
  end

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

  # Need to traverse through each course.
  courses.each { |course|
  
    # Determine if it can be revived.
    while course.init_num_sections() > course.curr_num_sections() && prefs_hash[course.course_number] > course.min()
      
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

        # See if the course section is now full.
        if total_added == course.max()
          break
        end

      }

      # Remove each of the marked students from the not_enrolled array.
      remove_from_not_enrolled.each { |student|
        not_enrolled.delete(student)
      }

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
        single_enrolled.delete(student)
      }

    end
  }
end

# Kicks as many students as needed from courses who are above their maximum
# number of students, organizing the type of student that was kicked into
# one of two arrays: not_enrolled or single_enrolled.
def kick_students(courses, courses_hash, not_enrolled, single_enrolled)

  # Traverse through each course, remove students from those that are over
  # their max (all courses either at or above min, even if min is 0).
  courses.each { |course|

    while course.enrolled_students.size() > course.total_max()

      # It actually doesn't matter which student we kick for
      # now, since this is audited at the end of the process.
      kicked_student = course.enrolled_students.pop()
      kicked_student.kick(course.course_number, courses_hash)

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

end

# Adds as many unenrolled students into courses as possible. Unenrolled students
# are first enrolled in any free spots that exist, then they are swapped into 
# courses in place of double-enrolled students.
def unenrolled_swap_double(courses, courses_hash, not_enrolled, single_enrolled)

  # Next, try swapping the lowest priority student from a 
  # course who is enrolled in two courses with a student that
  # is not enrolled in any.
  remove_from_not_enrolled = []
  not_enrolled.each { |student|

    # Mark the lowest priority student enrolled in 2 courses.
    done_checking = false
    marked_student = nil
    marked_course = nil

    # Look through all of the student's preferences.
    student.prefs.each { |pref|
    
      # If a course has a spot open, enroll the student.
      if courses_hash[pref].enrolled_students.size() < courses_hash[pref].total_max()
                
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

      # Kick the student from this course, adding them to the appropriate array.
      marked_student.kick(marked_course, courses_hash)
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

end

# Adds as many unenrolled students into courses as possible. Unenrolled students
# are compared to single-enrolled students, and swapped if the unenrolled student
# has a higher priority. The swapped students are checked to see if they can be 
# swapped into another course as well.
def unenrolled_swap_single(courses, courses_hash, not_enrolled, single_enrolled)

  # Next, try swapping the lowest priority student from a 
  # course who is enrolled one course with a student who is
  # unenrolled. Priority comparisons should be considered here.
  remove_from_not_enrolled = []
  not_enrolled.each { |student|

    # Mark the lowest priority student enrolled in 1 course.
    done_checking = false
    marked_student = nil
    marked_course = nil

    # Look through all of the student's preferences.
    student.prefs.each { |pref|
    
      # If a course has a spot open, enroll the student.
      if courses_hash[pref].enrolled_students.size() < courses_hash[pref].total_max()
        
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

      # Kick the student from this course, adding them to the appropriate array.
      marked_student.kick(marked_course, courses_hash)
      not_enrolled.push(marked_student)

      # Enroll the current student in this course, marking them for 
      # removal from the not enrolled array.
      student.enroll(marked_course, courses_hash)
      remove_from_not_enrolled.push(student)

    else
      remove_from_not_enrolled.push(student)
    end
  }

  # Removed each of the students who were either swapped in, or could
  # not be enrolled this semester.
  remove_from_not_enrolled.each { |student|
    not_enrolled.delete(student)
  }

end

# Adds as many single-enrolled students into courses as possible. Single-enrolled
# students are compared to double-enrolled students, and swapped if their priorities
# are higher. The swapped students are checked to see if they can be swapped into
# another course as well.
def single_swap_double(courses, courses_hash, not_enrolled, single_enrolled)

  # Consider all of the students who are single enrolled
  remove_from_single_enrolled = []
  single_enrolled.each { |student|

    # Mark the lowest priority student enrolled in 2 courses.
    done_checking = false
    marked_student = nil
    marked_course = nil

    # Look through all of the student's preferences.
    student.prefs.each { |pref|    

      # If a course has a spot open, and the student is not
      # already enrolled in this course, enroll the student.
      if (courses_hash[pref].enrolled_students.size() < courses_hash[pref].total_max()) && (not student.enrolled_courses.include?(pref))
        
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

      # Kick the student from this course, adding them to the appropriate array.
      marked_student.kick(marked_course, courses_hash)
      single_enrolled.push(marked_student)

      # Enroll the current student in this course, marking them for 
      # removal from the not enrolled array.
      student.enroll(marked_course, courses_hash)
      remove_from_single_enrolled.push(student)

    else
      remove_from_single_enrolled.push(student)
    end
  }

  # Removed each of the students who were either swapped into an additional
  # course, or could not be added to 2 courses.
  remove_from_single_enrolled.each { |student|
    single_enrolled.delete(student)
  }

end

# Creates reasons for each student that was not enrolled in their original number
# of requested courses.
def create_reasons(courses_hash, students)

  # Add reasons to the unenrolled students.
  students.each { |student|

    # First, if the student requested more courses than were
    # listed in their preferences, add this as a reason.
    if student.num_requests() > student.prefs().size()
      student.reasons().push("Requested more courses than preferences.")
    end

    student.prefs().each { |pref|
      
      # Only consider students who are enrolled in less courses than
      # the number that they requested.
      if student.enrolled_courses().size() < student.num_requests()
        
        # Add a reason if the student is not enrolled in this course.
        if not student.enrolled_courses().include?(pref)
          student.reasons().push(courses_hash[pref].get_reason())

        end

      end

    }
  }

end

# Begin execution of the main method.
main()