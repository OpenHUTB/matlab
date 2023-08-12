classdef ( CompatibleInexactProperties = true )VirtualRealityAnimation < Aero.animation.internal.VideoAnimation






properties ( Dependent, SetAccess = protected, Transient, SetObservable, Hidden )
VRAnimTimer;
end 

methods 
function set.VRAnimTimer( h, value )
h.AnimationTimer = value;
end 
function value = get.VRAnimTimer( h )
value = h.AnimationTimer;
end 
end 

properties ( Transient, SetObservable )
Name = '';
VRWorld = [  ];
VRWorldFilename( 1, : )char = '';
VRWorldOldFilename = {  };
VRWorldTempFilename( 1, : )char = '';
VRFigure = [  ];
Nodes = {  };
Viewpoints = {  };


TCurrent{ validateattributes( TCurrent, { 'numeric' }, { 'scalar' }, '', 'TCurrent' ) } = 0;
ShowSaveWarning( 1, 1 )logical = 1;
end 

methods 
function h = VirtualRealityAnimation( varargin )


if ~builtin( 'license', 'test', 'Aerospace_Toolbox' )
error( message( 'aero:licensing:noLicenseVRA' ) );
end 

if ~builtin( 'license', 'checkout', 'Aerospace_Toolbox' )
return ;
end 

end 

end 

methods 

function delete( h )

h.ShowSaveWarning = 0;
h.legacyDelete(  );

end 

end 

methods 
function value = get.ShowSaveWarning( obj )

value = double( obj.ShowSaveWarning );
end 
end 

methods 

function addNode( h, node_name, source )
R36
h
node_name( 1, 1 )string
source( 1, 1 )string{ Aero.internal.validation.mustBeFile( source ) }
end 


if ~source.endsWith( ".wrl" )
error( message( 'aero:vranim:invalidExtension' ) );
end 


node_type = 'Transform';




newNode1 = createNode( h, h.VRWorld, node_name, node_type );


newNode2 = createNode( h, newNode1, 'children', node_name + "_Inline", 'Inline' );


setfield( newNode2, 'url', source );%#ok<SFLD,STFLD>


saveWorld( h, '-nothumbnail' );

end 


function addRoute( h, nodeOut, eventOut, nodeIn, eventIn )

checkNodes(  );


save( h.VRWorld, h.VRWorldTempFilename, '-nothumbnail' );


fid = fopen( h.VRWorldTempFilename, 'a' );


routeStatement = [ 'ROUTE ', nodeOut, '.', eventOut, ' TO ', nodeIn, '.', eventIn ];


fprintf( fid, '\n%s', routeStatement );
fclose( fid );


saveWorld( h, '-nothumbnail' );


function checkNodes



nodeToTest = { nodeOut, nodeIn };
eventToTest = { eventOut, eventIn };
nodeInfo = h.nodeInfo;
for m = 1:2
flag = 0;

for n = 1:numel( h.Nodes )
if strcmp( nodeToTest( m ), nodeInfo( 2, n ) )
flag = 1;

try 
getfield( h.Nodes{ n }.VRNode, eventToTest{ m } );%#ok<GFLD>
continue 
catch invalidEvent
newExc = MException( 'aero:vranim:invalidEvent', getString( message( 'aero:vranim:invalidEvent', eventToTest{ m } ) ) );
newExc = newExc.addCause( invalidEvent );
throw( newExc );
end 
end 
end 

if flag == 0
error( message( 'aero:vranim:invalidNode', nodeToTest{ m } ) );
end 
end 

end 

end 


function addViewpoint( h, parent_node, parent_field, node_name, varargin )


narginchk( 4, 7 );


v = Aero.Viewpoint;




v.Node = createNode( h, parent_node, parent_field, node_name, 'Viewpoint' );


v.Name = node_name;

if ~isempty( varargin )

if numel( varargin ) == 3
v.Node.description = varargin{ 1 };
v.Node.position = varargin{ 2 };
v.Node.orientation = varargin{ 3 };
elseif numel( varargin ) == 2
v.Node.description = varargin{ 1 };
v.Node.position = varargin{ 2 };
elseif numel( varargin ) == 1
v.Node.description = varargin{ 1 };
else 

end 
end 



h.Viewpoints{ end  + 1 } = v;


saveWorld( h, '-nothumbnail' );

end 


function initialize( h, varargin )


idx = 1;
w = waitbar( 0, 'Initializing...' );
set( w, 'Name', 'Virtual Reality Animation' );
waitbarFcn(  );


waitbarFcn(  );
saveInformation(  );


waitbarFcn(  );
cleanObject(  );


waitbarFcn(  );
if ~isempty( h.VRFigure ) && isvalid( h.VRFigure )
close( h.VRFigure );
end 


waitbarFcn(  );
if ~isempty( h.VRWorldFilename )
h.VRWorld = vrworld( h.VRWorldFilename );
else 
close( w );
error( message( 'aero:vranim:noWorldSpecified' ) );
end 


try 

open( h.VRWorld );
catch MEinvalidWorld
close( w );
newExc = MException( 'aero:vranim:invalidWorld', getString( message( 'aero:vranim:invalidWorld' ) ) );
newExc = newExc.addCause( MEinvalidWorld );
throw( newExc );
end 



if isempty( h.VRWorldTempFilename )
createTempFilename(  );
end 


waitbarFcn(  );
allNodes = nodes( h.VRWorld );



waitbarFcn(  );
h.VRFigure = vrfigure( h.VRWorld );





waitbarFcn(  );
for q = 1:numel( allNodes )
h.Nodes{ q } = Aero.Node;
h.Nodes{ q }.VRNode = allNodes( q );
h.Nodes{ q }.Name = get( allNodes( q ), 'Name' );


if strcmp( get( allNodes( q ), 'Type' ), 'Viewpoint' )
h.Viewpoints{ end  + 1 } = Aero.Viewpoint;
h.Viewpoints{ end  }.Node = allNodes( q );
h.Viewpoints{ end  }.Name = get( allNodes( q ), 'Name' );
end 
end 


waitbarFcn(  );
if ~exist( 'savedInfo', 'var' )
savedInfo = {  };
end 
if ~exist( 'savedVRFigure', 'var' )
savedVRFigure = [  ];
end 
resetInformation( savedInfo, savedVRFigure );

waitbarFcn(  )

function waitbarFcn(  )


persistent waitbarUpdate

if idx == 1
waitbarUpdate = {  ...
@(  )waitbar( 0.00, w, 'Initializing...' ); ...
@(  )waitbar( 0.05, w, 'Saving previous node information if it exists...' ); ...
@(  )waitbar( 0.10, w, 'Clearing previous node information if it exists...' ); ...
@(  )waitbar( 0.15, w, 'Closing existing figure...' ); ...
@(  )waitbar( 0.20, w, 'Creating vrworld...' ); ...
@(  )waitbar( 0.40, w, 'Finding nodes in vrworld...' ); ...
@(  )waitbar( 0.60, w, 'Create new vrfigure...' ); ...
@(  )waitbar( 0.70, w, 'Create Node objects' ); ...
@(  )waitbar( 0.90, w, 'Resetting previous data if it existed...' ); ...
@(  )close( w ); };
end 
waitbarUpdate{ idx }(  );
idx = idx + 1;

end 

function saveInformation(  )


n = numel( h.Nodes );


savedInfo = cell( n, 4 );

for k = 1:n
name = get( h.Nodes{ k }.VRNode, 'Name' );












if ~strcmp( func2str( h.Nodes{ k }.CoordTransformFcn ), 'nullCoordTransform' )
savedInfo{ k, 1 } = { name, h.Nodes{ k }.CoordTransformFcn };
end 

if strcmpi( h.Nodes{ k }.TimeSeriesSourceType, 'timeseries' )
if h.Nodes{ k }.TimeSeriesSource.Length ~= 0
savedInfo{ k, 2 } = { name, h.Nodes{ k }.TimeSeriesSource };
end 
else 
if ~isempty( h.Nodes{ k }.TimeSeriesSource )
savedInfo{ k, 2 } = { name, h.Nodes{ k }.TimeSeriesSource };
end 
end 
if ~strcmp( h.Nodes{ k }.TimeSeriesSourceType, 'Array6DoF' )
savedInfo{ k, 3 } = { name, h.Nodes{ k }.TimeSeriesSourceType };
end 
if ~strcmp( func2str( h.Nodes{ k }.TimeSeriesReadFcn ), 'interp6DoFArrayWithTime' )
savedInfo{ k, 4 } = { name, h.Nodes{ k }.TimeSeriesReadFcn };
end 

end 

m = numel( h.VRFigure );

if ( m > 0 ) && ( isempty( h.VRWorldOldFilename ) || ~any( strcmpi( h.VRWorldFilename, h.VRWorldOldFilename ) ) )
if isvalid( h.VRFigure )
savedVRFigure = get( h.VRFigure );

savedVRFigure = rmfield( savedVRFigure, { 'CameraDirectionAbs', 'CameraPositionAbs', 'CameraUpVectorAbs', 'World' } );
else 
savedVRFigure = struct( [  ] );
end 
else 
savedVRFigure = struct( [  ] );
end 

end 

function cleanObject


n = numel( h.Nodes );








if ~isempty( h.VRWorld ) && isvalid( h.VRWorld )
for i = 1:get( h.VRWorld, 'OpenCount' )

while isopen( h.VRWorld )
close( h.VRWorld );
end 


if ~isopen( h.VRWorld )
delete( h.VRWorld );
end 
end 
end 






for m = 1:n
if isvalid( h.Nodes{ m }.VRNode )
delete( h.Nodes{ m }.VRNode );
end 
end 
h.Nodes( : ) = [  ];

end 

function resetInformation( savedInfo, savedVRFigure )


n = numel( h.Nodes );

for p = 1:size( savedInfo, 1 )
if ~isempty( savedInfo{ p, 1 } )
for i = 1:n

if strcmp( get( h.Nodes{ i }.VRNode, 'Name' ), savedInfo{ p, 1 }{ 1 } )
h.Nodes{ i }.CoordTransformFcn = savedInfo{ p, 1 }{ 2 };
end 
end 
end 
if ~isempty( savedInfo{ p, 2 } )
for i = 1:n

if strcmp( get( h.Nodes{ i }.VRNode, 'Name' ), savedInfo{ p, 2 }{ 1 } )
h.Nodes{ i }.TimeSeriesSource = savedInfo{ p, 2 }{ 2 };
end 
end 
end 
if ~isempty( savedInfo{ p, 3 } )
for i = 1:n

if strcmp( get( h.Nodes{ i }.VRNode, 'Name' ), savedInfo{ p, 3 }{ 1 } )
h.Nodes{ i }.TimeSeriesSourceType = savedInfo{ p, 3 }{ 2 };
end 
end 
end 
if ~isempty( savedInfo{ p, 4 } )
for i = 1:n

if strcmp( get( h.Nodes{ i }.VRNode, 'Name' ), savedInfo{ p, 4 }{ 1 } )
h.Nodes{ i }.TimeSeriesReadFcn = savedInfo{ p, 4 }{ 2 };
end 
end 
end 
end 

m = numel( h.VRFigure );
if m > 0
if ~isempty( savedVRFigure )
savedFields = fieldnames( savedVRFigure );
newFields = fieldnames( get( h.VRFigure ) );
for p = 1:numel( newFields )

index = strcmpi( newFields{ p }, savedFields );

if any( index )

if ischar( get( h.VRFigure, newFields{ p } ) ) || isstring( get( h.VRFigure, newFields{ p } ) )
condition = ~strcmpi( get( h.VRFigure, newFields{ p } ), savedVRFigure.( savedFields{ index } ) );
else 
condition = any( get( h.VRFigure, newFields{ p } ) ~= savedVRFigure.( savedFields{ index } ) );
end 


if condition
set( h.VRFigure, newFields{ p }, savedVRFigure.( savedFields{ index } ) );
end 
end 
end 
end 
end 

end 

function createTempFilename



[ pathstr, name ] = fileparts( h.VRWorldFilename );



if ~isempty( pathstr ) || isfile( h.VRWorldFilename )
h.VRWorldTempFilename = fullfile( pathstr, "tempVRAnimFile" + floor( rand * 10000 ) + ".wrl" );


elseif ~isempty( name )
fileloc = which( name );


if ~isempty( fileloc )
pathstr = fileparts( fileloc );
h.VRWorldTempFilename = fullfile( pathstr, "tempVRAnimFile" + floor( rand * 10000 ) + ".wrl" );
end 


else 
error( message( 'aero:vranim:createTempFile' ) )
end 
end 

end 


function varargout = nodeInfo( h )

narginchk( 0, 1 );

N = cell( 1, numel( h.Nodes ) );

numNodes = 1:numel( h.Nodes );

for k = numNodes
N{ 1, k } = k;
N{ 2, k } = h.Nodes{ k }.Name;
N{ 3, k } = get( h.Nodes{ k }.VRNode, 'Type' );

end 

if nargout == 0
fprintf( '\nNode Information\n' )
for k = numNodes
fprintf( '%d\t%s\n', N{ 1, k }, N{ 2, k } );
end 
end 

if nargout == 1
varargout = { N };
end 

end 


function play( h, varargin )


if isempty( h.Nodes )
warning( message( 'aero:vranim:noNodes' ) );
return ;
end 


nodesWithTimeData = [  ];
for k = 1:numel( h.Nodes )

if strcmpi( h.Nodes{ k }.TimeSeriesSourceType, 'timeseries' )
if h.Nodes{ k }.TimeSeriesSource.Length ~= 0
nodesWithTimeData = 1;
break 
end 
else 
if ~isempty( h.Nodes{ k }.TimeSeriesSource )
nodesWithTimeData = 1;
break 
end 
end 
end 
if isempty( nodesWithTimeData )
warning( message( 'aero:vranim:noTimeseriesSource' ) );
return ;
end 


oldTimer = timerfind;

if ~isempty( oldTimer )
try 
oldTimer = oldTimer( strcmp( oldTimer.Name, 'VRAnimTimer' ) );
while any( isvalid( oldTimer ) )

end 
catch invalidVRAnimTimer %#ok<NASGU>




end 
end 

if isempty( h.VRFigure ) || ~isvalid( h.VRFigure )
warning( message( 'aero:vranim:nothingToAnimate' ) );
h.initialize(  );
end 

if ~isfinite( h.TStart ) || ~isfinite( h.TFinal )
locStartStopTimeHeuristic( h );
else 
locStartStopTimeValidate( h );
end 

if h.VideoRecord == "scheduled"
setNonFiniteVideoTime( h );
validateVideoStartStopTime( h );
end 





timePace = ceil( 1000 / h.FramesPerSecond ) / 1000;

timeAdvance = h.TimeScaling * timePace;


if ( abs( ( h.TimeScaling / h.FramesPerSecond ) - timeAdvance ) / timeAdvance > 0.15 )
warning( message( 'aero:vranim:timePace', sprintf( '%5.3f', timePace ),  ...
sprintf( '%d', 1 / timePace ) ) );
end 



h.VRAnimTimer = timer( 'Name', 'VRAnimTimer' );




h.VRAnimTimer.BusyMode = 'drop';






h.VRAnimTimer.ErrorFcn = { @timerCallbackFcn, h };



h.VRAnimTimer.ExecutionMode = 'fixedRate';
h.VRAnimTimer.Period = timePace;
h.VRAnimTimer.StartFcn = { @timerCallbackFcn, h, h.tStart };
h.VRAnimTimer.StopFcn = { @timerCallbackFcn, h, h.tFinal };










h.VRAnimTimer.TasksToExecute = ceil( ( h.TFinal - h.TStart ) / ( h.TimeScaling * timePace ) ) + 1;
h.VRAnimTimer.TimerFcn = { @timerCallbackFcn, h, timeAdvance };


videoObj = [  ];


h.VRAnimTimer.UserData = { h.TStart;videoObj };




start( h.VRAnimTimer );

end 


function h = removeNode( h, node )


if isnumeric( node ) && ( numel( node ) > 1 )
error( message( 'aero:vranim:multipleRemoveNodes' ) );
end 

n = numel( h.Nodes );


if ischar( node ) || isstring( node )

nodesToDelete = [  ];

for k = 1:n
if strcmp( node, h.Nodes{ k }.Name ) || strcmp( [ node, '_Inline' ], h.Nodes{ k }.Name )

delete( h.Nodes{ k }.VRNode )

nodesToDelete( end  + 1 ) = k;%#ok<AGROW>
end 
end 
if ~isempty( nodesToDelete )

h.Nodes( nodesToDelete ) = [  ];
else 
error( message( 'aero:vranim:charNodeToRemoveNotFound' ) );
end 


elseif isnumeric( node ) && ( node <= n ) && ( node > 0 )


nodeName = h.Nodes{ node }.name;


for k = 1:numel( h.Nodes )
if strcmp( [ nodeName, '_Inline' ], h.Nodes{ k }.Name )

delete( h.Nodes{ k }.VRNode )

h.Nodes( k ) = [  ];
end 
end 



delete( h.Nodes{ node }.VRNode );


h.Nodes( node ) = [  ];

else 
error( message( 'aero:vranim:invalidNodeToRemove' ) );
end 


saveWorld( h, '-nothumbnail' );

end 


function removeViewpoint( h, node )

h.removeNode( node );

end 


function saveas( h, name, varargin )


narginchk( 2, 3 );

if ( ~ischar( name ) && ~isstring( name ) ) || isempty( name )
error( message( 'aero:vranim:invalidFilename' ) );
end 


if isempty( varargin )
saveWorld( h, name );
else 
saveWorld( h, name, varargin{ 1 } );
end 

end 


function h = updateNodes( h, t )


h.TCurrent = t;

if isvalid( h.VRFigure )

for k = 1:numel( h.Nodes )

if strcmpi( h.Nodes{ k }.TimeSeriesSourceType, 'timeseries' )
if h.Nodes{ k }.TimeSeriesSource.Length ~= 0
h.Nodes{ k }.update( t );
end 
else 
if ~isempty( h.Nodes{ k }.TimeSeriesSource )
h.Nodes{ k }.update( t );
end 
end 
end 
end 

end 

end 

methods ( Hidden )


function legacyDelete( h )






if ~isempty( h.VRWorldOldFilename ) && ~isempty( h.VRWorldTempFilename )
if h.ShowSaveWarning
warning( message( 'aero:vranim:deleteTempFile', h.VRWorldTempFilename ) );
end 
delete( h.VRWorldTempFilename )
end 


if ~isempty( ishghandle( findall( 0, 'Tag', 'VR_Figure' ) ) )
if ~isempty( h.VRFigure ) && isvalid( h.VRFigure )
close( h.VRFigure )
end 
end 


if ( ~isempty( h.VRAnimTimer ) && isvalid( h.VRAnimTimer ) )
try 
stop( h.VRAnimTimer )
catch invalidVRAnimTimer %#ok<NASGU>




end 
end 
h.VRAnimTimer = [  ];



if ~isempty( h.VRWorld ) && isvalid( h.VRWorld )
for i = 1:get( h.VRWorld, 'OpenCount' )

while isopen( h.VRWorld )
close( h.VRWorld );
end 


if ~isopen( h.VRWorld )
delete( h.VRWorld );
end 
end 
end 

end 

end 

end 



function timerCallbackFcn( timerObj, event, h, timeAdvance )


switch event.Type
case 'StartFcn'

if ~strcmpi( h.VideoRecord, 'off' )
userData = get( timerObj, 'UserData' );

videoObj = VideoWriter( h.VideoFileName, h.VideoCompression );

videoObj.FrameRate = h.FramesPerSecond;
if any( strncmp( h.VideoCompression, { 'Motion JPEG AVI', 'MPEG-4' }, length( h.VideoCompression ) ) )

videoObj.Quality = h.VideoQuality;
end 
timerObj.UserData = { userData{ 1 }, videoObj };
end 
case 'TimerFcn'
userData = get( timerObj, 'UserData' );


t = userData{ 1 };


videoObj = userData{ 2 };

if ( ( t == h.TStart ) && strcmpi( h.VideoRecord, 'on' ) ) ||  ...
( ( t <= h.VideoTStart ) && strcmpi( h.VideoRecord, 'scheduled' ) )

open( videoObj );
end 

if ( t < h.TFinal )

h.updateNodes( t );


timerObj.UserData = { h.TStart + timerObj.TasksExecuted * timeAdvance; ...
videoObj };

if isvalid( h.VRFigure ) && ( strcmpi( h.VideoRecord, 'on' ) ||  ...
( ( ( t >= h.VideoTStart ) && ( t <= h.VideoTFinal ) ) && strcmpi( h.VideoRecord, 'scheduled' ) ) )
try 

vrdrawnow;
frame = capture( h.VRFigure );
writeVideo( videoObj, frame );
catch ME %#ok<NASGU>

end 
end 
else 

h.updateNodes( h.TFinal );

if isvalid( h.VRFigure ) && ( strcmpi( h.VideoRecord, 'on' ) ||  ...
( ( t <= h.VideoTFinal ) && strcmpi( h.VideoRecord, 'scheduled' ) ) )
try 

vrdrawnow;
frame = capture( h.VRFigure );
writeVideo( videoObj, frame );
catch ME %#ok<NASGU>

end 
end 
end 
case 'StopFcn'

if ~strcmpi( h.VideoRecord, 'off' )
userData = get( timerObj, 'UserData' );
videoObj = userData{ 2 };
close( videoObj );
end 

delete( timerObj )
case 'ErrorFcn'

if ~strcmpi( h.VideoRecord, 'off' )
userData = get( timerObj, 'UserData' );
videoObj = userData{ 2 };
close( videoObj );
end 
end 

end 

function locStartStopTimeHeuristic( h )






n = numel( h.Nodes );
nodesWithData = zeros( 1, n );
for k = 1:n

nodesWithData( k ) = ~isempty( h.Nodes{ k }.TimeSeriesSource );
end 
nodeIndex = find( nodesWithData );
for k = nodeIndex
[ tempStart( k ), tempFinal( k ) ] = h.Nodes{ k }.findstartstoptimes;%#ok<AGROW>
end 
if all( isfinite( tempStart ) )
h.TStart = max( tempStart( nodeIndex ) );
else 
error( message( 'aero:vranim:infiniteStartTime' ) );
end 
if all( isfinite( tempFinal ) )
h.TFinal = min( tempFinal( nodeIndex ) );
else 
error( message( 'aero:vranim:infiniteStopTime' ) );
end 

end 
























function locStartStopTimeValidate( h )







validateStartTimeLessThanFinalTime( h )



n = numel( h.Nodes );
nodesWithData = zeros( 1, n );

for k = 1:n

nodesWithData( k ) = ~isempty( h.Nodes{ k }.TimeSeriesSource );
end 

nodeIndex = find( nodesWithData );

tempStart = NaN * ones( nodeIndex( end  ), 1 );
tempFinal = NaN * ones( nodeIndex( end  ), 1 );

for i = nodeIndex
[ tempStart( i ), tempFinal( i ) ] = h.Nodes{ i }.findstartstoptimes;
end 


minStart = max( tempStart( isfinite( tempStart ) ) );
maxFinal = min( tempFinal( isfinite( tempFinal ) ) );

validateTimeBounds( h, minStart, maxFinal )

end 

function newNode = createNode( h, varargin )





narginchk( 4, 5 );


n = Aero.Node;

switch nargin
case 5

[ parent_node, parent_field, node_name, node_type ] = varargin{ : };


n.VRNode = vrnode( parent_node, parent_field, node_name, node_type );


n.Name = node_name;


h.Nodes{ end  + 1 } = n;


newNode = n.VRNode;

case 4

[ world, node_name, node_type ] = varargin{ : };


n.VRNode = vrnode( world, node_name, node_type );


n.Name = node_name;


h.Nodes{ end  + 1 } = n;


newNode = n.VRNode;
otherwise 
error( message( 'aero:vranim:changeNodeArgs' ) );
end 

end 

function saveWorld( h, varargin )









narginchk( 1, 3 );



if isempty( h.VRWorldOldFilename )
h.VRWorldOldFilename{ 1 } = h.VRWorldFilename;
end 

noThumbFlag = false;
if nargin == 2 && strcmp( varargin{ 1 }, '-nothumbnail' ) ||  ...
nargin == 3 && strcmp( varargin{ 2 }, '-nothumbnail' )
noThumbFlag = true;
elseif nargin == 3 && ~strcmp( varargin{ 2 }, '-nothumbnail' )
error( message( 'aero:vranim:noThumbnailError', varargin{ 2 } ) );
end 

if nargin == 2 && ~noThumbFlag
[ pathstr, name, ext ] = fileparts( varargin{ 1 } );
if isempty( ext )
ext = '.wrl';
end 
if isempty( pathstr )

pathstr = pwd;
end 


if ~any( strcmp( h.VRWorldFilename, h.VRWorldOldFilename ) )
h.VRWorldOldFilename{ end  + 1 } = h.VRWorldFilename;
end 



h.VRWorldFilename = fullfile( pathstr, filesep, [ name, ext ] );

else 
h.VRWorldFilename = h.VRWorldTempFilename;
end 


pathstr = fileparts( h.VRWorldFilename );
if contains( pathstr, [ matlabroot, filesep, 'toolbox' ] )
undoChanges;
error( message( 'aero:vranim:saveToPath' ) );
end 



if ~isempty( h.VRWorld )



try 
if h.ShowSaveWarning && nargin == 1
fprintf( [ '\nSaving world to temporary file \n\n%s\n\nand running initialize() from that file. The previous .wrl filename:' ...
, '\n\n%s\n\nis stored in the VRWorldOldFilename property.\n\n' ...
, 'To preserve temporary files, use the saveas method.\n' ] );
end 

if noThumbFlag

save( h.VRWorld, h.VRWorldFilename, '-nothumbnail' );
else 

save( h.VRWorld, h.VRWorldFilename );
end 

catch vrsave
undoChanges;
newExc = MException( 'aero:vranim:vrSave', getString( message( 'aero:vranim:vrSave' ) ) );
newExc = newExc.addCause( vrsave );
throw( newExc );
end 

else 
error( message( 'aero:vranim:saveUninitializedWorld' ) )
end 


h.initialize(  )

function undoChanges

h.VRWorldFilename = h.VRWorldOldFilename{ end  };
h.VRWorldOldFilename( end  ) = [  ];
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmplofEyC.p.
% Please follow local copyright laws when handling this file.

