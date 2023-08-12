



function launchEnrolledCourse( token, courseCode, chapter, lesson, section )

R36
token char
courseCode char
chapter double = 0
lesson double = 0
section double = 0
end 

assert( ~isempty( token ), 'User token is required.' );
assert( ~isempty( courseCode ), 'Course code is required.' );

userEnrolledCourse = checkUserCourseEnrollment( token, courseCode );
if true( userEnrolledCourse )
simulinkTraining( courseCode, chapter, lesson, section );
else 

web( 'https://www.mathworks.com/services/training.html' );
end 


function userEnrolledCourse = checkUserCourseEnrollment( token, courseCode )
userEnrolledCourse = false;
courses = sltemplate.internal.request.getCourseProgressAndEnrollment( token, true, false );
enrollmentCount = size( courses.ListSelfPacedEnrollmentsResponse.selfPacedEnrollments, 1 );

for k = 1:enrollmentCount
course = courses.ListSelfPacedEnrollmentsResponse.selfPacedEnrollments( k );
if strcmp( course.selfPacedCourseId.code, courseCode )
userEnrolledCourse = true;
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpQdwmuT.p.
% Please follow local copyright laws when handling this file.

