function [ oFile, oFoundFile, oFoundBuiltIn ] = sl_get_file_ignoring_builtins( iFile, varargin )










oFile = iFile;
oFoundFile = false;
oFoundBuiltIn = false;
checkExtensions = {  };
if nargin > 1
checkExtensions = varargin{ : };
end 



pathtofile = fileparts( iFile );
if ( isempty( pathtofile ) )


files = which( iFile, '-all' );
ind = 1;
while ind <= size( files, 1 )
aFile = char( files( ind ) );
[ ~, ~, ext ] = fileparts( aFile );

if strfind( aFile, 'built-in' )
oFoundBuiltIn = true;
ind = ind + 1;
elseif ~isempty( checkExtensions ) && ~any( strcmp( ext, checkExtensions ) )
ind = ind + 1;
else 


oFoundFile = ~isempty( dir( aFile ) );
oFile = aFile;
break ;
end 
end 
else 
oFoundFile = ~isempty( dir( iFile ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpVLNmg_.p.
% Please follow local copyright laws when handling this file.

