# Course class for representing courses.
class Course

  # Class variables for all Course objects.
  @@total_courses = 0

  # Read / write instance variables from CSV.
  attr_accessor :course_number, :init_num_sections, :min, :max

  # Read / write instance variables NOT from CSV.
  attr_accessor :total_min, :total_max, :curr_num_sections,
    :enrolled_students

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
    update_totals()

    @@total_courses += 1

  end

  # Updates total min and max according to curr_num_sections.
  def update_totals()
    @total_min = @curr_num_sections * @min
    @total_max = @curr_num_sections * @max
  end

  # Returns the total number of courses available this semester.
  def Course.total_courses()
    @@total_courses
  end

  # Drops anywhere from 0 to all sections of a class based on the
  # current number of enrolled students. Returns true if all sections
  # of the course are to be dropped, and the course should be deleted
  # and all students dropped.
  def drop_sections()
  
    while enrolled_students.size() < total_min
      @curr_num_sections -= 1
      update_totals()
      puts "A section of #{course_number} was dropped due to low enrollment."
    end

    return @curr_num_sections == 0
  
  end

  # Drops all students from the course in the case that 0 sections can
  # run. The course is deleted from each student's array of courses.
  def drop_all_students(courses_hash)
    @enrolled_students.each { |student|
      student.drop(self.course_number(), "No sections of #{self.course_number()} could run because they could not be filled.", courses_hash)
    }
  end

  # Returns the number of overenrolled students currently enrolled
  # in this course.
  def num_overenrolled()
    
    count = 0
    enrolled_students.each { |student|
      if student.overenrolled()
        count += 1
      end
    }
    return count
  end

end