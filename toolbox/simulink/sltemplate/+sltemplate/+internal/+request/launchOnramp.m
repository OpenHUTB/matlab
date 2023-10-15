function launchOnramp( courseCode, chapter, lesson, section, token )

arguments
    courseCode char = 'simulink'
    chapter double = 0
    lesson double = 0
    section double = 0
    token char = ''
end

try
    learning.simulink.launchOnramp( courseCode, chapter, lesson, section, token );
catch causeException
    errorString = 'sltemplate:Gallery:FailedToLaunchOnramp';
    courseName = learning.simulink.preferences.slacademyprefs.CourseMap( courseCode ).CourseName;

    exceptionMessage = strrep( causeException.message, '\', '\\' );
    baseException = MException( errorString,  ...
        [ message( errorString, courseName ).getString(  ), ' ', exceptionMessage ] );
    throw( baseException )
end
