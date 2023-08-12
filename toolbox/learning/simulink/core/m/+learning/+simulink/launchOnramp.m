function launchOnramp( courseCode, chapter, lesson, section, token )





R36
courseCode char = 'simulink'
chapter double = 0
lesson double = 0
section double = 0
token char = ''
end 

if isequal( courseCode, 'simulink' )
[ isInstalled, addonID ] = learning.simulink.internal.isOnrampAddonInstalled;

if isInstalled

matlab.addons.disableAddon( addonID );
end 
end 




if ~isempty( token )
if learning.simulink.preferences.slacademyprefs.CourseMap( courseCode ).category == learning.simulink.preferences.Category.PAID
enrollmentReqObj = struct( 'token', token, 'courseCodes', [ courseCode ] );
enrollementInfo = sltemplate.internal.request.getCourseProgressAndEnrollment( enrollmentReqObj, 1, 0 );
if isempty( enrollementInfo ) || isempty( enrollementInfo.enrolledCourses )
sltemplate.internal.request.purchaseCourse( courseCode );
return 
end 
end 
end 

functionName = 'simulinkTraining';
functionPath = which( functionName, '-all' );


assert( ~isempty( functionPath ) );
assert( all( cell2mat( strfind( functionPath, fullfile( matlabroot, 'toolbox', 'learning', 'simulink', 'core', 'm', 'simulinkTraining' ) ) ) ) );

missingToolboxes = lAreToolboxesInstalled( courseCode );

[ licensesAreCheckedOut, uncheckedOutLicenses ] = learning.simulink.internal.checkoutLicense( courseCode );
if ~all( licensesAreCheckedOut )
firstUncheckedOutLicense = uncheckedOutLicenses{ 1 };
error( message( 'learning:simulink:resources:MissingLicense',  ...
firstUncheckedOutLicense,  ...
[ learning.simulink.preferences.slacademyprefs.CourseMap( courseCode ).CourseName, '.', newline, newline ],  ...
[ '"', learning.simulink.internal.getAcademyDomain(  ), '#simulink"' ] ) );
elseif ~isempty( missingToolboxes )
missingToolboxesString = [ newline, strjoin( missingToolboxes, newline ), newline, newline ];
error( message( 'learning:simulink:resources:MissingToolbox', learning.simulink.preferences.slacademyprefs.CourseMap( courseCode ).CourseName,  ...
missingToolboxesString, [ '"', learning.simulink.internal.getAcademyDomain(  ), '#simulink"' ] ) );
else 
simulinkTraining( courseCode, chapter, lesson, section );
end 

function missingToolboxes = lAreToolboxesInstalled( courseCode )
toolboxInfo = ver(  );
installedToolboxes = { toolboxInfo.Name };

requiredToolboxes = learning.simulink.preferences.slacademyprefs.CourseMap( courseCode ).ProductNames;



missingToolboxes = requiredToolboxes( ~ismember( requiredToolboxes, installedToolboxes ) );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp3H5wTo.p.
% Please follow local copyright laws when handling this file.

