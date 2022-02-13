# Name: Payton Shaltis
# Project name: Assignment 1: EasyEnroll
# Description: An algorithm that determines the best college course enrollment strategy according to a set of student preferences and course constraings.
# Filename: student.rb
# Description: Contains the class implementation for representing Students.
# Last modified on: February 12, 2022

# Student class for representing students.
class Student

  # Read / write instance variables from CSV.
  attr_accessor :student_id, :student_year, :courses_taken, 
    :semesters_left, :num_requests, :prefs

  # Read / write instance variables NOT from CSV.
  attr_accessor :enrolled_courses, :reasons, :priority

  # Initializes the Student using a row from the CSV file.
  def initialize(student_info)

    # Straight from CSV file.
    @student_id = student_info[0]
    @student_year = student_info[1]
    @semesters_left = student_info[3].to_i()
    @num_requests = student_info[4].to_i()

    # Needs formatting.
    @courses_taken = split_taken(student_info[2])
    @prefs = merge_prefs(student_info[5], student_info[6], student_info[7])

    # Need to set up some variables NOT from CSV file.
    @enrolled_courses = []
    @reasons = []
    calculate_priority()

  end

  # Returns an array of strings representing courses taken by
  # the student in the past.
  def split_taken(courses_taken)
    if courses_taken
      return courses_taken.split(", ")
    else
      return []
    end
  end

  # Returns an array of strings representing courses preferred
  # by the student, omitting the "N/A"s.
  def merge_prefs(pref1, pref2, pref3)
    unfiltered = [pref1, pref2, pref3]
    filtered = []
    unfiltered.each { |pref|
      if (pref) && (not pref == "N/A")
        filtered.push(pref)
      end
    }
    filtered
  end

  # Returns the priority level of a student based on the 
  # factors described in the assignment. Returns an integer.
  def calculate_priority()
  
    # A higher result indicates a higher priority for classes.
    @priority = 0

    # The first digit represents the class level.
    case @student_year
    when "Senior"
      @priority += 40000
    when "Junior"
      @priority += 30000
    when "Sophomore"
      @priority += 20000
    when "First year student"
      @priority += 10000
    end

    # The second digit represents semesters taken.
    @priority += (8 - @semesters_left) * 1000

    # The third and fourth digits represent classes taken.
    @priority += @courses_taken.size() * 10

    # The fifth digit represents if the studen selected the
    # maximum number of courses that they could.
    if (@prefs.size() == 3) || (@prefs.size() + @courses_taken.size() == Course.total_courses())
      @priority += 3
    else
      @priority += (@prefs.size())
    end

  end

  # Returns the number of overenrollments for all students.
  def Student.overenrollments(students)
    count = 0
    students.each { |student|
      difference = student.enrolled_courses().size() - student.num_requests()
      count += (difference > 0) ? difference : 0
    }
    return count
  end

  # Returns true if the student is still enrolled in more classes
  # than they initially requested.
  def overenrolled()
    @enrolled_courses.size() > @num_requests
  end

  # 'Enrolls' a student into courses, given as an array or a single
  # string. Adds the course to the array of courses the student is 
  # currently enrolled in. A reference to this student is also stored
  # in the enrolled_students array within that class.
  def enroll(courses, courses_hash)

    # Courses is an array.
    if courses.class() == Array
      courses.each { |course|
        @enrolled_courses.push(course)

        # Add reference to the course.
        courses_hash[course].enrolled_students().push(self)
        puts "#{self.student_id} enrolled in #{course}"
      }
    
    # Courses is a string.
    elsif courses.class() == String
      @enrolled_courses.push(courses)

      # Add reference to the course.
      courses_hash[courses].enrolled_students().push(self)
      puts "#{self.student_id} enrolled in #{courses}"

    end

  end

  # 'Unenrolls' a student from a course if they are still
  # overenrolled and enrolled in this course. Returns true 
  # if the student was unenrolled, false if the student was 
  # not. Different from being 'kicked'; unenrolling is used 
  # to manage students who are enrolled in too many courses 
  # from the start.
  def unenroll(course, courses_hash)

    # Ensure the student is still overenrolled and in this course
    if overenrolled() && @enrolled_courses.include?(course)

      # Remove the course and student from one another.
      @enrolled_courses.delete(course)
      courses_hash[course].enrolled_students().delete(self)

      # Indicates that the student was unenrolled.
      return true

    end

    # Indicates that this method call had no effect.
    return false

  end

  # 'Kicks' a student from a course. This action is performed
  # when a course is above its total maximum number of students.
  def kick(course, courses_hash)

    # Remove the course and student from one another.
    @enrolled_courses.delete(course)
    courses_hash[course].enrolled_students().delete(self)

  end

  # Returns an array of values to be written to CSV files.
  def to_csv()
    enrolled_string = ""
    reason_string = ""

    # Generate the string of enrolled courses or "None".
    @enrolled_courses.each { |course|
      enrolled_string += "#{course}, "
    }
    if not enrolled_string == ""
      enrolled_string = enrolled_string.chop.chop
    else
      enrolled_string = "None"
    end

    # Generate the string of reasons or "N/A".
    @reasons.each { |reason|
      puts reason
      reason_string += "#{reason} "
    }
    if not reason_string == ""
      reason_string = reason_string.chop
    else
      reason_string = "N/A"
    end

    # Return the CSV-formatted array representation of a Student.
    [@student_id, enrolled_string, reason_string]
  end

end