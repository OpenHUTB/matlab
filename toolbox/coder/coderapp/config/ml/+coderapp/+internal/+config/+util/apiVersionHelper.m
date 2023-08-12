function varargout = apiVersionHelper( mode, varargin )






R36
mode{ mustBeMember( mode, { 'record', 'test', 'testFile', 'get' } ) } = 'get'
end 
R36( Repeating )
varargin
end 

VERSION_FILE = fullfile( matlabroot, 'toolbox/coder/coderapp/config/api_version' );

switch mode
case 'record'
narginchk( 2, 2 );
dest = normalizePath( varargin{ 1 } );
folder = fileparts( dest );
if ~isfolder( folder )
mkdir( folder );
end 
copyfile( VERSION_FILE, dest, 'f' );
case 'test'
narginchk( 2, 2 );
varargout{ 1 } = strcmp( varargin{ 1 }, getApiVersion(  ) );
case 'testFile'
narginchk( 2, 2 );
varargout{ 1 } = strcmp( getApiVersion( varargin{ 1 } ), getApiVersion(  ) );
case 'get'
narginchk( 0, 1 );
varargout{ 1 } = getApiVersion(  );
end 


function version = getApiVersion( file )
if nargin == 0
file = VERSION_FILE;
else 
file = normalizePath( file );
end 
if isfile( file )
version = strtrim( fileread( file ) );
else 
version = '';
end 
end 
end 

function path = normalizePath( path )
if ~startsWith( path, matlabroot )
path = fullfile( matlabroot, path );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp3xYAp2.p.
% Please follow local copyright laws when handling this file.

