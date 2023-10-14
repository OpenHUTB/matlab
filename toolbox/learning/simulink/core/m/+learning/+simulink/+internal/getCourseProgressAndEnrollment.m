function courses = getCourseProgressAndEnrollment( courseObj, requestEnrollment, requestProgress )

arguments
    courseObj
    requestEnrollment double = 0
    requestProgress double = 0
end

domain = learning.simulink.internal.getAcademyDomain(  );
endPoint = [ domain, '/service/v1/request' ];
account = struct( 'tokenName', 'MW_CU', 'tokenValue', courseObj.token );
auth = struct( 'mathworksAccount', account );

opts = weboptions(  ...
    'RequestMethod', 'post',  ...
    'MediaType', 'application/json',  ...
    'Timeout', 10,  ...
    'ContentType', 'json' );

emptyObj = struct(  );
messages = struct(  );

if requestEnrollment > 0
    messages.ListSelfPacedEnrollments = emptyObj;
end

if requestProgress > 0
    messages.ListSelfPacedCourseProgress = emptyObj;
end

assert( ~isempty( fieldnames( messages ) ), 'At least one field is required.' );
requestBody = struct( 'authentication', auth, 'messages', messages );

try
    [ serviceResponse ] = webwrite( endPoint, jsonencode( requestBody ), opts );
    courses = struct(  );
    if requestEnrollment > 0
        enrolledCourses = learning.simulink.internal.util.EntitlementUtils.getCourseEnrollment( serviceResponse, courseObj.courseCodes );
        courses.enrolledCourses = enrolledCourses;
    end

    if requestProgress > 0
        courseProgresses = learning.simulink.internal.util.EntitlementUtils.getCourseProgress( serviceResponse, courseObj.courseCodes );
        courses.courseProgresses = courseProgresses;
    end

catch
    courses = [  ];
end
end


