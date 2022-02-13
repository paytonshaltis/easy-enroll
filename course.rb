# Name: Payton Shaltis
# Project name: Assignment 1: EasyEnroll
# Description: An algorithm that determines the best college course enrollment strategy according to a set of student preferences and course constraings.
# Filename: course.rb
# Description: Contains the class implementation for representing Courses.
# Last modified on: February 12, 2022

# Course class for representing courses.
class Course

  # Class variables for all Course objects.
  @@total_courses = 0

  # Read / write instance variables from CSV.
  attr_accessor :course_number, :init_num_sections, :min, :max

  # Read / write instance variables NOT from CSV.
  attr_accessor :curr_num_sections, :enrolled_students

  # Initializes a Course using a row from the CSV file.
  def initialize(course_info)
    
    # Straight from CSV file.
    @course_number = course_info[0]
    @init_num_sections = course_info[1].to_i()
    @curr_num_sections = course_info[1].to_i()
    @min = course_info[2].to_i()
    @max = course_info[3].to_i()

    # Need to calculate other course data.
    @enrolled_students = []
    @@total_courses += 1

  end

  # Returns the total minimum students across all course sections.
  def total_min()
    @curr_num_sections * @min
  end

  # Returns the total maximum students across all course sections.
  def total_max()
    @curr_num_sections * @max
  end

  # Returns the total number of courses available this semester.
  def Course.total_courses()
    @@total_courses
  end

  # Returns the number of overenrolled students in this course.
  def num_overenrolled_students()
    count = 0
    enrolled_students.each { |student|
      if student.overenrolled()
        count += 1
      end
    }
    return count
  end

  # Returns a String representing a reason why a student could not
  # be enrolled in this course.
  def get_reason()
    
    # If the course initially had 0 sections.
    if @curr_num_sections == 0
      return "#{@course_number}: No sections running this semester."
    
    # If all sections of a course filled up.
    elsif @enrolled_students.size() == (@init_num_sections * @max)
      return "#{@course_number}: All sections filled up with students of higher priority."

    # Otherwise, some sections of the course aren't offered due to low
    # enrollment in those courses.
    else
      return "#{@course_number}: Some sections filled up with students of higher priority, some sections could not be run due to low enrollemnt."
    end

  end
  
  # Returns an array of values to be written to CSV files. Only returns
  # values for the section specified by the sole parameter.
  def to_csv(section_number)
    
    student_ids = "student ids here"
    seats_filled = 5
    open_seats = @max - seats_filled

    [@course_number, section_number, student_ids, seats_filled, open_seats, "Yes"]
  end

end