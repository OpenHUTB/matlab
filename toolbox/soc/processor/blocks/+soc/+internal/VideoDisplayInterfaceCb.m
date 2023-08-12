function varargout = VideoDisplayInterfaceCb( func, blkH, varargin )




if nargout == 0
feval( func, blkH, varargin{ : } );
else 
[ varargout{ 1:nargout } ] = feval( func, blkH, varargin{ : } );
end 
end 


function MaskParamCb( blkH, paramName )
cbH = eval( [ '@', paramName, 'Cb' ] );
soc.blkcb.cbutils( 'MaskParamCb', paramName, blkH, cbH );
end 


function LoadFcn( blkH )
if soc.blkcb.cbutils( 'IsLibContext', blkH ), return ;end 
end 


function InitFcn( blkH )%#ok<INUSD>
soc.internal.HWSWMessageTypeDef(  );
end 


function PreSaveFcn( blkH )
if soc.blkcb.cbutils( 'IsLibContext', blkH ), return ;end 
end 


function MaskInitFcn( blkH )%#ok<*DEFNU>
persistent hadError
if isempty( hadError )
hadError = false;
end 
blkPath = soc.blkcb.cbutils( 'GetBlkPath', blkH );
blkP = soc.blkcb.cbutils( 'GetDialogParams', blkH, 'slResolve' );
sysH = bdroot( blkH );
try 
hSinkVariant = [ blkPath, '/Variant/SIM/Sink Variant' ];
hwMsgBlk = [ blkPath, '/Variant/SIM/HWSW Message Receive' ];
switch blkP.OutputSink
case 'To output port'
set_param( hSinkVariant, 'OverrideUsingVariant', 'ToOutputPort' );
set_param( hwMsgBlk, 'DiscardMessage', 'off' );
set_param( hwMsgBlk, 'DataTypeStr', 'uint8',  ...
'Dimensions', num2str( locGetNumElemsBuffer( blkP ) ) );
case 'To terminator'
set_param( hSinkVariant, 'OverrideUsingVariant', 'ToTerminator' );
set_param( hwMsgBlk, 'DiscardMessage', 'on' );
end 
dataPortH = find_system( blkH, 'SearchDepth', '1', 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'regexp', 'on', 'BlockType', 'Inport', 'Name', 'Data' );
set_param( dataPortH, 'Name', 'Data' );
blkP = soc.blkcb.cbutils( 'GetDialogParams', blkH, 'slResolve' );


if isequal( get_param( bdroot( blkH ), 'SimulationStatus' ), 'stopped' )
locUpdateSubsystemPorts( blkH, blkPath, sysH, blkP );
end 
soc.internal.setBlockIcon( blkH, 'socicons.VideoDisplayInterface' );
locSetMaskHelp( blkH );
catch ME
hadError = true;
rethrow( ME );
end 
end 


function [ vis, ens ] = OutputSinkCb( blkH, val, vis, ens, idxMap )
blkP = soc.blkcb.cbutils( 'GetDialogParams', blkH, 'slResolve' );
if isequal( blkP.ImageSize', 'custom' ), llv = 'on';else , llv = 'off';end 
switch val
case 'To output port'
vis{ idxMap( 'ImageSize' ) } = 'on';
ens{ idxMap( 'ImageSize' ) } = 'on';
vis{ idxMap( 'ImageSizeCustom' ) } = llv;
ens{ idxMap( 'ImageSizeCustom' ) } = llv;
vis{ idxMap( 'PixelFormat' ) } = 'on';
ens{ idxMap( 'PixelFormat' ) } = 'on';
case 'To terminator'
vis{ idxMap( 'ImageSize' ) } = 'off';
ens{ idxMap( 'ImageSize' ) } = 'off';
vis{ idxMap( 'ImageSizeCustom' ) } = 'off';
ens{ idxMap( 'ImageSizeCustom' ) } = 'off';
vis{ idxMap( 'PixelFormat' ) } = 'off';
ens{ idxMap( 'PixelFormat' ) } = 'off';
otherwise 
error( '(internal) illegal input type' );
end 
end 


function [ vis, ens ] = ImageSizeCb( blkH, ~, vis, ens, idxMap )
blkP = soc.blkcb.cbutils( 'GetDialogParams', blkH, 'slResolve' );
if isequal( blkP.ImageSize, 'custom' )
vis{ idxMap( 'ImageSizeCustom' ) } = 'on';
ens{ idxMap( 'ImageSizeCustom' ) } = 'on';
else 
vis{ idxMap( 'ImageSizeCustom' ) } = 'off';
ens{ idxMap( 'ImageSizeCustom' ) } = 'off';
end 
end 


function sz = locGetImageSize( blkP )
if isequal( blkP.ImageSize, 'custom' )
sz = blkP.ImageSizeCustom;
else 
sz = str2num( strrep( blkP.ImageSize, 'x', ' ' ) );%#ok<ST2NM>
end 
end 


function bufSize = locGetNumElemsBuffer( blkP )
sz = locGetImageSize( blkP );
if isequal( blkP.PixelFormat, 'RGB' ), numBuf = 3;else , numBuf = 2;end 
bufSize = numBuf * sz( 1 ) * sz( 2 );
end 


function [ dataPortH, donePortH, eventPortH, msgPortH ] = locFindPorts( blkH, blkPath, DataPortStr, DonePortStr, EventPortStr, MsgPortStr )
blkportH = get_param( blkH, 'PortHandles' );
if strcmp( get_param( [ blkPath, '/', DataPortStr ], 'BlockType' ), 'Outport' )
dataPortH = blkportH.Outport( 1 );
else 
dataPortH = [  ];
end 
if strcmp( get_param( [ blkPath, '/', DonePortStr ], 'BlockType' ), 'Outport' )
donePortH = blkportH.Outport( 1 );
else 
donePortH = [  ];
end 
if strcmp( get_param( [ blkPath, '/', EventPortStr ], 'BlockType' ), 'Outport' )
eventPortH = blkportH.Outport( end  );
else 
eventPortH = [  ];
end 
if strcmp( get_param( [ blkPath, '/', MsgPortStr ], 'BlockType' ), 'Inport' )
msgPortH = blkportH.Inport( end  );
else 
msgPortH = [  ];
end 
end 


function locUpdateSubsystemPorts( blkH, blkPath, ~, blkP )
dataPortStr = 'data';
donePortStr = 'done';
eventPortStr = 'event';
msgPortStr = 'msg';
[ dataPortH, donePortH, eventPortH, ~ ] = locFindPorts( blkH, blkPath, dataPortStr, donePortStr, eventPortStr, msgPortStr );
interfaceChange = false;
msgPort = true;
eventPort = false;
if eventPortH
interfaceChange = true;
dataBlk = replace_block( blkPath, 'SearchDepth', '1', 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'Name', eventPortStr, 'Terminator', 'noprompt' );
assert( ~isempty( dataBlk ), message( 'soc:msgs:InternalNoNewBlkFor', 'event ground' ) );
set_param( dataBlk{ 1 }, 'Name', eventPortStr );
end 
donePort = false;
if donePortH
interfaceChange = true;
newdblk = replace_block( blkPath, 'SearchDepth', '1', 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'Name', donePortStr, 'Terminator', 'noprompt' );
assert( ~isempty( newdblk ), message( 'soc:msgs:InternalNoNewBlkFor', 'done ground' ) );
set_param( newdblk{ 1 }, 'Name', donePortStr );
end 
switch blkP.OutputSink
case 'To output port'
outPort = true;
if isempty( dataPortH )
interfaceChange = true;
dataBlock = replace_block( blkPath, 'SearchDepth', '1', 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'Name', dataPortStr, 'Outport', 'noprompt' );
assert( ~isempty( dataBlock ), message( 'soc:msgs:InternalNoNewBlkFor', 'data outport' ) );
set_param( dataBlock{ 1 }, 'Name', dataPortStr );
end 
case 'To terminator'
outPort = false;
if dataPortH
interfaceChange = true;
dataBlock = replace_block( blkPath, 'SearchDepth', '1', 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'Name', dataPortStr, 'Terminator', 'noprompt' );
assert( ~isempty( dataBlock ), message( 'soc:msgs:InternalNoNewBlkFor', 'data terminator' ) );
set_param( dataBlock{ 1 }, 'Name', dataPortStr );
end 
end 
s = soc.blkcb.GenPortSchema( 'IO Data Sink', outPort, donePort, eventPort, msgPort );
set_param( blkH, 'PortSchema', s );
if interfaceChange


pos = get_param( blkPath, 'Position' );
set_param( blkPath, 'Position', pos - [ 10, 10, 20, 20 ] );
set_param( blkPath, 'Position', pos );
end 
end 


function locSetMaskHelp( blkH )
helpcmd = 'eval(''soc.internal.helpview(''''soc_videodisplayinterface'''')'')';
set_param( blkH, 'MaskHelp', helpcmd );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpFjpXGl.p.
% Please follow local copyright laws when handling this file.

