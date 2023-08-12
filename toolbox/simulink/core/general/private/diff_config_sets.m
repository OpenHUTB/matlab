function [ iseq, differences ] = diff_config_sets( cs1, cs2, format )


















differences = [  ];
[ iseq, diffs ] = isequal( cs1, cs2 );

if ~iseq
if isequal( format, 'string' )
outputStr = '';
for i = 1:length( diffs )
paramName = diffs{ i };
if isValidParam( cs1, paramName ) && isValidParam( cs2, paramName )
oldval = get_param( cs1, paramName );
newval = get_param( cs2, paramName );
if ischar( oldval )
oldvalstr = [ '"', oldval, '"' ];
elseif isnumeric( oldval ) && isscalar( oldval )
oldvalstr = num2str( oldval );
else 
oldvalstr = '[mxArray]';
end 
if ischar( newval )
newvalstr = [ '"', newval, '"' ];
elseif isnumeric( newval ) && isscalar( newval )
newvalstr = num2str( newval );
else 
newvalstr = '[mxArray]';
end 
outputStr = sprintf( [ outputStr, '"', paramName, '": old value (', oldvalstr,  ...
') -> new value (', newvalstr, ')\n' ] );
end 
end 
differences = outputStr;
else 
differences = diffs;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp7QUWyk.p.
% Please follow local copyright laws when handling this file.

