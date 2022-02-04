# Student class for representing students
class Student

    # Attributes for a single Student.
    attr_accessor :student_id, :student_year, :courses_taken, 
      :semesters_left, :num_prefs, :prefs
  
    # Initializes the Student using a row from the CSV file.
    def initialize(student_info)

      # Straight from CSV file
      @student_id = student_info[0]
      @student_year = student_info[1]
      @semesters_left = student_info[3]
      @num_prefs = student_info[4]

      # Needs formatting
      @courses_taken = split_taken(student_info[2])
      @prefs = merge_prefs(student_info[5], student_info[6], student_info[7])

    end

    # Returns an array of Strings representing courses taken by
    # the student in the past.
    def split_taken(courses_taken)
      if courses_taken
        return courses_taken.split(", ")
      end
    end

    # Returns an array of Strings representing courses preferred
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

    # 'Enrolls' a student into a course. Adds the course to the 
    # array of courses the student is currently enrolled in.
    def enroll(course)
    end

    # 'Unenrolls' a student into a course. Different from being
    # 'dropped'; unenrolling is used to manage students who
    # are enrolled in too many courses.
    def unenroll(course)
    end

    # 'Drops' a student from a course. This action is performed
    # when classes exceed their maximum and is based on priority.
    def drop(course)
    end

    # The toString() method for neatly printing students. Prints
    # in CSV format for writing to output files.
    def to_s()
    end

  end