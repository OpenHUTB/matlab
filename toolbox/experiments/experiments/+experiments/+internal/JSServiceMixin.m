classdef ( Abstract )JSServiceMixin < handle

properties ( Constant, Abstract )
feature( 1, 1 ){ isaJSServiceFeature }
end 

properties ( GetAccess = private, SetAccess = immutable )
identifier;
requestChannel;
responseChannel;
eventChannel;
featureChannel;
errorChannel;
queryChannel;
answerChannel;
jsMethods = struct(  );
end 

properties ( Access = private )
queryId = 0;
answerReceivers = struct(  );
requestSubscription;
errorSubscription;
answerSubscription;
featureListener;
lasterror = [  ];
isServicingRequest = false;
suspendEventsCount = 0;
suspendEventsBuffer = struct(  );
end 

methods 
function self = JSServiceMixin( channel, prefix )
self.requestChannel = [ channel, '/request' ];
self.responseChannel = [ channel, '/response' ];
self.eventChannel = [ channel, '/event' ];
self.featureChannel = [ channel, '/feature' ];
self.errorChannel = [ channel, '/error' ];
self.queryChannel = [ channel, '/query' ];
self.answerChannel = [ channel, '/answer' ];


mc = metaclass( self );
self.identifier = [ regexprep( mc.Name, '.*\.', '' ), ':JSService' ];
for m = mc.MethodList'
if startsWith( m.Name, prefix )
assert( length( m.OutputNames ) <= 1, 'service methods must have either 0 or 1 output' );
assert( ~strcmp( m.Name, 'jsMethods' ), 'jsMethods is a reserved method' );
self.jsMethods.( m.Name ) = length( m.OutputNames );
end 
end 
end 

function subscribe( self )

self.log( @(  ){ 'subscribe\n' } );
assert( isempty( self.requestSubscription ), 'JSService can only be subscribed if unsubscribed' );
connector.ensureServiceOn(  );

function handleCallbackErrror( fn, msg )


try 
fn( msg );
catch ME
self.errors( 'add', ME );
fwrite( 2, ME.getReport(  ) );
end 
end 

self.requestSubscription = message.subscribe( self.requestChannel, @( msg )handleCallbackErrror( @self.dispatchRequest, msg ) );
self.errorSubscription = message.subscribe( self.errorChannel, @( msg )handleCallbackErrror( @self.reportError, msg ) );
self.featureListener = self.feature.addlistener( 'FeatureUpdate', @( ~, eventData )self.updateFeature( eventData.Update, eventData.Previous ) );
self.answerSubscription = message.subscribe( self.answerChannel, @( msg )handleCallbackErrror( @self.receiveAnswer, msg ) );
end 

function unsubscribe( self )

self.log( @(  ){ 'unsubscribe\n' } );
assert( ~isempty( self.requestSubscription ), 'JSService can only be unsubscribed if subscribed' );
if connector.isRunning
message.unsubscribe( self.requestSubscription );
message.unsubscribe( self.errorSubscription );
delete( self.featureListener );
message.unsubscribe( self.answerSubscription );
end 
self.requestSubscription = [  ];
self.errorSubscription = [  ];
self.featureListener = [  ];
self.answerSubscription = [  ];
end 

function delete( self )
if ~isempty( self.requestSubscription )
self.unsubscribe(  );
end 
end 
end 

methods 
function cleanup = suspendEvents( self, opt )
R36
self( 1, 1 )experiments.internal.JSServiceMixin
opt( 1, 1 )string{ mustBeMember( opt, [ "", "initial" ] ) }
end 

self.suspendEventsCount = self.suspendEventsCount + 1;
if opt == "initial"

self.isServicingRequest = true;
end 
self.log( @(  ){ 'suspendEventsCount = %d (was %d), isServicingRequest = %d\n', self.suspendEventsCount, self.suspendEventsCount - 1, self.isServicingRequest } );

function resetSuspendEvents( self )
self.suspendEventsCount = self.suspendEventsCount - 1;
self.log( @(  ){ 'suspendEventsCount = %d (was %d), isServicingRequest = %d\n', self.suspendEventsCount, self.suspendEventsCount + 1, self.isServicingRequest } );
self.flushSuspendedEvents(  );
end 
cleanup = onCleanup( @(  )resetSuspendEvents( self ) );
end 

function emit( self, name, value )
event.name = name;
if exist( 'value', 'var' )
event.value = value;
end 
if self.suspendEventsCount > 0
if isfield( self.suspendEventsBuffer, name )

self.suspendEventsBuffer = rmfield( self.suspendEventsBuffer, name );
end 
self.suspendEventsBuffer.( name ) = event;
self.log( @(  ){ 'suspend %s\n', jsonencode( event ) } );
else 
message.publish( self.eventChannel, event );
self.log( @(  ){ 'emit %s\n', jsonencode( event ) } );
end 
end 

function log( self, argsfn )
if self.feature.debug || self.feature.log
args = argsfn(  );
fprintf( 2, args{ : } );
end 
end 
end 

methods ( Access = private )
function dispatchRequest( self, request )
self.log( @(  ){ '%16d >> %s\n', request.id, jsonencode( orderfields( rmfield( request, 'id' ), { 'method', 'args' } ) ) } );
self.isServicingRequest = true;
flushEventCleanup = onCleanup( @(  )self.finishRequest( request.id ) );
if strcmp( request.method, 'methods' )
response.id = request.id;
response.value = fieldnames( self.jsMethods );
self.updateFeature( struct( self.feature ), struct(  ) );
message.publish( self.responseChannel, response );
self.isServicingRequest = false;
elseif strcmp( request.method, 'ping' )
response.id = request.id;
response.value = true;
message.publish( self.responseChannel, response );
self.isServicingRequest = false;
elseif isfield( self.jsMethods, request.method )
response.id = request.id;
try 

request.args = jsondecode( request.args );
request.args( end  ) = [  ];

if self.jsMethods.( request.method )
response.value = self.( request.method )( request.args{ : } );
else 
self.( request.method )( request.args{ : } );
end 
message.publish( self.responseChannel, response );
catch ME

self.lasterror = ME;
response.error.identifier = ME.identifier;
response.error.message = ME.message;
response.error.stack = ME.stack;
if isa( ME, 'ExperimentException' )
response.error.report = ME.getReport(  );
else 
response.error.report = ME.getReport( 'basic' );
end 
message.publish( self.responseChannel, response );
self.log( @(  ){ ME.getReport } );
end 
self.isServicingRequest = false;
else 
self.isServicingRequest = false;
assert( false, 'unknown method %s, args %s', request.method, jsonencode( request.args ) );
end 
self.log( @(  ){ '%16d << %s\n', response.id, jsonencode( rmfield( response, 'id' ) ) } );
end 

function flushSuspendedEvents( self )
if self.suspendEventsCount == 0 && ~self.isServicingRequest
for name = fieldnames( self.suspendEventsBuffer )'
event = self.suspendEventsBuffer.( name{ : } );
message.publish( self.eventChannel, event );
self.log( @(  ){ 'flush %s\n', jsonencode( event ) } );
end 
self.suspendEventsBuffer = struct(  );
end 
end 

function finishRequest( self, requestId )
if ( self.isServicingRequest == true )
response.id = requestId;
response.error.identifier = 'JSServiceMixin:OperationTerminatedByUser';
response.error.message = 'Operation terminated by user';
message.publish( self.responseChannel, response );
self.log( @(  ){ '%16d << %s\n', response.id, jsonencode( rmfield( response, 'id' ) ) } );
self.isServicingRequest = false;
end 
self.flushSuspendedEvents(  );
end 

function reportError( self, errmsg )
self.log( @(  ){ '%16s !! %s\n', '', jsonencode( errmsg ) } );
self.reportErrorActual( errmsg );
end 

function reportErrorActual( self, errmsg, morestack )
if isstruct( errmsg )
if isfield( errmsg, 'name' ) && strcmp( errmsg.name, 'MATLABError' )
if ~isempty( self.lasterror ) ...
 && strcmp( self.lasterror.identifier, errmsg.identifier ) ...
 && strcmp( self.lasterror.message, errmsg.message ) ...
 && isequal( self.lasterror.stack, errmsg.MATLABStack )

self.lasterror.rethrow(  );
else 

errmsg.stack = errmsg.MATLABStack;
if isempty( strfind( errmsg.identifier, ':' ) )

errmsg.identifier = [ self.identifier, ':', errmsg.identifier ];
end 
end 
else 



if ~isfield( errmsg, 'identifier' )
if isfield( errmsg, 'name' )
errmsg.identifier = [ self.identifier, ':', errmsg.name ];
else 
errmsg.identifier = self.identifier;
end 
end 


stack = [  ];
if isfield( errmsg, 'stack' )



stack = arrayfun( @( s )struct( 'file', strrep( s.file, self.origin, matlabroot ), 'name', s.name, 'line', str2double( s.line ) ),  ...
regexp( errmsg.stack, '^ +at (\S+ )*(?<name>\S+(?= \())?(?(name) \()(?<file>[^\s\?]+)(?<query>\S+)?:(?<line>\d+):(?<column>\d+)(?(name)\))$|^(?<name>\S+(?=@))?(?(name)@)(?<file>[^\s\?]+)(?<query>\S+)?:(?<line>\d+):(?<column>\d+)$', 'names', 'lineanchors' ) )';
end 
if ~isempty( stack )
errmsg.stack = stack;
elseif all( isfield( errmsg, { 'sourceURL', 'line' } ) )
errmsg.stack = struct( 'file', strrep( errmsg.sourceURL, self.origin, matlabroot ), 'name', '', 'line', errmsg.line );
else 
errmsg.stack = struct( 'file', '', 'name', '', 'line', 0 );
end 
if exist( 'morestack', 'var' )
errmsg.stack = [ errmsg.stack;morestack ];
end 
end 
error( errmsg );
elseif ischar( errmsg )
error( self.identifier, errmsg );
else 
error( self.identifier, jsonencode( errmsg ) );
end 
end 

function updateFeature( self, update, previous )
data.update = experiments.internal.Feature.toJSON( update );
data.previous = experiments.internal.Feature.toJSON( previous );
self.log( @(  ){ 'feature %s\n', jsonencode( data ) } );
message.publish( self.featureChannel, data );
end 
end 

methods 
function answer = query( self, clientId, method, varargin )
if strcmp( method, 'load' )
assert( ismember( length( varargin ), [ 1, 2 ] ), 'query(..., ''load'', ...) takes one or two arguments (an absolute path to a file rooted at matlabroot, and a boolean flag to overwrite methods)' );
assert( ismember( varargin{ 1 }( 1 ), '/\' ), 'first argument of query(..., ''load'', ...) must be an absolute path to a file rooted at matlabroot' );
assert( exist( fullfile( matlabroot, varargin{ 1 } ), 'file' ) == 2, 'query(..., ''load'', ...) of non-existent file %s (rooted at matlabroot)', varargin{ 1 } );
end 

if strcmp( method, 'ping' )
queryId = 'ping';
else 
queryId = [ 'query', num2str( self.queryId ) ];
self.queryId = self.queryId + 1;
end 

msg.waiting = tic(  );

function removeReceiver( self, queryId )
self.answerReceivers = rmfield( self.answerReceivers, queryId );
end 
cleanupReceiver = onCleanup( @(  )removeReceiver( self, queryId ) );

function receiveAnswer( ansmsg )
msg = ansmsg;
if isfield( msg, 'progress' )
msg.progress{ 1 }( end  + 1 ) = char( 10 );
self.log( @(  )msg.progress );
msg.waiting = tic(  );
else 

clear cleanupReceiver;
end 
end 
self.answerReceivers.( queryId ) = @receiveAnswer;

query.clientId = clientId;
query.queryId = queryId;
query.method = method;
query.args = varargin;
self.log( @(  ){ '%16d <? %s\n', clientId, jsonencode( orderfields( rmfield( query, 'clientId' ), { 'queryId', 'method', 'args' } ) ) } );
message.publish( self.queryChannel, query );


if strcmp( method, 'ping' )

pings = 1;
while isfield( msg, 'waiting' )
if toc( msg.waiting ) > self.feature.queryTimeout
clear cleanupReceiver;
msg = rmfield( msg, 'waiting' );
msg.clientId = clientId;
msg.answer = false;
elseif toc( msg.waiting ) > pings
message.publish( self.queryChannel, query );
pings = pings + 1;
end 
drawnow(  );
end 
clear pings;
else 

while isfield( msg, 'waiting' )
if toc( msg.waiting ) > self.feature.queryTimeout
error( [ self.identifier, ':QueryTimeout' ], '%.1fs timeout awaiting answer from clientId %d for query %s', self.feature.queryTimeout, clientId, jsonencode( orderfields( rmfield( query, 'clientId' ), { 'queryId', 'method', 'args' } ) ) );
end 
drawnow(  );
end 
end 
assert( ~isfield( msg, 'waiting' ), 'should still be waiting for an answer' );


assert( msg.clientId == clientId, 'expected answer from clientId %d but received from clientId %d', clientId, msg.clientId );
if isfield( msg, 'error' )
self.reportErrorActual( msg.error, dbstack( '-completenames' ) );
elseif isfield( msg, 'answer' )
answer = msg.answer;
else 
assert( strcmp( method, 'load' ), 'only "load" is allowed to return no answers' );
end 
end 
end 

methods ( Access = private )
function receiveAnswer( self, msg )
self.log( @(  ){ '%16d ?> %s\n', msg.clientId, jsonencode( orderfields( rmfield( msg, 'clientId' ), intersect( { 'queryId', 'progress', 'answer', 'error' }, fieldnames( msg ), 'stable' ) ) ) } );
if isfield( self.answerReceivers, msg.queryId )
self.answerReceivers.( msg.queryId )( msg );
elseif ~strcmp( msg.queryId, 'ping' )
assert( false, 'received answer for non-pending requestId %d from clientId %d: %s', msg.queryId, msg.clientId, jsonencode( orderfields( rmfield( msg, { 'queryId', 'clientId' } ), intersect( { 'progress', 'answer', 'error' }, fieldnames( msg ), 'stable' ) ) ) );
end 
end 
end 

methods ( Static )
function url = origin(  )
url = connector.getBaseUrl(  );
url = url( 1:end  - 1 );
end 

function varargout = errors( cmd, arg, message )

persistent log

assert( ismember( cmd, { 'add', 'call', 'verifyOnCleanup' } ), 'unknown cmd %s', cmd );

function report = diag( errors )
if ~exist( 'message', 'var' )
message = 'Unhandled JSServiceMixin errors detected';
end 

function result = basename( file )
[ ~, name, ext ] = fileparts( file );
result = [ name, ext ];
end 

function item = diag1( error )
file = '';
if ~isempty( error.stack )
file = [ error.stack( 1 ).name, '@', basename( error.stack( 1 ).file ), ':', num2str( error.stack( 1 ).line ) ];
if desktop( '-inuse' ) && ~qeinbat(  ) && ~qeInSbRunTests(  )
file = [ '<a href="error:', error.stack( 1 ).file, ',', num2str( error.stack( 1 ).line ), '">', file, '</a>' ];
end 
file = [ ' (', file, ')' ];
end 
item = [ error.identifier, file, ' - ', strtok( error.message, char( 10 ) ) ];
end 
[ ids, ~, idIdx ] = unique( cellfun( @diag1, errors, 'UniformOutput', false ) );
counts = hist( idIdx, unique( idIdx ) );
countsIds = [ num2cell( counts );ids ];
report = [ sprintf( '%s\n', message ), sprintf( '\t(%d) %s\n', countsIds{ : } ) ];
end 

function push(  )
if isempty( log )
mlock(  );
end 
log{ end  + 1 } = {  };
end 

function value = pop(  )
value = log{ end  };
log( end  ) = [  ];
if isempty( log )
munlock(  );
end 
end 

function verify( verifyFail )
verrors = pop(  );
if ~isempty( verrors )
verifyFail( diag( verrors ) );
end 
end 

switch cmd
case 'add'
assert( nargin == 2, 'add takes only one argument' );
if ~isempty( log )
log{ end  }{ end  + 1 } = arg;
end 

case 'call'
assert( nargin <= 3, 'call takes one or two arguments' );
push(  );
try 
if nargout > 0
[ varargout{ 1:nargout } ] = arg(  );
else 
arg(  );
end 
catch ME
errors = pop(  );
if ~isempty( errors )
ME.addCause( MException( 'JSServiceMixin:UnhandledError', diag( errors ) ) );
end 
ME.rethrow(  );
end 
errors = pop(  );
if ~isempty( errors )
MException( 'JSServiceMixin:UnhandledError', diag( errors ) ).throw(  );
end 

case 'verifyOnCleanup'
assert( nargin <= 3, 'verifyOnCleanup takes one or two arguments' );
push(  );
varargout{ 1 } = onCleanup( @(  )verify( arg ) );

otherwise 
assert( false );
end 
end 
end 
end 

function isaJSServiceFeature( A )
assert( isa( A, 'experiments.internal.JSServiceFeature' ), 'Value must be a subclass of experiments.internal.JSServiceFeature.' );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpCsBHmX.p.
% Please follow local copyright laws when handling this file.

