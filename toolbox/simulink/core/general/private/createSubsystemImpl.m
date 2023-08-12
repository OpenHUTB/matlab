function createSubsystemImpl( varargin )






















handles = [  ];
subsystemName = [  ];
makeNameUnique = true;

index = 1;
if nargin > 0
arg = loc_getArg( varargin( 1 ) );
if ~ischar( arg ) && ~isstring( arg )
handles = arg;
index = 2;
end 
end 


while index <= nargin
key = loc_getArg( varargin( index ) );
if nargin > index
value = loc_getArg( varargin( index + 1 ) );
else 
value = [  ];
end 

if strcmpi( key, 'Name' )
if ischar( value ) || isstring( value )
subsystemName = value;
else 
DAStudio.error( 'glee_util:messages:GenericError' );
end 
elseif strcmpi( key, 'MakeNameUnique' )
if strcmpi( value, 'on' ) || strcmpi( value, 'off' )
makeNameUnique = strcmpi( value, 'on' );
else 
DAStudio.error( 'glee_util:messages:GenericError' );
end 

else 
DAStudio.error( 'glee_util:messages:GenericError' );
end 
index = index + 2;
end 

if isempty( handles )
selected = find_system( gcs, 'SearchDepth', 1, 'Selected', 'on' );
gcsIndex = find( ismember( selected, gcs ) == 1 );
if ( gcsIndex )
selected( gcsIndex ) = [  ];
end 
handles = cell2mat( get_param( selected, 'Handle' ) )';

if ~isempty( selected )
selectedNoteHandles = find_system( gcs, 'SearchDepth', 1, 'FindAll', 'on', 'Selected', 'on', 'type', 'annotation' );
handles = [ handles, selectedNoteHandles' ];
end 
end 

handlesSize = size( handles );
if ( handlesSize( 1 ) > 1 )
handles = handles';
end 

obj = get_param( bdroot( gcs ), 'Object' );
if isempty( subsystemName )
obj.localCreateSubSystem( handles );
else 
obj.localCreateNamedSubSystem( handles, subsystemName, makeNameUnique );
end 

end 

function arg = loc_getArg( argIn )
arg = argIn;
if ~isempty( argIn ) && iscell( argIn )
if isstring( argIn{ 1 } )
arg = argIn{ 1 };
else 
arg = cell2mat( argIn );
end 
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpx2N2H8.p.
% Please follow local copyright laws when handling this file.

