function varargout = StreamReadCb( func, blkH, varargin )



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
hAXI4StreamRead = [ blkPath, '/Variant/CODEGEN/AXI4-Stream Read' ];
hHWSWMessageReceive = [ blkPath, '/Variant/SIM/HWSW Message Receive' ];
hStreamReadDataPort = [ blkPath, '/data' ];

if isequal( blkP.EnableEvent, 'on' )

hideEventLines = 'off';
dataTimeout = 'Inf';
else 

hideEventLines = 'on';
dataTimeout = '0';
end 

if exist( 'procspkglib_internal', 'file' )
set_param( hAXI4StreamRead, 'devName', blkP.DeviceName );
set_param( hAXI4StreamRead, 'dataTypeStr', get_param( blkH, 'OutDataTypeStr' ) );
set_param( hAXI4StreamRead, 'SamplesPerFrame', num2str( blkP.SamplesPerFrame ) );
set_param( hAXI4StreamRead, 'NumBuffers', num2str( blkP.NumberOfBuffers ) );
set_param( hAXI4StreamRead, 'SampleTime', num2str( blkP.SampleTime ) );
set_param( hAXI4StreamRead, 'DataTimeout', dataTimeout );
set_param( hAXI4StreamRead, 'HideEventLines', hideEventLines );
end 

set_param( hStreamReadDataPort, 'OutDataTypeStr', get_param( blkH, 'OutDataTypeStr' ) );
set_param( hStreamReadDataPort, 'PortDimensions', num2str( blkP.SamplesPerFrame ) );

set_param( hHWSWMessageReceive, 'DataTypeStr', get_param( blkH, 'OutDataTypeStr' ) );
set_param( hHWSWMessageReceive, 'Dimensions', num2str( blkP.SamplesPerFrame ) );
set_param( hHWSWMessageReceive, 'QueueLength', num2str( blkP.NumberOfBuffers ) );

l_SetMaskDisplay( blkH, blkP );
soc.internal.setBlockIcon( blkH, 'socicons.StreamRead' );
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

function l_SetMaskDisplay( blkH, blkP )
fulltext1 = sprintf( 'color(''black'')' );
fulltext2 = sprintf( 'text(0.5, 0.2,''%s'',''horizontalAlignment'',''center'',''texmode'',''off'')', blkP.DeviceName );

md = sprintf( '%s;\n%s;\n%s;\n%s', fulltext1, fulltext2 );
set_param( blkH, 'MaskDisplay', md );
end 

function l_SetMaskHelp( blkH )
helpcmd = 'eval(''soc.internal.helpview(''''soc_streamread'''')'')';
set_param( blkH, 'MaskHelp', helpcmd );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpr8tkwF.p.
% Please follow local copyright laws when handling this file.

