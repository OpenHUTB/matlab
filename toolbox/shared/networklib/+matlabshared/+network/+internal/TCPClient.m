classdef TCPClient < matlabshared.transportlib.internal.ITransport &  ...
matlabshared.transportlib.internal.ITokenReader &  ...
matlabshared.transportlib.internal.IFilterable





































%#codegen



properties ( Constant, Hidden )

DefaultSocketSize = 64 * 1024


ConverterPlugin = fullfile( toolboxdir( fullfile( 'shared', 'networklib', 'bin', computer( 'arch' ) ) ), 'networkmlconverter' )


DevicePlugin = fullfile( toolboxdir( fullfile( 'shared', 'networklib', 'bin', computer( 'arch' ) ) ), 'tcpclientdevice' )
end 

properties ( Constant )

DefaultTimeout = 10


DefaultConnectTimeout = inf


DefaultTransferDelay = true
end 

properties ( GetAccess = public, SetAccess = private, Dependent )


ConnectionStatus;
end 

properties ( GetAccess = public, SetAccess = protected )


RemoteHost


RemotePort
end 

properties ( Access = public )


InputBufferSize = inf




OutputBufferSize = inf



Timeout = matlabshared.network.internal.TCPClient.DefaultTimeout



ConnectTimeout = matlabshared.network.internal.TCPClient.DefaultConnectTimeout


UserData
end 

properties ( GetAccess = private, SetAccess = private )



ReceiveCallbackListener



SendCallbackListener



CustomListener
end 

properties ( Access = private, Transient = true )


AsyncIOChannel



TransportChannel



FilterImpl
end 

properties ( GetAccess = public, SetAccess = private, Hidden = true )



IsWriteOnly



IsSharingPort
end 

properties ( Hidden, Dependent )













InitAccess( 1, 1 )logical{ mustBeNonempty }
end 


properties ( GetAccess = public, SetAccess = private, Dependent )

NumBytesAvailable



NumBytesWritten


Connected
end 

properties ( Access = public )



BytesAvailableEventCount = 64



BytesAvailableFcn = function_handle.empty(  )




BytesWrittenFcn = function_handle.empty(  )



ErrorOccurredFcn = function_handle.empty(  )



ByteOrder = 'little-endian'



NativeDataType = 'uint8'



DataFieldName = 'Data'



CustomConverterPlugIn
end 

properties 






SingleCallbackMode = false



LastCallbackVal = 0




TransferDelay( 1, 1 )logical = matlabshared.network.internal.TCPClient.DefaultTransferDelay
end 

properties ( Hidden, Dependent )



AllowPartialReads( 1, 1 )logical{ mustBeNonempty }
end 

properties ( Dependent )




WriteAsync
end 




methods ( Static )
function name = matlabCodegenRedirect( ~ )


name = 'matlabshared.network.internal.coder.TCPClient';
end 
end 


methods 
function value = get.TransferDelay( obj )
if ~obj.Connected
value = obj.TransferDelay;
else 
value = obj.AsyncIOChannel.TransferDelay;
end 

end 

function set.TransferDelay( obj, value )
R36
obj matlabshared.network.internal.TCPClient
value( 1, 1 )logical
end 
obj.validateDisconnected(  );
obj.TransferDelay = value;
end 

function value = get.WriteAsync( obj )
value = obj.TransportChannel.WriteAsync;
end 

function set.WriteAsync( obj, value )
obj.TransportChannel.WriteAsync = value;
end 

function value = get.AllowPartialReads( obj )

obj.validateConnected(  );
value = obj.TransportChannel.AllowPartialReads;
end 

function set.AllowPartialReads( obj, val )

obj.validateConnected(  );
obj.TransportChannel.AllowPartialReads = val;
end 

function value = get.ConnectionStatus( obj )
if isempty( obj.AsyncIOChannel ) || ~obj.AsyncIOChannel.isOpen(  )
value = 'Disconnected';
else 
value = 'Connected';
end 
end 

function value = get.BytesAvailable( obj )
if ~isempty( obj.AsyncIOChannel )
value = obj.AsyncIOChannel.InputStream.DataAvailable;
else 
value = 0;
end 
end 

function obj = set.Timeout( obj, value )%#ok<MCHV2>
try %#ok<*EMTC>

validateattributes( value, { 'numeric' }, { 'scalar', 'nonnegative', 'finite', 'nonnan' }, 'TCPClient', 'TIMEOUT' );

catch validationException
throwAsCaller( validationException );
end 
obj.setAsyncIOChannelTimeout( value );
obj.Timeout = value;
end 

function set.CustomConverterPlugIn( obj, value )
try 

validateDisconnected( obj );


validateattributes( value, { 'char', 'string' }, {  }, 'TCPClient', 'CUSTOMCONVERTERPLUGIN' );

catch validationException
throwAsCaller( validationException );
end 

obj.CustomConverterPlugIn = value;
end 

function set.ConnectTimeout( obj, value )
try 

validateattributes( value, { 'numeric' }, { 'scalar', '>=', 1, 'nonnan' }, 'TCPClient', 'CONNECTTIMEOUT' );


validateDisconnected( obj );

catch validationException
throwAsCaller( validationException );
end 

obj.ConnectTimeout = value;
end 

function set.InputBufferSize( obj, value )
try 

validateattributes( value, { 'numeric' }, { 'scalar', 'nonnegative', 'nonnan' }, 'TCPClient', 'INPUTBUFFERSIZE' );


validateDisconnected( obj );

catch validationException
throwAsCaller( validationException );
end 

obj.InputBufferSize = value;
end 

function set.OutputBufferSize( obj, value )
try 

validateattributes( value, { 'numeric' }, { 'scalar', 'nonnegative', 'nonnan' }, 'TCPClient', 'OUTPUTBUFFERSIZE' );


validateDisconnected( obj );

catch validationException
throwAsCaller( validationException );
end 

obj.OutputBufferSize = value;
end 

function set.BytesAvailableEventCount( obj, val )
try 
validateattributes( val, { 'numeric' }, { '>', 0, 'integer', 'scalar', 'finite', 'nonnan' }, mfilename, 'BytesAvailableEventCount' );
catch ex
throwAsCaller( ex );
end 
obj.BytesAvailableEventCount = val;
end 

function set.BytesAvailableFcn( obj, val )
if isempty( val )
val = function_handle.empty(  );
end 
try 
validateattributes( val, { 'function_handle' }, {  }, mfilename, 'BytesAvailableFcn' );
catch ex
throwAsCaller( ex );
end 


obj.recalculateLastCBValue(  );
obj.BytesAvailableFcn = val;
end 

function set.BytesWrittenFcn( obj, val )
if isempty( val )
val = function_handle.empty(  );
end 
try 
validateattributes( val, { 'function_handle' }, {  }, mfilename, 'BytesWrittenFcn' );
catch ex
throwAsCaller( ex );
end 
obj.BytesWrittenFcn = val;
end 

function set.ErrorOccurredFcn( obj, val )
if isempty( val )
val = function_handle.empty(  );
end 
try 
validateattributes( val, { 'function_handle' }, {  }, mfilename, 'ErrorOccurredFcn' );
catch ex
throwAsCaller( ex );
end 
obj.ErrorOccurredFcn = val;
end 

function value = get.NumBytesAvailable( obj )

obj.validateConnected(  );
value = obj.TransportChannel.NumBytesAvailable;
end 

function value = get.NumBytesWritten( obj )

obj.validateConnected(  );
value = obj.TransportChannel.NumBytesWritten;
end 

function value = get.InitAccess( obj )



obj.validateConnected(  );

obj.AsyncIOChannel.execute( [ 'GetInitAccessStatus', char( 0 ) ] );


value = obj.AsyncIOChannel.InitAccess;
end 

function set.ByteOrder( obj, value )

value = instrument.internal.stringConversionHelpers.str2char( value );
validateattributes( value, { 'char', 'string' }, { 'nonempty' }, mfilename, 'ByteOrder' );
value = validatestring( value, { 'little-endian', 'big-endian' } );
obj.ByteOrder = value;
if obj.Connected %#ok<MCSUP>
obj.TransportChannel.ByteOrder = obj.ByteOrder;%#ok<MCSUP>
end 
end 

function out = get.ByteOrder( obj )

out = obj.ByteOrder;
end 

function set.NativeDataType( obj, val )

validateattributes( val, { 'string', 'char' }, {  }, mfilename, 'val', 2 );
obj.NativeDataType = val;
if obj.Connected %#ok<MCSUP>
obj.TransportChannel.NativeDataType = val;%#ok<MCSUP>
end 
end 

function out = get.NativeDataType( obj )

out = obj.NativeDataType;
end 

function set.DataFieldName( obj, val )

validateattributes( val, { 'string', 'char' }, {  }, mfilename, 'val', 2 );
obj.DataFieldName = val;
if obj.Connected %#ok<MCSUP>
obj.TransportChannel.DataFieldName = val;%#ok<MCSUP>
end 
end 

function out = get.DataFieldName( obj )

out = obj.DataFieldName;
end 

function value = get.Connected( obj )
value = ~isempty( obj.TransportChannel ) &&  ...
obj.TransportChannel.Connected;
end 
end 


methods ( Access = public )



function obj = TCPClient( hostName, portNumber, varargin )
























hostName = instrument.internal.stringConversionHelpers.str2char( hostName );

try 

validateattributes( hostName, { 'char' }, { 'nonempty' }, 'TCPClient', 'HOSTNAME', 1 )


validateattributes( portNumber, { 'numeric' }, { '>=', 1, '<=', 65535, 'scalar', 'nonnegative', 'finite' }, 'TCPClient', 'PORTNUMBER', 2 )


obj.RemoteHost = hostName;
obj.RemotePort = portNumber;

p = inputParser;
p.PartialMatching = false;
addParameter( p, 'IsWriteOnly', false, @( x )validateattributes( x, { 'logical' }, { 'scalar' } ) );
addParameter( p, 'IsSharingPort', false, @( x )validateattributes( x, { 'logical' }, { 'scalar' } ) );
parse( p, varargin{ : } );
output = p.Results;

obj.IsWriteOnly = output.IsWriteOnly;
obj.IsSharingPort = output.IsSharingPort;


obj.FilterImpl = matlabshared.transportlib.internal.FilterImpl( obj );

catch validationException
throwAsCaller( validationException );
end 
end 

function connect( obj )





















if ( ~isempty( obj.AsyncIOChannel ) && obj.AsyncIOChannel.isOpen(  ) )
throwAsCaller( MException( 'network:tcpclient:alreadyConnectedError',  ...
message( 'network:tcpclient:alreadyConnectedError' ).getString(  ) ) );
end 

try 

initializeChannel( obj );



obj.TransportChannel =  ...
matlabshared.transportlib.internal.asyncIOTransportChannel.AsyncIOTransportChannel( obj.AsyncIOChannel );
obj.TransportChannel.ByteOrder = obj.ByteOrder;
obj.TransportChannel.NativeDataType = obj.NativeDataType;
obj.TransportChannel.DataFieldName = obj.DataFieldName;
catch asyncioError

formattedMessage = strrep( asyncioError.message, 'Unexpected exception in plug-in: ', '' );

formattedMessage = strrep( formattedMessage, '''', '' );

throwAsCaller( MException( 'network:tcpclient:connectFailed',  ...
message( 'network:tcpclient:connectFailed', formattedMessage ).getString(  ) ) );
end 
end 

function disconnect( obj )









terminateChannel( obj );
end 

function data = getTotalBytesWritten( obj )



data = [  ];
if ~isempty( obj.AsyncIOChannel )
data = obj.AsyncIOChannel.TotalBytesWritten;
end 
end 


function tuneInputFilter( obj, options )



narginchk( 2, 2 );

obj.validateConnected(  );
try 
obj.AsyncIOChannel.InputStream.tuneFilters( options );
catch asyncioError
throwAsCaller( obj.formatAsyncIOException( asyncioError, 'transportlib:filter:tuneInputFilterError' ) );
end 
end 

function tuneOutputFilter( obj, options )



narginchk( 2, 2 );

obj.validateConnected(  );
try 
obj.AsyncIOChannel.OutputStream.tuneFilters( options );
catch asyncioError
throwAsCaller( obj.formatAsyncIOException( asyncioError, 'transportlib:filter:tuneOutputFilterError' ) );
end 
end 

function addInputFilter( obj, filter, options )





narginchk( 3, 3 );
try 
obj.FilterImpl.addInputFilter( filter, options );
catch filterError
throwAsCaller( obj.formatAsyncIOException( filterError, 'transportlib:filter:addInputFilterError' ) );
end 
end 

function removeInputFilter( obj, filter )





narginchk( 2, 2 );
try 
obj.FilterImpl.removeInputFilter( filter );
catch filterError
throwAsCaller( obj.formatAsyncIOException( filterError, 'transportlib:filter:removeInputFilterError' ) );
end 
end 

function addOutputFilter( obj, filter, options )





narginchk( 3, 3 );
try 
obj.FilterImpl.addOutputFilter( filter, options );
catch filterError
throwAsCaller( obj.formatAsyncIOException( filterError, 'transportlib:filter:addOutputFilterError' ) );
end 
end 

function removeOutputFilter( obj, filter )





narginchk( 2, 2 );
try 
obj.FilterImpl.removeOutputFilter( filter );
catch filterError
throwAsCaller( obj.formatAsyncIOException( filterError, 'transportlib:filter:removeOutputFilterError' ) );
end 
end 

function [ inputFilters, inputFilterOptions ] = getInputFilters( obj )









[ inputFilters, inputFilterOptions ] = obj.FilterImpl.getInputFilters(  );
end 

function [ outputFilters, outputFilterOptions ] = getOutputFilters( obj )









[ outputFilters, outputFilterOptions ] = obj.FilterImpl.getOutputFilters(  );
end 


function data = read( varargin )












































try 
obj = varargin{ 1 };
obj.validateConnected(  );
catch validationEx
throwAsCaller( validationEx );
end 

try 
data = obj.TransportChannel.read( varargin{ 2:end  } );
catch ex
if obj.AllowPartialReads &&  ...
strcmpi( ex.identifier, 'transportlib:transport:timeout' )
data = [  ];
return 
end 

if ~isempty( ex.cause )
throwAsCaller( ex.cause{ 1 } );
else 
throwAsCaller( MException( 'network:tcpclient:receiveFailed',  ...
message( 'network:tcpclient:receiveFailed', ex.message ).getString(  ) ) );
end 
end 

end 

function data = readUntil( varargin )




















try 
narginchk( 2, 3 );
obj = varargin{ 1 };
obj.validateConnected(  );
catch validationEx
throwAsCaller( validationEx );
end 

try 
data = obj.TransportChannel.readUntil( varargin{ 2:end  } );
catch ex
throwAsCaller( MException( 'network:tcpclient:receiveFailed',  ...
message( 'network:tcpclient:receiveFailed', ex.message ).getString(  ) ) );
end 
end 

function data = readRaw( obj, numBytes )



















try 
data = obj.TransportChannel.readRaw( numBytes );
catch ex
throwAsCaller( MException( 'network:tcpclient:receiveFailed',  ...
message( 'network:tcpclient:receiveFailed', ex.message ).getString(  ) ) );
end 
end 

function tokenFound = peekUntil( obj, token )

















try 
narginchk( 2, 2 );
obj.validateConnected(  );
catch validationEx
throwAsCaller( validationEx );
end 

try 
tokenFound = obj.TransportChannel.peekUntil( token );
catch ex
throwAsCaller( MException( 'network:tcpclient:peekFailed',  ...
message( 'network:tcpclient:peekFailed', ex.message ).getString(  ) ) );
end 
end 

function write( varargin )




























try 
narginchk( 2, 3 );
obj = varargin{ 1 };
obj.validateConnected(  );
catch validationEx
throwAsCaller( validationEx );
end 

try 
obj.TransportChannel.write( varargin{ 2:end  } );
catch ex
if ~isempty( ex.cause )
throwAsCaller( ex.cause{ 1 } );
else 
throwAsCaller( MException( 'network:tcpclient:sendFailed',  ...
message( 'network:tcpclient:sendFailed', ex.message ).getString(  ) ) );
end 
end 
end 

function writeAsync( varargin )


































try 
obj = varargin{ 1 };
obj.validateConnected(  );
catch validationEx
throwAsCaller( validationEx );
end 

try 
obj.TransportChannel.writeAsync( varargin{ 2:end  } );
catch ex
if ~isempty( ex.cause )
throwAsCaller( ex.cause{ 1 } );
else 
throwAsCaller( MException( 'network:tcpclient:sendFailed',  ...
message( 'network:tcpclient:sendFailed', ex.message ).GetString(  ) ) );
end 
end 
end 

function numbytes = writeAsyncRaw( obj, dataToWrite )



















numbytes = obj.TransportChannel.writeAsyncRaw( dataToWrite );
end 

function flushInput( obj )



obj.validateConnected(  );
try 

obj.AsyncIOChannel.execute( 'ResetTotalBytesWritten' );

obj.AsyncIOChannel.InputStream.flush(  );

obj.TransportChannel.flushUnreadData(  );

obj.LastCallbackVal = 0;
catch asyncioError
throwAsCaller( obj.formatAsyncIOException( asyncioError, 'network:tcpclient:flushInputFailed' ) );
end 
end 

function flushOutput( obj )



obj.validateConnected(  );
try 

obj.AsyncIOChannel.OutputStream.flush(  );
catch asyncioError
throwAsCaller( obj.formatAsyncIOException( asyncioError, 'network:tcpclient:flushOutputFailed' ) );
end 
end 

function index = peekBytesFromEnd( obj, lastCallbackIndex, token )





















try 
narginchk( 3, 3 );
obj.validateConnected(  );
catch validationEx
throwAsCaller( validationEx );
end 
try 
index = obj.TransportChannel.peekBytesFromEnd( lastCallbackIndex, token );
catch ex
throwAsCaller( MException( 'network:tcpclient:peekFailed',  ...
message( 'network:tcpclient:peekFailed', ex.message ).getString(  ) ) );
end 
end 
end 

methods ( Access = private )

function initializeChannel( obj )




options.HostName = obj.RemoteHost;
options.ServiceName = num2str( obj.RemotePort );
options.IsWriteOnly = obj.IsWriteOnly;
options.IsSharingPort = obj.IsSharingPort;

if ~isempty( obj.CustomConverterPlugIn )
converterPlugin = obj.CustomConverterPlugIn;
else 
converterPlugin = obj.ConverterPlugin;
end 


obj.AsyncIOChannel = matlabshared.asyncio.internal.Channel( obj.DevicePlugin,  ...
converterPlugin,  ...
Options = options,  ...
StreamLimits = [ obj.InputBufferSize, obj.OutputBufferSize ] );

obj.setAsyncIOChannelTimeout( obj.Timeout );



obj.ReceiveCallbackListener = event.listener(  ...
obj.AsyncIOChannel.InputStream,  ...
'DataWritten',  ...
@obj.onDataReceived );



obj.SendCallbackListener = event.listener(  ...
obj.AsyncIOChannel.OutputStream,  ...
'DataRead',  ...
@obj.onDataWritten );

obj.CustomListener = addlistener( obj.AsyncIOChannel,  ...
'Custom',  ...
@obj.handleCustomEvent );


[ inputFilters, inputFilterOptions ] = obj.FilterImpl.getInputFilters(  );
[ outputFilters, outputFilterOptions ] = obj.FilterImpl.getOutputFilters(  );


for i = 1:length( inputFilters )
obj.AsyncIOChannel.InputStream.addFilter( inputFilters{ i }, inputFilterOptions{ i } );
end 
for i = 1:length( outputFilters )
obj.AsyncIOChannel.OutputStream.addFilter( outputFilters{ i }, outputFilterOptions{ i } );
end 


options.ReceiveSize = obj.DefaultSocketSize;
options.SendSize = obj.DefaultSocketSize;
options.ConnectTimeout = obj.ConnectTimeout;
options.TransferDelay = obj.TransferDelay;


obj.AsyncIOChannel.open( options );

end 

function setAsyncIOChannelTimeout( obj, value )



if ( ~isempty( obj.AsyncIOChannel ) )

obj.AsyncIOChannel.OutputStream.Timeout = value;
obj.AsyncIOChannel.InputStream.Timeout = value;
end 
end 

function ex = formatAsyncIOException( ~, asyncioError, errorid )





formattedMessage = strrep( asyncioError.message, 'Unexpected exception in plug-in: ', '' );

formattedMessage = strrep( formattedMessage, '''', '' );

ex = MException( errorid, message( errorid, formattedMessage ).getString(  ) );
end 

function terminateChannel( obj )



if ( ~isempty( obj.AsyncIOChannel ) )
obj.AsyncIOChannel.close(  );
delete( obj.AsyncIOChannel );
delete( obj.ReceiveCallbackListener );
delete( obj.SendCallbackListener );
obj.AsyncIOChannel = [  ];
obj.ReceiveCallbackListener = [  ];
obj.SendCallbackListener = [  ];
obj.TransportChannel = [  ];
end 
end 

function validateDisconnected( obj )




if obj.Connected
throwAsCaller( MException( message( 'transportlib:transport:cannotSetWhenConnected' ) ) );
end 
end 

function validateConnected( obj )




if ~obj.Connected
throwAsCaller( MException( 'transportlib:transport:invalidConnectionState',  ...
message( 'transportlib:transport:invalidConnectionState', 'remote server' ).getString(  ) ) );
end 
end 

function onDataReceived( obj, ~, ~ )




count = obj.AsyncIOChannel.InputStream.DataAvailable;
if count > 0
notify( obj, 'DataReceived' );
end 


if isempty( obj.BytesAvailableFcn )
return ;
end 

if obj.SingleCallbackMode
obj.BytesAvailableFcn( obj,  ...
matlabshared.transportlib.internal.DataAvailableInfo( obj.BytesAvailableEventCount ) );

else 


deltaFromLastCallback = obj.AsyncIOChannel.TotalBytesWritten - obj.LastCallbackVal;





numCallbacks = floor( double( deltaFromLastCallback ) / double( obj.BytesAvailableEventCount ) );

for idx = 1:numCallbacks
if isempty( obj.BytesAvailableFcn )
break 
end 
obj.BytesAvailableFcn( obj,  ...
matlabshared.transportlib.internal.DataAvailableInfo( obj.BytesAvailableEventCount ) );
end 




obj.LastCallbackVal = obj.LastCallbackVal +  ...
numCallbacks * obj.BytesAvailableEventCount;
end 
end 

function onDataWritten( obj, ~, ~ )




space = obj.AsyncIOChannel.OutputStream.SpaceAvailable;
if space > 0
notify( obj, 'DataSent' );
end 


if isempty( obj.BytesWrittenFcn )
return ;
end 



space = obj.AsyncIOChannel.OutputStream.SpaceAvailable;
if space > 0
obj.BytesWrittenFcn( obj,  ...
matlabshared.transportlib.internal.DataWrittenInfo( space ) );
end 
end 

function handleCustomEvent( obj, ~, eventData )



errorId = eventData.Data.ErrorID;


if ~isempty( obj.ErrorOccurredFcn )
obj.ErrorOccurredFcn( obj,  ...
matlabshared.transportlib.internal.ErrorInfo( eventData.Data.ErrorID,  ...
eventData.Data.ErrorMessage ) );
else 
error( errorId, message( errorId ).getString(  ) );
end 
end 
end 

methods ( Static = true, Hidden = true )
function out = loadobj( s )




out = [  ];
if isstruct( s )
out = matlabshared.network.internal.TCPClient( s.RemoteHost, s.RemotePort, 'IsSharingPort', s.IsSharingPort, 'IsWriteOnly', s.IsWriteOnly );
out.Timeout = s.Timeout;
out.InputBufferSize = s.InputBufferSize;
out.OutputBufferSize = s.OutputBufferSize;
if isfield( s, 'ConnectTimeout' )
out.ConnectTimeout = s.ConnectTimeout;
end 
if isfield( s, 'ByteOrder' )
out.ByteOrder = s.ByteOrder;
end 
if isfield( s, 'NativeDataType' )
out.NativeDataType = s.NativeDataType;
end 
if isfield( s, 'DataFieldName' )
out.DataFieldName = s.DataFieldName;
end 

if strcmpi( s.Connected, 'Connected' )
try 
out.connect(  );
catch connectFailed



warning( 'network:tcpclient:connectFailed', '%s', connectFailed.message );
end 
end 
end 
end 
end 


methods ( Hidden )

function s = saveobj( obj )

s.RemoteHost = obj.RemoteHost;
s.RemotePort = obj.RemotePort;
s.IsWriteOnly = obj.IsWriteOnly;
s.IsSharingPort = obj.IsSharingPort;
s.Timeout = obj.Timeout;
s.InputBufferSize = obj.InputBufferSize;
s.OutputBufferSize = obj.OutputBufferSize;
s.Connected = obj.ConnectionStatus;
s.ConnectTimeout = obj.ConnectTimeout;
s.ByteOrder = obj.ByteOrder;
s.NativeDataType = obj.NativeDataType;
s.DataFieldName = obj.DataFieldName;
end 

function delete( obj )




obj.FilterImpl = [  ];
terminateChannel( obj );
end 
end 


properties ( Hidden, GetAccess = public, SetAccess = private, Dependent )


BytesAvailable
end 


methods ( Hidden )

function data = receive( obj, size, precision )

































data = obj.read( size, precision );
end 

function [ data, errorStr ] = receiveRaw( obj, numBytes )





















data = [  ];
errorStr = '';
try 
data = obj.readRaw( numBytes );
catch e
errorStr = e.message;
end 
end 

function send( obj, data )



















obj.write( data );
end 

function sendAsync( obj, dataToWrite )


















obj.writeAsync( dataToWrite );
end 

function [ numBytes, errorStr ] = sendRawAsync( obj, dataToWrite )




















numBytes = 0;
errorStr = '';
try 
numBytes = obj.writeAsyncRaw( dataToWrite );
catch e
errorStr = e.message;
end 
end 

function recalculateLastCBValue( obj )








if ~isempty( obj.AsyncIOChannel ) && obj.Connected
obj.LastCallbackVal =  ...
obj.AsyncIOChannel.TotalBytesWritten - obj.NumBytesAvailable;
else 
obj.LastCallbackVal = 0;
end 
end 
end 


events ( NotifyAccess = private )


DataReceived;


DataSent;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpQxNSN2.p.
% Please follow local copyright laws when handling this file.

