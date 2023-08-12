function varargout = TCPReadCb( func, blkH, varargin )




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
hHWSWMessageReceive = [ blkPath, '/Variant/SIM/HWSW Message Receive' ];

if isa( blkP.DataType, 'Simulink.NumericType' )
assert( blkP.DataType.WordLength <= REG_MAX_WORDLEN, message( 'soc:msgs:MaxRegistersWordLength', REG_MAX_WORDLEN ) );
end 
if isa( blkP.DataType, 'Simulink.AliasType' )
DataType = numerictype( eval( blkP.DataType.BaseType ) );
assert( DataType.WordLength <= REG_MAX_WORDLEN, message( 'soc:msgs:MaxRegistersWordLength', REG_MAX_WORDLEN ) );
end 


set_param( hHWSWMessageReceive, 'QueueLength', '65535' );
set_param( hHWSWMessageReceive, 'DataTypeStr', get_param( blkH, 'DataType' ) );
set_param( hHWSWMessageReceive, 'Dimensions', num2str( blkP.DataLength ) );


if isequal( blkP.EnableEvent, 'on' )
set_param( [ blkPath, '/', get_param( blkH, 'hoistedMaskSrc' ) ], 'BlockingTime', 'Inf' );

set_param( [ blkPath, '/', get_param( blkH, 'hoistedMaskSrc' ) ], 'HideEventLines', 'off' );
else 
set_param( [ blkPath, '/', get_param( blkH, 'hoistedMaskSrc' ) ], 'BlockingTime', '0' );

set_param( [ blkPath, '/', get_param( blkH, 'hoistedMaskSrc' ) ], 'HideEventLines', 'on' );
end 

l_SetMaskDisplay( blkH, blkP );
soc.internal.setBlockIcon( blkH, 'socicons.TCPRead' );
catch ME
hadError = true;
rethrow( ME );
end 
end 

function l_SetMaskDisplay( blkH, blkP )%#ok<INUSD>

currentBlock = blkH;
soc.blocks.hoistedMaskCallback( 'adaptMaskDisplay' );
md = get_param( currentBlock, 'MaskDisplay' );
md = [ md, newline, 'port_label(''input'', 1, ''msg'')' ];
set_param( currentBlock, 'MaskDisplay', md );
end 

function l_SetMaskHelp( blkH, ~ )
helpcmd = 'eval(''soc.internal.helpview(''''soc_tcpread'''')'')';
set_param( blkH, 'MaskHelp', helpcmd );
end 


function InitFcn( blkH )
blkPath = soc.blkcb.cbutils( 'GetBlkPath', blkH );
blkP = soc.blkcb.cbutils( 'GetDialogParams', blkH, 'slResolve' );
if isequal( blkP.EnableEvent, 'on' )
soc.internal.IOBlockSemantics.verifyBlockInEventDrivenTask( blkPath );
end 
soc.internal.HWSWMessageTypeDef(  );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpdo5gtK.p.
% Please follow local copyright laws when handling this file.

