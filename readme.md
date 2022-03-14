#### Payton Shaltis CSC-415-01
# Assignment 1 - EasyEnroll

## (NEW) Resubmission Revisions:
- Removed 'magic numbers' from the 'student.rb' file. These were initially used to calculate student priority and have since been replaced with descriptive constants.
-
-
-
-

## Files in the Repository:
- `easyenroll.rb` - The 'driver' file with the main method. Contains the code for the actual scheduling algorithm itself.
- `student.rb` - The implementation of the 'Student' class for representing individual student instances.
- `course.rb` - The implementation of the 'Course' class for representing individual course instances.

## Instructions for Use:
To use the application, you should first ensure that your file of course constraints and your file of student preferences are located in the same directory as the three Ruby source files.

Next, run the driver file by using the command `ruby easyenroll.rb`. You will be prompted to enter the name of the course constraints file, the name of the student preferences file, the name of the course enrollment output file, and the name of the student enrollment output file, IN THAT ORDER. If you enter an input or output filename twice, or enter an invalid filename, or a non-existent input filename, or even switch the order of the input files, watch for the prompts on the screen: you will be required to reenter information until you enter it correctly.

```
Enter course constraints input file name:
> course_constraints.csv
Enter student preferences input file name:
> student_prefs.csv
Enter course output file name (will be overwritten if it already exists):
> output1.csv
Enter student output file name (will be overwritten if it already exists):
> output2.csv

=================
ENROLLEMNT TOTALS
...
...
...
```

The program will run, and the output files will be created with the names that you have given them. Note that if you want them to have the `.csv` extension, you must explicitly include it in the name of your output file.

Additionally, some information will be printed to the standard output that gives some insight as to how well the scheduling algorithm was able to place students into courses.

## Assumptions Made:

### Input Files
* The only courses that a student will enter in their previously taken courses or their preferences will be courses included in the course constraints input file. If a student _does_ include a course not being offered in their preferences, it is treated the same as an "N/A".
* Duplicate courses previously taken are handled, and will only count as a single course. Duplicate courses included in a student's preferences are _also_ only counted once; the other is treated as an "N/A".
* No two students will have the same student ID. In the case of my program's implementation, this will not break the application, but it will be difficult to determine which ID is referring to which student when looking at the output files.

### Output Files
* If a course was listed as having zero sections in the course constraints file, this course is _not_ included in the course enrollment output file. This is because there _are_ no sections of the course to report on, and they wouldn't have any students anyway.

### Priority
* The priority system is a _weighted_ priority system, in that the different priority requirements mentioned in the Assignment 1 description are assigned different weights in determining a student's overall priority. 
    * For example, the fact that student is a Senior is weighted more heavily than the fact that the student requested three preferences. 
    * You can view the exact weights in the `student.rb` source code, but they are modular enough to enable change in the future.
* A student being enrolled in one course is _always_ of higher priority than _any other_ student being enrolled in two, even if they have a higher priority.
    * For example, a Sophomore may get into a course before a Senior if the Senior already has one enrollment already but the Sophomore has none. If both the Senior _and_ the Sophomore are already enrolled in one course each, however, then the Senior is prioritized and will get the second course.

## Known Bugs, Issues or Limitations
From my tests, I have not encountered any bugs with the code at the current version of the program.
