function slprofile_hilite_system( varargin )
























if nargin == 1 && ischar( varargin{ 1 } )
decodePath = 0;
sysStr = varargin{ 1 };
elseif nargin == 2 &&  ...
strcmp( varargin{ 1 }, 'encoded-path' ) &&  ...
ischar( varargin{ 1 } )
decodePath = 1;
sysStr = varargin{ 2 };
else 
DAStudio.error( 'Simulink:tools:slprof_hilite_usage' );
end 





if decodePath

encodedPathStr = sysStr;
encodedPathStrLen = length( encodedPathStr );
sysStr = '';

newline = sprintf( '\n' );
tab = sprintf( '\t' );

i = 1;
j = 1;
while i <= encodedPathStrLen
if encodedPathStr( i ) == '\'
i = i + 1;
switch encodedPathStr( i )
case '\'
sysStr( j ) = '\';
case 's'
sysStr( j ) = ' ';
case 't'
sysStr( j ) = tab;
case 'n'
sysStr( j ) = newline;
case 'T'
sysStr( j ) = '''';
case 'Q'
sysStr( j ) = '"';
case 'q'
sysStr( j ) = '?';
otherwise 
DAStudio.error( 'Simulink:tools:badEncPath' );
end 
else 
sysStr( j ) = encodedPathStr( i );
end 
j = j + 1;
i = i + 1;
end 
end 





slashes = findstr( '/', sysStr );




slashesLen = length( slashes );
rmSlashes = [  ];

i = 1;
while i < slashesLen
if slashes( i ) == slashes( i + 1 ) - 1
rmSlashes( end  + 1:end  + 2 ) = [ i, i + 1 ];
i = i + 2;
else 
i = i + 1;
end 
end 

slashes( rmSlashes ) = [  ];

if ~isempty( slashes )
model = sysStr( 1:slashes( 1 ) - 1 );
block = sysStr;
else 
model = sysStr;
block = [  ];
end 




if ~bdIsLoaded( model )
open_system( model );
end 





slprofile_unhilite_system( model );

if ~isempty( block )
hilite_system( block );
else 
open_system( model );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpclsUPf.p.
% Please follow local copyright laws when handling this file.

