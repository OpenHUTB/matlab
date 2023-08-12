function varargout = VideoCaptureCb( func, blkH, varargin )





if nargout == 0
feval( func, blkH, varargin{ : } );
else 
[ varargout{ 1:nargout } ] = feval( func, blkH, varargin{ : } );
end 
end 


function MaskParamCb( blkH, paramName )
cbH = eval( [ '@', paramName, 'Cb' ] );
soc.blkcb.cbutils( 'MaskParamCb', paramName, blkH, cbH )
end 


function LoadFcn( blkH )
if soc.blkcb.cbutils( 'IsLibContext', blkH ), return ;end 
end 


function InitFcn( ~ )
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
allLbls = { 'Y', 'Cb', 'Cr';'R', 'G', 'B' };
blkPath = soc.blkcb.cbutils( 'GetBlkPath', blkH );
blkP = soc.blkcb.cbutils( 'GetDialogParams', blkH, 'slResolve' );
try 
codeGenBlk = [ blkPath, '/Variant/CODEGEN/Video Capture' ];
if isequal( get_param( codertarget.utils.getModelForBlock( blkH ), 'SimulationStatus' ), 'stopped' )
hwMsgBlk = [ blkPath, '/Variant/SIM/HWSW Message Receive' ];
set_param( hwMsgBlk, 'DataTypeStr', 'uint8',  ...
'Dimensions', num2str( locGetNumElemsBuffer( blkP ) ) );
locSetSelectorReshape( blkPath, blkP, locGetImageSize( blkP ) );
end 





set_param( blkPath, 'BlockSID', codertarget.peripherals.utils.getBlockSID( blkH, false ) );


blockSID = codertarget.peripherals.utils.getBlockSID( blkH, true );
set_param( codeGenBlk, 'BlockID', blockSID );
set_param( codeGenBlk, 'PixelFormat', blkP.PixelFormat );
set_param( codeGenBlk, 'ImageWidth', num2str( locGetImageWidth( blkP ) ) );
set_param( codeGenBlk, 'ImageHeight', num2str( locGetImageHeight( blkP ) ) );
set_param( codeGenBlk, 'Out1NumElements', num2str( locGetNumElemsOut( blkP, 1 ) ) );
set_param( codeGenBlk, 'Out2NumElements', num2str( locGetNumElemsOut( blkP, 2 ) ) );
set_param( codeGenBlk, 'Out3NumElements', num2str( locGetNumElemsOut( blkP, 3 ) ) );
set_param( codeGenBlk, 'SampleTime', num2str( blkP.SampleTime ) );
soc.internal.setBlockIcon( blkH, 'socicons.VideoCapture' );
inp1 = sprintf( 'port_label(''input'',1,''msg'')' );
lblIdx = isequal( blkP.PixelFormat, 'RGB' ) + 1;
portLbl = allLbls( lblIdx, : );
out1 = sprintf( '%s, %d, ''%s'')', 'port_label(''output''', 1, portLbl{ 1 } );
out2 = sprintf( '%s, %d, ''%s'')', 'port_label(''output''', 2, portLbl{ 2 } );
out3 = sprintf( '%s, %d, ''%s'')', 'port_label(''output''', 3, portLbl{ 3 } );
fullLbl = sprintf( '%s;\n %s; \n %s; \n %s;', inp1, out1, out2, out3 );
set_param( blkH, 'MaskDisplay', fullLbl );
locSetMaskHelp( blkH );
catch ME
hadError = true;
rethrow( ME );
end 
end 


function setPeripheralConfigButtonVisibility( blkH )

codertarget.peripherals.utils.setBlockMaskButtonVisibility( blkH, 'PeripheralConfigBtn' );
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


function w = locGetImageWidth( blkP )
sz = locGetImageSize( blkP );
w = sz( 1 );
end 


function h = locGetImageHeight( blkP )
sz = locGetImageSize( blkP );
h = sz( 2 );
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


function bufSize = locGetNumElemsOut( blkP, outIdx )
sz = locGetImageSize( blkP );
bufSize = sz( 1 ) * sz( 2 );
if ~isequal( outIdx, 1 ) && ~isequal( blkP.PixelFormat, 'RGB' )
bufSize = sz( 1 ) * sz( 2 ) / 2;
end 
end 


function locSetSelectorReshape( blkPath, blkP, sz )
numElemsImage = sz( 1 ) * sz( 2 );
if isequal( blkP.PixelFormat, 'RGB' )
set_param( [ blkPath, '/Variant/SIM/Selector1' ], 'Indices', '1,1' );
set_param( [ blkPath, '/Variant/SIM/Selector2' ], 'Indices', [ '1,', num2str( 1 + numElemsImage ) ] );
set_param( [ blkPath, '/Variant/SIM/Selector3' ], 'Indices', [ '1,', num2str( 1 + 2 * numElemsImage ) ] );
set_param( [ blkPath, '/Variant/SIM/Selector1' ], 'OutputSizes', [ '1,', num2str( numElemsImage ) ] );
set_param( [ blkPath, '/Variant/SIM/Selector2' ], 'OutputSizes', [ '1,', num2str( numElemsImage ) ] );
set_param( [ blkPath, '/Variant/SIM/Selector3' ], 'OutputSizes', [ '1,', num2str( numElemsImage ) ] );
set_param( [ blkPath, '/Variant/SIM/Reshape1' ], 'OutputDimensions', [ '[', num2str( sz( 1 ) ), ',', num2str( sz( 2 ) ), ']' ] );
set_param( [ blkPath, '/Variant/SIM/Reshape2' ], 'OutputDimensions', [ '[', num2str( sz( 1 ) ), ',', num2str( sz( 2 ) ), ']' ] );
set_param( [ blkPath, '/Variant/SIM/Reshape3' ], 'OutputDimensions', [ '[', num2str( sz( 1 ) ), ',', num2str( sz( 2 ) ), ']' ] );
else 
set_param( [ blkPath, '/Variant/SIM/Selector1' ], 'Indices', '1,1' );
set_param( [ blkPath, '/Variant/SIM/Selector2' ], 'Indices', [ '1,', num2str( 1 + numElemsImage ) ] );
set_param( [ blkPath, '/Variant/SIM/Selector3' ], 'Indices', [ '1,', num2str( 1 + 3 * numElemsImage / 2 ) ] );
set_param( [ blkPath, '/Variant/SIM/Selector1' ], 'OutputSizes', [ '1,', num2str( numElemsImage ) ] );
set_param( [ blkPath, '/Variant/SIM/Selector2' ], 'OutputSizes', [ '1,', num2str( numElemsImage / 2 ) ] );
set_param( [ blkPath, '/Variant/SIM/Selector3' ], 'OutputSizes', [ '1,', num2str( numElemsImage / 2 ) ] );
set_param( [ blkPath, '/Variant/SIM/Reshape1' ], 'OutputDimensions', [ '[', num2str( sz( 1 ) ), ',', num2str( sz( 2 ) ), ']' ] );
set_param( [ blkPath, '/Variant/SIM/Reshape2' ], 'OutputDimensions', [ '[', num2str( sz( 1 ) / 2 ), ',', num2str( sz( 2 ) ), ']' ] );
set_param( [ blkPath, '/Variant/SIM/Reshape3' ], 'OutputDimensions', [ '[', num2str( sz( 1 ) / 2 ), ',', num2str( sz( 2 ) ), ']' ] );
end 
end 


function locSetMaskHelp( blkH )
helpcmd = 'eval(''soc.internal.helpview(''''soc_videocapture'''')'')';
set_param( blkH, 'MaskHelp', helpcmd );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpNxZ3Db.p.
% Please follow local copyright laws when handling this file.

