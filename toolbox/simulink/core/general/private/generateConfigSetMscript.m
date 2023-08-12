function r = generateConfigSetMscript( cs, filename, varargin )



r = true;
filename = loc_validateFileName( filename );

argName = cell( 1, 1 );
argValue = cell( 1, 1 );
hash = containers.Map;

for i = 1:length( varargin ) / 2
if ~isempty( varargin( 2 * i - 1 ) ) && ~strcmp( varargin( 2 * i - 1 ), '' ) ||  ...
~isempty( varargin( 2 * i ) ) && ~strcmp( varargin( 2 * i ), '' )
argName{ i } = varargin{ 2 * i - 1 };
argValue{ i } = varargin{ 2 * i };

if hash.isKey( argName{ i } )
msgId = 'Simulink:tools:badOutputRedundantArg';
DAStudio.error( msgId, argName{ i } );
else 
hash( argName{ i } ) = argValue{ i };
end 
end 
end 

len = length( argName );

conflictList = { { struct( 'name', '-format', 'value', 'MATLAB script' ), struct( 'name', '-comments', 'value', 'on' ) },  ...
{ struct( 'name', '-format', 'value', 'MATLAB function' ), struct( 'name', '-varname', 'value', '*' ) },  ...
{ struct( 'name', '-comments', 'value', 'on' ), struct( 'name', '-varname', 'value', '*' ) },  ...
 };


for i = 1:len
if ~isempty( argName{ i } ) &&  ...
~strcmpi( argName{ i }, '-format' ) &&  ...
~strcmpi( argName{ i }, '-comments' ) &&  ...
~strcmpi( argName{ i }, '-varname' ) &&  ...
~strcmpi( argName{ i }, '-update' ) &&  ...
~strcmpi( argName{ i }, '-encoding' ) &&  ...
~strcmpi( argName{ i }, '-timestamp' )
msgId = 'Simulink:tools:badOutputArgumentName';
DAStudio.error( msgId, argName{ i } );
end 
end 

for i = 1:length( conflictList )
conflict = conflictList{ i };

name1 = conflict{ 1 }.name;
name2 = conflict{ 2 }.name;

if hash.isKey( name1 ) && hash.isKey( name2 )
value1 = hash( name1 );
value2 = hash( name2 );

if ( strcmpi( value1, conflict{ 1 }.value ) || strcmpi( '*', conflict{ 1 }.value ) ) &&  ...
( strcmpi( value2, conflict{ 2 }.value ) || strcmpi( '*', conflict{ 2 }.value ) )
msgId = 'Simulink:tools:badOutputConflict';
DAStudio.error( msgId, name1, value1, name2, value2 );
end 
end 
end 

for i = 1:len
if isempty( argName{ i } ) && ~isempty( argValue{ i } )
msgId = 'Simulink:tools:badOutputArgumentName';
DAStudio.error( msgId, argName{ i } );
end 

if strcmpi( argName{ i }, '-comments' )
if ~strcmpi( argValue{ i }, 'on' ) &&  ...
~strcmpi( argValue{ i }, 'off' )
msgId = 'Simulink:tools:badOutputComments';
DAStudio.error( msgId, argValue{ i } );
end 
end 

if strcmpi( argName{ i }, '-format' )
if ~strcmpi( argValue{ i }, 'MATLAB script' ) &&  ...
~strcmpi( argValue{ i }, 'MATLAB function' )
msgId = 'Simulink:tools:badOutputFormat';
DAStudio.error( msgId, argValue{ i } );
end 
end 

if strcmpi( argName{ i }, '-varname' )
if ~isvarname( argValue{ i } )
msgId = 'Simulink:tools:badOutputVariableName';
DAStudio.error( msgId, argValue{ i } );
end 

if i <= 3
argName{ i + 1 } = '-format';
argValue{ i + 1 } = 'MATLAB script';
end 

end 

if strcmpi( argName{ i }, '-update' )
if ~strcmpi( argValue{ i }, 'true' ) &&  ...
~strcmpi( argValue{ i }, 'false' )
msgId = 'Simulink:tools:badOutputUpdate';
DAStudio.error( msgId, argValue{ i } );
end 
end 

end 

etm = configset.util.ExportToM( cs, filename, { argName, argValue } );
etm.saveToFile;

end 



function result = loc_validateFileName( name )
[ dir, filename, ext ] = fileparts( name );

if ~isempty( dir ) && ~exist( dir, 'dir' )
msgId = 'Simulink:tools:badOutputFileNameDirectory';
DAStudio.error( msgId, dir );
end 

isMFile = strcmp( ext, '.m' );
isMLXFile = strcmp( ext, '.mlx' );

if ~isempty( ext ) && ~( isMFile || isMLXFile )
msgId = 'Simulink:tools:badOutputFileNameExtension';
DAStudio.error( msgId, ext );
end 

if ~isvarname( filename )
msgId = 'Simulink:tools:badOutputFileName';
DAStudio.error( msgId, filename );
end 

if isMLXFile
filename = [ filename, '.mlx' ];
else 
filename = [ filename, '.m' ];
end 

if ~isempty( dir )
result = fullfile( dir, filename );
else 
result = filename;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpFzbDOw.p.
% Please follow local copyright laws when handling this file.

