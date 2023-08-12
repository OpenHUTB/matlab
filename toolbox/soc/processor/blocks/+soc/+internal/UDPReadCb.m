function varargout = UDPReadCb( func, blkH, varargin )




if nargout == 0
feval( func, blkH, varargin{ : } );
else 
[ varargout{ 1:nargout } ] = feval( func, blkH, varargin{ : } );
end 
end 

function MaskInitFcn( blkH )%#ok<*DEFNU>
persistent hadError
if isempty( hadError )
hadError = false;
end 

blkPath = soc.blkcb.cbutils( 'GetBlkPath', blkH );
blkP = soc.blkcb.cbutils( 'GetDialogParams', blkH, 'slResolve' );

l_SetMaskHelp( blkH );

try 
if isa( blkP.DataType, 'Simulink.NumericType' )
assert( blkP.DataType.WordLength <= REG_MAX_WORDLEN, message( 'soc:msgs:MaxRegistersWordLength', REG_MAX_WORDLEN ) );
end 
if isa( blkP.DataType, 'Simulink.AliasType' )
DataType = numerictype( eval( blkP.DataType.BaseType ) );
assert( DataType.WordLength <= REG_MAX_WORDLEN, message( 'soc:msgs:MaxRegistersWordLength', REG_MAX_WORDLEN ) );
end 

validateattributes( blkP.DataLength, { 'numeric' }, { 'integer', 'nonnan', 'finite', 'nonempty', 'scalar', '>', 0 }, '', 'Maximum data length (elements)' );
validateattributes( blkP.ReceiveBufferSize, { 'numeric' }, { 'nonnan', 'finite', 'scalar', 'integer', 'nonempty', '>=', numel( typecast( cast( 0, blkP.DataType ), 'uint8' ) ) }, '', '"Receive buffer size (bytes)"' );
DataLengthInBytes = ( numel( typecast( cast( 0, blkP.DataType ), 'uint8' ) ) * blkP.DataLength );
ReceiveQueueLength = floor( blkP.ReceiveBufferSize / DataLengthInBytes );

msg = message( 'soc:msgs:ReceiveBufferQueueSizeRange', intmax( 'uint16' ), blkP.ReceiveBufferSize, blkP.DataLength, blkP.DataType, ReceiveQueueLength );
assert( ReceiveQueueLength > 0 && ReceiveQueueLength <= 65535, msg.getString );
if isequal( get_param( codertarget.utils.getModelForBlock( blkH ), 'SimulationStatus' ), 'stopped' )
hHWSWMessageReceive = [ blkPath, '/Variant/SIM/HWSW Message Receive' ];
set_param( hHWSWMessageReceive, 'QueueLength', num2str( ReceiveQueueLength ),  ...
'DataTypeStr', get_param( blkH, 'DataType' ),  ...
'Dimensions', num2str( blkP.DataLength ) );
end 


if isequal( blkP.EnableEvent, 'on' )
set_param( [ blkPath, '/', get_param( blkH, 'hoistedMaskSrc' ) ], 'BlockingTime', 'Inf' );

set_param( [ blkPath, '/', get_param( blkH, 'hoistedMaskSrc' ) ], 'HideEventLines', 'off' );
else 
set_param( [ blkPath, '/', get_param( blkH, 'hoistedMaskSrc' ) ], 'BlockingTime', '0' );

set_param( [ blkPath, '/', get_param( blkH, 'hoistedMaskSrc' ) ], 'HideEventLines', 'on' );
end 

l_SetMaskDisplay( blkH, blkP );
soc.internal.setBlockIcon( blkH, 'socicons.UDPRead' );
catch ME
hadError = true;
rethrow( ME );
end 
end 

function LoadFcn( blkH )
if soc.blkcb.cbutils( 'IsLibContext', blkH ), return ;end 
end 

function InitFcn( blkH )
blkPath = soc.blkcb.cbutils( 'GetBlkPath', blkH );
blkP = soc.blkcb.cbutils( 'GetDialogParams', blkH, 'slResolve' );
if isequal( blkP.EnableEvent, 'on' )
soc.internal.IOBlockSemantics.verifyBlockInEventDrivenTask( blkPath );
end 
soc.internal.HWSWMessageTypeDef(  );
end 

function PreSaveFcn( blkH )
if soc.blkcb.cbutils( 'IsLibContext', blkH ), return ;end 
end 

function l_SetMaskDisplay( blkH, blkP )%#ok<INUSD>

currentBlock = blkH;
soc.blocks.hoistedMaskCallback( 'adaptMaskDisplay' );
md = get_param( currentBlock, 'MaskDisplay' );
md = [ md, newline, 'port_label(''input'', 1, ''msg'')' ];
set_param( currentBlock, 'MaskDisplay', md );
end 

function l_SetMaskHelp( blkH )
helpcmd = 'eval(''soc.internal.helpview(''''soc_udpread'''')'')';
set_param( blkH, 'MaskHelp', helpcmd );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpGcnSPq.p.
% Please follow local copyright laws when handling this file.

