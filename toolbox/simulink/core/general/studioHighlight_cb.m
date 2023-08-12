function varargout = studioHighlight_cb( action, varargin )




switch action
case 'hilite'
block = varargin{ 1 };
unhiliteFcn = varargin{ 2 };
blockPathHandles = varargin{ 3 };

unhiliteFcn(  );
found = ~strcmp( get_param( block, 'HiliteAncestors' ), 'find' );

if found
try 
blockPathHandles = [ blockPathHandles( 1:end  - 1 ), block ];
blockPathStrings = arrayfun( @getfullname, blockPathHandles, 'UniformOutput', false );
destToHilite = Simulink.BlockPath( blockPathStrings );
catch 

destToHilite = block;
end 

hilite_system( destToHilite, 'find' );
end 

case 'getBlockPathHandles'
bp = varargin{ 1 };
handles = loc_getBlockPathHandles( bp );
varargout{ 1 } = handles;

case 'getBlockPathHandlesAsString'
bp = varargin{ 1 };
varargout{ 1 } = loc_getBlockPathHandlesAsString( bp );

case 'getStringForHandle'
h = varargin{ 1 };
varargout{ 1 } = loc_getStringForHandle( h );
end 
end 

function hStr = loc_getBlockPathHandlesAsString( blockPath )
handles = loc_getBlockPathHandles( blockPath );
hStr = '';
for i = 1:length( handles )
if ( ~isempty( hStr ) )
hStr = [ hStr, ', ' ];%#ok<AGROW>
end 

hStr = [ hStr, loc_getStringForHandle( handles( i ) ) ];%#ok<AGROW>
end 
hStr = [ '[', hStr, ']' ];
end 

function handles = loc_getBlockPathHandles( blockPath )
handles = [  ];
for i = 1:blockPath.getLength(  )
blockInPath = blockPath.getBlock( i );
handleInPath = get_param( blockInPath, 'Handle' );
handles( end  + 1 ) = handleInPath;%#ok<AGROW>
end 
end 


function hStr = loc_getStringForHandle( handle )
hStr = sprintf( '%.17g', handle );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpDOP6Gj.p.
% Please follow local copyright laws when handling this file.

