function varargout = VideoDisplayCb( func, blkH, varargin )




if nargout == 0
feval( func, blkH, varargin{ : } );
else 
[ varargout{ 1:nargout } ] = feval( func, blkH, varargin{ : } );
end 
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
try 
codeGenBlk = [ blkPath, '/Variant/CODEGEN/Video Display' ];





set_param( blkPath, 'BlockSID', codertarget.peripherals.utils.getBlockSID( blkH, false ) );


blockSID = codertarget.peripherals.utils.getBlockSID( blkH, true );
set_param( codeGenBlk, 'BlockID', blockSID );
set_param( codeGenBlk, 'PixelFormat', blkP.PixelFormat );
soc.internal.setBlockIcon( blkH, 'socicons.VideoDisplay' );
out1 = sprintf( 'port_label(''output'',1,''msg'')' );
lblIdx = isequal( blkP.PixelFormat, 'RGB' ) + 1;
allLbls = { 'Y', 'Cb', 'Cr';'R', 'G', 'B' };
portLbl = allLbls( lblIdx, : );
inp1 = sprintf( '%s, %d, ''%s'')', 'port_label(''input''', 1, portLbl{ 1 } );
inp2 = sprintf( '%s, %d, ''%s'')', 'port_label(''input''', 2, portLbl{ 2 } );
inp3 = sprintf( '%s, %d, ''%s'')', 'port_label(''input''', 3, portLbl{ 3 } );
fullLbl = sprintf( '%s;\n %s; \n %s; \n %s;', out1, inp1, inp2, inp3 );
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


function locSetMaskHelp( blkH )
helpcmd = 'eval(''soc.internal.helpview(''''soc_videodisplay'''')'')';
set_param( blkH, 'MaskHelp', helpcmd );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpnvII9W.p.
% Please follow local copyright laws when handling this file.

