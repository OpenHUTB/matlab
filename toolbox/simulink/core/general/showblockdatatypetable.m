function showblockdatatypetable( Action )





if nargin == 0
Action = 'LaunchHTML';
end 

switch Action
case 'LaunchHTML'

if isempty( find_system( 'SearchDepth', 0, 'CaseSensitive', 'off', 'Name', 'simulink' ) )
disp( DAStudio.message( 'Simulink:bcst:LoadingSL' ) );
load_system( 'simulink' );
end 
bcstMakeSlSupportTable( 'simulink' );
otherwise 
warning( message( 'Simulink:bcst:UnrecognizedAction', Action ) );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpg6rcxG.p.
% Please follow local copyright laws when handling this file.

