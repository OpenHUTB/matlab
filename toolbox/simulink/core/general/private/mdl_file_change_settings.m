function out = mdl_file_change_settings( option, in )











persistent handling_strings;
persistent handling_values;

if isempty( handling_strings )



handling_strings = {  ...
DAStudio.message( 'Simulink:util:MDLFileChangeWarning' ),  ...
DAStudio.message( 'Simulink:util:MDLFileChangeError' ),  ...
DAStudio.message( 'Simulink:util:MDLFileChangeReload' ),  ...
DAStudio.message( 'Simulink:util:MDLFileChangePrompt' ) ...
 };
handling_values = {  ...
'warning',  ...
'error',  ...
'close',  ...
'dialog' };

allowed_values = rootobjectenum( 'MDLFileChangedOnDiskHandling' );
if ~all( ismember( handling_values, allowed_values ) )

error( message( 'Simulink:util:IncompatibleVersion' ) );
end 
end 

if nargin > 1

switch option
case 'Handling'

[ x, ind ] = ismember( in, handling_strings );
if ~x
error( message( 'Simulink:util:InvalidHandlingString' ) );
end 

v = handling_values{ ind };

set_param( 0, 'MDLFileChangedOnDiskHandling', v );
otherwise 
in = strcmp( in, 'on' );
v = get_param( 0, 'MDLFileChangedOnDiskChecks' );
v.( option ) = in;
if ~isfield( v, option )
error( message( 'Simulink:util:InvalidOption' ) );
else 
set_param( 0, 'MDLFileChangedOnDiskChecks', v );
end 
end 
else 

switch option
case 'Handling'
v = get_param( 0, 'MDLFileChangedOnDiskHandling' );
[ x, ind ] = ismember( v, handling_values );
if ~x
warning( message( 'Simulink:util:InvalidMDLFileChangedOnDiskHandlingValue', v ) );
ind = 1;
end 
current = handling_strings( ind );


out = [ handling_strings, current ];
otherwise 
v = get_param( 0, 'MDLFileChangedOnDiskChecks' );
if isfield( v, option )
out = v.( option );
if out
out = 'on';
else 
out = 'off';
end 
else 
error( message( 'Simulink:util:InvalidOption' ) );
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpa5DXWG.p.
% Please follow local copyright laws when handling this file.

