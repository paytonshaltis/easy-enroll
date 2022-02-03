# Student class for representing students
class Student

    # Attributes for a single Student
    attr_accessor :student_id, :student_year, :courses_taken, 
      :semesters_left, :num_prefs, :prefs
  
    # Initializes the Student using a row from the CSV file
    def initialize(student_info)
      @student_id = student_info[0]
      @student_year = student_info[1]
      @courses_taken = student_info[2].split(', ', -1) if student_info[2];
      @semesters_left = student_info[3]
      @num_prefs = student_info[4]
      @prefs = [student_info[5], student_info[6], student_info[7]]
    end

  end