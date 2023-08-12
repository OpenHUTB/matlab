function varargout = RegisterReadCb( func, blkH, varargin )
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
REG_MAX_WORDLEN = 32;

blkPath = soc.blkcb.cbutils( 'GetBlkPath', blkH );
blkP = soc.blkcb.cbutils( 'GetDialogParams', blkH, 'slResolve' );

l_SetMaskHelp( blkH );

try 
hAXI4RegisterRead = [ blkPath, '/Variant/CODEGEN/AXI4-Register Read' ];
hDataTypeConversion = [ blkPath, '/Variant/CODEGEN/Data Type Conversion' ];
hHWSWMessageReceive = [ blkPath, '/Variant/SIM/HWSW Message Receive' ];
hRegisterReadDataPort = [ blkPath, '/data' ];

switch ( class( blkP.OutDataTypeStr ) )

case 'Simulink.NumericType'
assert( blkP.OutDataTypeStr.WordLength <= REG_MAX_WORDLEN, message( 'soc:msgs:MaxRegistersWordLength', REG_MAX_WORDLEN ) );
case 'char'
;%#ok<NOSEMI> %do nothing
case 'Simulink.AliasType'
try 
DataType = blkP.OutDataTypeStr.BaseType;
DataType = evalin( 'base', DataType );
catch ME %#ok<NASGU>

end 
switch class( DataType )
case 'Simulink.NumericType'
assert( DataType.WordLength <= REG_MAX_WORDLEN, message( 'soc:msgs:MaxRegistersWordLength', REG_MAX_WORDLEN ) );
case 'char'
;%#ok<NOSEMI> %do nothing
otherwise 
error( 'Data type not supported' );
end 
otherwise 
error( 'Data type not supported' );
end 


set_param( hAXI4RegisterRead, 'DeviceName', blkP.DeviceName );
set_param( hAXI4RegisterRead, 'RegisterOffset', num2str( blkP.OffsetAddress ) );
set_param( hDataTypeConversion, 'OutDataTypeStr', get_param( blkH, 'OutDataTypeStr' ) );
set_param( hAXI4RegisterRead, 'DataLength', num2str( blkP.OutputVectorSize ) );
set_param( hAXI4RegisterRead, 'SampleTime', num2str( blkP.SampleTime ) );

set_param( hRegisterReadDataPort, 'OutDataTypeStr', get_param( blkH, 'OutDataTypeStr' ) );
set_param( hRegisterReadDataPort, 'PortDimensions', get_param( blkH, 'OutputVectorSize' ) );

set_param( hHWSWMessageReceive, 'DataTypeStr', get_param( blkH, 'OutDataTypeStr' ) );
set_param( hHWSWMessageReceive, 'Dimensions', num2str( blkP.OutputVectorSize ) );

l_SetMaskDisplay( blkH, blkP );
soc.internal.setBlockIcon( blkH, 'socicons.RegisterRead' );
catch ME
hadError = true;
rethrow( ME );
end 
end 

function l_SetMaskDisplay( blkH, blkP )
fulltext1 = sprintf( 'color(''black'')' );
fulltext2 = sprintf( 'text(0.5, 0.3, ''%s'',''horizontalAlignment'',''center'',''texmode'',''off'')', blkP.DeviceName );
fulltext3 = sprintf( 'text(0.5, 0.15, ''0x%s'',''horizontalAlignment'',''center'',''texmode'',''off'')', dec2hex( blkP.OffsetAddress ) );

md = sprintf( '%s;\n%s;\n%s;\n%s', fulltext1, fulltext2, fulltext3 );
set_param( blkH, 'MaskDisplay', md );
end 

function l_SetMaskHelp( blkH )
helpcmd = 'eval(''soc.internal.helpview(''''soc_registerread'''')'')';
set_param( blkH, 'MaskHelp', helpcmd );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp8tE3wZ.p.
% Please follow local copyright laws when handling this file.

