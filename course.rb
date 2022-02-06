# Course class for representing courses.
class Course

  # Read / write instance variables from CSV.
  attr_accessor :course_number, :num_sections, :min, :max

  # Read / write instance variables NOT from CSV.
  attr_accessor :total_min, :total_max, :enrolled_students,
    :num_overenrolled

  # Initializes a Course using a row from the CSV file.
  def initialize(course_info)
    
    # Straight from CSV file.
    @course_number = course_info[0]
    @num_sections = course_info[1].to_i()
    @min = course_info[2].to_i()
    @max = course_info[3].to_i()

    # Need to calculate other course data.
    @enrolled_students = []
    @num_overenrolled = 0
    update_totals()

  end

  # Updates total min and max according to num_sections.
  def update_totals()
    @total_min = @num_sections * @min
    @total_max = @num_sections * @max
  end

end