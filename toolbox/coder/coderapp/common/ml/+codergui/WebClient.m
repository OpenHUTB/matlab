classdef ( Abstract )WebClient < coderapp.internal.log.HierarchyLoggable










events ( NotifyAccess = protected )
WindowFocusGained
WindowFocusLost
end 

properties ( Access = private, Constant )
POLL_INTERVAL = 0.3
POLL_TIMEOUT = 60
WC_CHANNEL_GROUP = 'wc'
CLIENT_READY_CHANNEL = 'clientstate/status'
CLIENT_API_SPEC_OBJECT = 'clientContext.apiSpec'
CLIENT_API_OBJECT = 'clientContext.api'
KEEP_ALIVE_CHANNEL = 'clientstate/keepalive'
SHARED_REMOTE_API_DOC = fullfile( matlabroot, 'toolbox/coder/coderapp/common/ml/+codergui/sharedRemoteApiDocs.json' )
end 

properties ( SetAccess = immutable )
Id( 1, : )char
ClientRoot( 1, : )char
ChannelGroup( 1, : )char
Debug( 1, 1 )logical
end 

properties ( SetAccess = private, SetObservable )
ClientUrl( 1, : )char
InitTimeout( 1, 1 ){ mustBeNonnegative( InitTimeout ) }
end 

properties ( SetAccess = private, SetObservable )
Disposed( 1, 1 )logical
Visible( 1, 1 )logical
Initialized( 1, 1 )logical
ClientLoaded( 1, 1 )logical
end 

properties ( Dependent, SetAccess = private )
RemoteApi
end 

properties ( Abstract, SetAccess = immutable )
Async
SupportsEvalReturn
SupportsKeepAlive
DebugPort
end 

properties 
WindowTitle{ mustBeTextScalar( WindowTitle ) } = ''
ClientParams( 1, 1 )struct = struct(  )
PauseBeforeInit( 1, 1 )logical = false
CustomCloseCallback function_handle
end 

properties ( Dependent )
WindowSize{ mustBeNonnegative( WindowSize ) }
end 

properties ( Access = private )
Subscriptions
Services
Properties
RemoteApiManager
RemoteControlDocSources
Disposing = false
end 

properties ( SetAccess = immutable, Hidden )
PostReadyCode{ mustBeTextScalar( PostReadyCode ) } = ''
PostReadyModuleId{ mustBeTextScalar( PostReadyModuleId ) } = ''
ExternalModules{ mustBeA( ExternalModules, [ "struct", "char", "string", "cell" ] ) } = {  }
end 

properties ( SetAccess = immutable, GetAccess = protected )
OpenDebuggerOnInit( 1, 1 )logical
BreakOnInit( 1, 1 )logical
ReadyStatus{ mustBeMember( ReadyStatus, [ "initialized", "ready" ] ) } = 'initialized'
WaitTimeout( 1, 1 ){ mustBeNonnegative( WaitTimeout ) }
end 

properties ( SetAccess = private, GetAccess = protected )
StoredWindowSize{ mustBeNonnegative( StoredWindowSize ) }
end 

properties ( SetAccess = immutable, GetAccess = protected )
UseRemoteControl( 1, 1 )logical
CacheBustOverride( 1, 1 )logical
Themeable( 1, 1 )logical
end 

methods 
function this = WebClient( clientRoot, varargin )




































































R36
clientRoot char{ mustBeTextScalar( clientRoot ) }
end 
R36( Repeating )
varargin
end 

ip = inputParser(  );
ip.KeepUnmatched = true;
ip.PartialMatching = false;
ip.addParameter( 'Debug', coder.internal.gui.globalconfig( 'WebDebugMode' ), @islogical );
ip.addParameter( 'IdPrefix', 'generic', @ischar );
ip.addParameter( 'WaitForReady', false, @islogical );
ip.addParameter( 'OpenDebugger', coder.internal.gui.globalconfig( 'WebDebugger' ), @islogical );
ip.addParameter( 'BreakOnInit', coder.internal.gui.globalconfig( 'WebBreakOnInit' ), @islogical );
ip.addParameter( 'WaitTimeout', codergui.WebClient.POLL_TIMEOUT, @( v )validateattributes( v, { 'double' }, { 'integer', 'scalar' } ) );
ip.addParameter( 'RemoteControl', coder.internal.gui.globalconfig( 'WebRemoteControl' ), @islogical );
ip.addParameter( 'RemoteApiDocSources', {  }, @iscellstr );
ip.addParameter( 'ExternalModules', [  ], @validateBundleDefs );
ip.addParameter( 'PostReadyCode', '', @ischar );
ip.addParameter( 'PostReadyModuleId', '', @ischar );
ip.addParameter( 'CustomCloseCallback', function_handle.empty(  ), @( v )isempty( v ) || isa( v, 'function_handle' ) );
ip.addParameter( 'LogParent', [  ] );
ip.addParameter( 'EnableLogging', [  ] );
ip.parse( varargin{ : } );

id = coderapp.internal.util.readableId( ip.Results.IdPrefix );
this@coderapp.internal.log.HierarchyLoggable( id, Parent = ip.Results.LogParent, EnableLogging = ip.Results.EnableLogging );

this.Id = id;
this.Debug = ip.Results.Debug;
this.OpenDebuggerOnInit = ip.Results.OpenDebugger;
this.BreakOnInit = ip.Results.BreakOnInit;
this.WaitTimeout = ip.Results.WaitTimeout;
this.UseRemoteControl = ip.Results.RemoteControl;
this.RemoteControlDocSources = [ { this.SHARED_REMOTE_API_DOC }, ip.Results.RemoteApiDocSources ];
this.CacheBustOverride = coderapp.internal.globalconfig( 'WebCacheBust' );
this.Themeable = coderapp.internal.globalconfig( 'ThemeSupport' );
this.Properties = containers.Map(  );

this.Services = {  };
this.Subscriptions = uint64( [  ] );

if ip.Results.WaitForReady
this.ReadyStatus = 'ready';
else 
this.ReadyStatus = 'initialized';
end 
if this.BreakOnInit
this.InitTimeout = 0;
else 
this.InitTimeout = this.WaitTimeout;
end 
if ~isempty( ip.Results.CustomCloseCallback )
this.CustomCloseCallback = ip.Results.CustomCloseCallback;
end 

if ~isempty( ip.Results.ExternalModules )
this.ExternalModules = ip.Results.ExternalModules;
end 
this.PostReadyCode = ip.Results.PostReadyCode;
this.PostReadyModuleId = ip.Results.PostReadyModuleId;

this.ChannelGroup = sprintf( '/mlc/%s', this.Id );
this.ClientRoot = rootFolderToPage( clientRoot, this.Debug );
this.updateUrl(  );
end 
end 

methods ( Static )
function clients = getWebClients( predicate )
R36
predicate function_handle = function_handle.empty(  )
end 

if nargin > 0
args = { predicate };
else 
args = {  };
end 
clients = webClientRegistry( 'get', args{ : } );
for i = 1:numel( clients )
if ~isvalid( clients{ i } )
clients{ i } = [  ];
end 
end 
clients( cellfun( 'isempty', clients ) ) = [  ];
end 

function disposeAll(  )
clients = codergui.WebClient.getWebClients(  );
for i = 1:numel( clients )
clients{ i }.dispose(  );
end 
end 

function disposeById( clientId )
R36
clientId( 1, 1 )string
end 

clients = codergui.WebClient.getWebClients( @( c )strcmp( c.Id, clientId ) );
for i = 1:numel( clients )
clients{ i }.dispose(  );
end 
end 
end 

methods ( Sealed )
function show( this )
if isempty( this.WindowSize )
screen = get( 0, 'screensize' );
this.WindowSize = [  ...
min( max( floor( screen( 3 ) * 0.85 ), min( screen( 3 ), 750 ) ), 1920 ),  ...
min( max( floor( screen( 4 ) * 0.85 ), min( screen( 4 ), 600 ) ), 1200 ) ...
 ];
end 

if ~this.Initialized
this.init(  );
this.setWindowSize( this.StoredWindowSize( 1 ), this.StoredWindowSize( 2 ) );
end 

this.setVisible( true );
this.Visible = true;
this.bringToFront(  );
end 

function hide( this )
if this.Initialized
this.setVisible( false );
this.Visible = false;
end 
end 

function visible = isVisible( this )
visible = this.Visible;
end 





function result = jsEval( this, code, varargin )
R36
this( 1, 1 )
code( 1, 1 )string
end 
R36( Repeating )
varargin
end 

assert( this.SupportsEvalReturn || nargout == 0,  ...
'%s does not support JS evals that return values', class( this ) );
this.init(  );
code = char( sprintf( code, varargin{ : } ) );

try 
if nargout ~= 0
result = this.doJsEval( code );
if ischar( result )
result = jsondecode( result );
end 
else 
this.doJsEval( code );
end 
catch me
me.throwAsCaller(  );
end 
end 

function varargout = takeScreenshot( this, opts )
R36
this( 1, 1 )
opts.Bounds( 1, 4 )double{ mustBeNonnegative( opts.Bounds ) } = [ 0, 0, 0, 0 ]
opts.Region( 1, 1 )string = ""
opts.Padding double{ mustBeNonnegative( opts.Padding ) } = [  ]
opts.File( 1, 1 )string = ""
end 

hasBounds = any( opts.Bounds ~= 0 );
hasRegion = opts.Region ~= "";
assert( ~hasBounds || ~hasRegion, 'Cannot specify both Bounds and Region' );
if hasRegion
this.RemoteApi.regions.scrollToRegion( opts.Region );
bounds = reshape( this.getRegionBounds( opts.Region ), 1, [  ] );
elseif hasBounds
bounds = opts.Bounds;
else 
bounds = [  ];
end 

pixels = this.doTakeScreenshot(  );

if ~isempty( bounds )
padding = reshape( opts.Padding, 1, [  ] );
switch numel( padding )
case 0
padding = zeros( 1, 4 );
case 1
padding = repmat( padding, 1, 4 );
case 2
padding = [ padding, padding ];
case 4
otherwise 
error( 'Padding must specfied as a scalar, pair, or quadruple' );
end 

bounds( 1:2 ) = bounds( 1:2 ) - padding( 1:2 );
bounds( 3:4 ) = bounds( 3:4 ) + padding( 1:2 ) + padding( 3:4 );
imgSize = size( pixels, [ 1, 2 ] );
pixels = imcrop( pixels, [  ...
min( bounds( 1:2 ), imgSize ) ...
, min( bounds( 1:2 ) + bounds( 3:4 ), imgSize ) - min( bounds( 1:2 ), imgSize ) ...
 ] );
end 

if opts.File ~= ""
destFile = opts.File;
[ ~, ~, ext ] = fileparts( destFile );
if ext == ""
destFile = destFile + ".png";
end 
imwrite( pixels, destFile );
elseif nargout ~= 0
varargout{ 1 } = pixels;
else 
imtool( pixels );
end 
end 

function regions = getRegionNames( this )
this.assertUseRemoteApi( 'getRegionNames' );
regions = sort( this.RemoteApi.regions.getAllNames(  ) );
end 

function bool = isRegion( this, region )
R36
this( 1, 1 )
region( 1, 1 )string
end 

this.assertUseRemoteApi( 'isRegion' );
bool = ~isempty( this.RemoteApi.regions.getBounds( region ) );
end 

function bounds = getRegionBounds( this, region )
R36
this( 1, 1 )
region( 1, 1 )string
end 

this.assertUseRemoteApi( 'getRegionBounds' );
bounds = this.RemoteApi.regions.getBounds( region );
if isempty( bounds )
error( 'Region with name of "%s" is either hidden or does not exist', region );
end 
end 

function dispose( this )
if this.Disposing || ~this.Initialized
return 
end 
this.Disposing = true;

if ~isempty( this.RemoteApiManager )
this.RemoteApiManager.delete(  );
end 

try 
this.cleanup(  );
for i = 1:numel( this.Services )
this.Services{ i }.shutdown(  );
end 
catch me %#ok<NASGU>
end 

this.unsubscribe( this.Subscriptions );
values = this.Properties.values(  );%#ok<NASGU>
this.Properties.remove( this.Properties.keys(  ) );
webClientRegistry( 'remove', this );
this.Disposed = true;
end 

function installWebService( this, service )
R36
this codergui.WebClient
service codergui.internal.WebService
end 
this.Services{ end  + 1 } = service;
if this.Initialized
this.startService( service );
end 
end 

function uninstallWebService( this, service )
R36
this codergui.WebClient
service codergui.internal.WebService
end 
numServices = numel( this.Services );
this.Services = this.Services( ~cellfun( @( s )isequal( s, service ), this.Services ) );
if numServices ~= numel( this.Services ) && this.Initialized
service.shutdown(  );
end 
end 

function setProperty( this, key, val )
this.Properties( key ) = val;
end 

function yes = hasProperty( this, key )
yes = this.Properties.isKey( key );
end 

function val = getProperty( this, key )
val = this.Properties( key );
end 
end 

methods 
function delete( this )
this.dispose(  );
end 

function set.ClientParams( this, clientParams )
if isempty( clientParams )
clientParams = struct(  );
else 
assert( ~isfield( clientParams, 'clientId' ) || isequal( clientParams.clientId, this.Id ),  ...
'''clientId'' is a reserved query parameter' );%#ok<MCSUP>
end 
this.ClientParams = clientParams;
this.updateUrl(  );
end 

function clientParams = get.ClientParams( this )
clientParams = this.ClientParams;
if this.PauseBeforeInit
clientParams.debugInit = true;
end 
if this.Debug
clientParams.mode = 'debug';
end 
if this.BreakOnInit
clientParams.debugInit = true;
end 
if this.UseRemoteControl
clientParams.useRemoteApi = true;
end 
if ~isempty( this.ExternalModules )
clientParams.hasExternalModules = true;
end 
if ~isempty( this.PostReadyCode )
clientParams.postReadyCode = this.PostReadyCode;
end 
if ~isempty( this.PostReadyModuleId )
clientParams.postReadyModuleId = this.PostReadyModuleId;
end 
if ~isempty( this.CacheBustOverride )
clientParams.cacheBust = this.CacheBustOverride;
end 
clientParams.themeable = this.Themeable;
clientParams.clientId = this.Id;
end 

function set.WindowSize( this, windowSize )
this.StoredWindowSize = windowSize;
if this.Initialized
this.setWindowSize( windowSize( 1 ), windowSize( 2 ) );
end 
end 

function windowSize = get.WindowSize( this )
if this.Initialized
windowSize = this.doGetWindowSize(  );
else 
windowSize = this.StoredWindowSize;
end 
end 

function set.WindowTitle( this, title )
validateattributes( title, { 'char' }, { 'scalartext' } );
this.WindowTitle = title;
this.updateWindowTitle(  );
end 

function remoteApi = get.RemoteApi( this )
if ~isempty( this.RemoteApiManager )
this.init(  );
remoteApi = this.RemoteApiManager.Root;
else 
remoteApi = [  ];
end 
end 
end 

methods ( Abstract )
bringToFront( this )

minimize( this )

restore( this )
end 

methods ( Abstract, Access = protected )
start( this )

cleanup( this )

doJsEval( this )

setVisible( this, visible )

setWindowSize( this, width, height )

setWindowTitle( this, title )
end 

methods ( Abstract, Hidden )
openDebugger( this )
end 

methods ( Sealed, Hidden )
function init( this )
if this.Disposed
error( 'Client is already disposed' );
elseif this.Initialized
return 
end 

this.Initialized = true;
webClientRegistry( 'add', this );

if this.UseRemoteControl
this.RemoteApiManager = codergui.internal.RemoteApiManager( this,  ...
'ApiDocSources', this.RemoteControlDocSources );
end 

for i = 1:numel( this.Services )
this.startService( this.Services{ i } );
end 
this.installCoreServices(  );

this.subscribe( this.CLIENT_READY_CHANNEL, @onStatusMessage );
if ~this.SupportsKeepAlive
this.subscribe( this.CLIENT_READY_CHANNEL, @onDisposeMessage );
end 
this.doClientStartup(  );
if this.OpenDebuggerOnInit
this.openDebugger(  );
end 
this.waitFor( @(  )this.ClientLoaded, 'InitWait', true );

function onStatusMessage( message )
if strcmp( message, this.ReadyStatus )
onLoad(  );
end 
end 

function onLoad(  )
if ~this.ClientLoaded
this.ClientLoaded = true;
end 
end 

function onDisposeMessage( message )
if this.ClientLoaded && strcmp( message, 'disposed' )
disposer = onCleanup( @this.dispose );
end 
end 
end 

function subToken = subscribe( this, subChannelSpec, callback )
R36
this( 1, 1 )
subChannelSpec char{ mustBeTextScalar( subChannelSpec ) }
callback( 1, 1 )function_handle
end 

if ~startsWith( subChannelSpec, [ this.ChannelGroup, '/' ] )
subChannelSpec = this.channel( subChannelSpec );
end 
subToken = message.subscribe( subChannelSpec, callback );
this.Subscriptions( end  + 1 ) = subToken;
end 

function unsubscribe( this, subTokens )
if iscell( subTokens )
subTokens = cell2mat( subTokens );
end 
arrayfun( @( t )message.unsubscribe( t ), subTokens );
this.Subscriptions = setdiff( this.Subscriptions, subTokens );
end 

function publish( this, subChannelSpec, msg, force )
R36
this( 1, 1 )
subChannelSpec char{ mustBeTextScalar( subChannelSpec ) }
msg
force( 1, 1 ){ mustBeNumericOrLogical( force ) } = false
end 


if ~force
this.waitFor( @(  )this.ClientLoaded, 'ForceSync', true, 'InitWait', true );
end 
if ~startsWith( subChannelSpec, [ this.ChannelGroup, '/' ] )
subChannelSpec = this.channel( subChannelSpec );
end 
message.publish( subChannelSpec, msg );
end 

function scopedChannel = channel( this, subChannel )
if ~isempty( subChannel )
scopedChannel = [ this.ChannelGroup, '/', subChannel ];
else 
scopedChannel = this.ChannelGroup;
end 
end 

function waitFor( this, completionPredicate, varargin )
ip = inputParser(  );
ip.addParameter( 'ForceSync', false, @islogical );
ip.addParameter( 'Timeout', this.WaitTimeout, @isnumeric );
ip.addParameter( 'Interval', this.POLL_INTERVAL, @isnumeric );
ip.addParameter( 'InitWait', false, @islogical );
ip.addParameter( 'TimeoutHandler', [  ], @( x )isa( x, 'function_handle' ) );
ip.parse( varargin{ : } );

if this.Async && ~ip.Results.ForceSync
return ;
end 

if ip.Results.InitWait
timeout = this.InitTimeout;
else 
timeout = ip.Results.Timeout;
end 
interval = ip.Results.Interval;
completed = completionPredicate(  );
startTime = tic(  );

while ~completed && ~this.Disposed
if timeout > 0 && toc( startTime ) > timeout
if ~isempty( ip.Results.TimeoutHandler )
ip.Results.TimeoutHandler(  );
else 
error( 'Operation ''%s'' timed out', func2str( completionPredicate ) );
end 
end 
drawnow(  );
pause( interval );
if ~isvalid( this )
break 
end 
completed = completionPredicate(  );
end 
end 
end 

methods ( Access = protected )
function updateWindowTitle( this )
if this.Initialized && ~this.Disposed
this.setWindowTitle( this.WindowTitle );
end 
end 

function windowSize = doGetWindowSize( this )
windowSize = this.StoredWindowSize;
end 

function img = doTakeScreenshot( ~, bounds )%#ok<STOUT,INUSD>
error( 'Programmatic screenshot capture is not supported by this WebClient' );
end 
end 

methods ( Access = private )
function installCoreServices( this )
this.installWebService( codergui.internal.ClientToServerLoggingService(  ) );
this.installWebService( coderapp.internal.gc.GlobalConfigWebService(  ) );
if this.SupportsKeepAlive
this.installWebService( codergui.internal.KeepAliveService(  ...
this.channel( this.CLIENT_READY_CHANNEL ),  ...
this.channel( this.KEEP_ALIVE_CHANNEL ) ) );
end 
if ~isempty( this.ExternalModules )
this.installWebService( codergui.internal.BundleDiscoveryService(  ) );
end 
end 

function updateUrl( this )
if isstruct( this.ClientParams ) && ~isempty( fieldnames( this.ClientParams ) )
queryParams = this.ClientParams;
paramNames = fieldnames( queryParams );
for i = 1:numel( paramNames )
paramName = paramNames{ i };
paramValue = queryParams.( paramName );
if isnumeric( paramValue )
paramValue = num2str( paramValue );
elseif islogical( paramValue )
if paramValue
paramValue = 'true';
else 
paramValue = 'false';
end 
end 
queryParams.( paramName ) = paramValue;
end 
resourcePathURI = matlab.net.URI( this.ClientRoot, matlab.net.QueryParameter( queryParams ) );
resourcePath = resourcePathURI.EncodedURI;
else 
resourcePath = this.ClientRoot;
end 
connector.ensureServiceOn(  );
this.ClientUrl = connector.getUrl( resourcePath );
end 

function doClientStartup( this )
this.start(  );
this.updateWindowTitle(  );
end 

function startService( this, service )
if isa( service, 'codergui.internal.WebService' )
service.start( this );
else 
service.start(  );
end 
end 

function assertUseRemoteApi( this, contextName )
assert( this.UseRemoteControl, '%s requires opting enabling RemoteControl during WebClient construction',  ...
contextName );
end 
end 

methods ( Access = { ?codergui.internal.RemoteApi } )
function result = invokeRemoteApi( this, apiName, varargin )
assert( this.ClientLoaded );

if ~isempty( varargin )
argJson = cell( 1, numel( varargin ) );
for i = 1:numel( varargin )
argJson{ i } = jsonencode( varargin{ i } );
end 
argStr = strjoin( argJson, ',' );
else 
argStr = '';
end 
code = sprintf( '%s.%s(%s)', this.CLIENT_API_OBJECT, apiName, argStr );

if nargout > 0 && this.SupportsEvalReturn
result = this.jsEval( code );
else 
this.jsEval( code );
result = [  ];
end 
end 
end 
end 


function page = rootFolderToPage( clientRoot, debug )
[ folder, page, ext ] = fileparts( clientRoot );
if isempty( ext )
folder = fullfile( folder, page );
if debug
page = 'index-debug.html';
else 
page = 'index.html';
end 
else 
page = [ page, ext ];
end 
page = regexprep( strrep( fullfile( folder, page ), '\', '/' ), '^/', '', 'once' );
end 


function validateBundleDefs( arg )
if ~isempty( arg ) && ~isstruct( arg )
mustBeText( arg );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpIH0TWU.p.
% Please follow local copyright laws when handling this file.

