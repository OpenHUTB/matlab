function slshowallcaps( Action, libLists, libNames )





if nargin < 3
Action = 'Unknown';
end 

switch Action
case 'Unknown'
warning( message( 'Simulink:bcst:UseFromMenu' ) );
case 'LaunchHTML'

if isempty( find_system( 'SearchDepth', 0, 'CaseSensitive', 'off', 'Name', 'simulink' ) )
disp( DAStudio.message( 'Simulink:bcst:LoadingSL' ) );
load_system( 'simulink' );
end 
bcstMakeSlSupportTable( libLists, false, '*All*', libNames );
otherwise 
warning( message( 'Simulink:bcst:UnrecognizedAction', Action ) );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpsc1JOj.p.
% Please follow local copyright laws when handling this file.

