function varargout = UDPReadHostCb( func, blkH, varargin )
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

blkP = soc.blkcb.cbutils( 'GetDialogParams', blkH, 'slResolve' );

coder.internal.errorIf( blkP.dims > floor( 65507 / ioplayback.base.ByteOrder.getNumberOfBytes( blkP.signalDatatype ) ),  ...
'ioplayback:general:UDPIncorrectNumel', blkP.dims, blkP.signalDatatype );
l_SetMaskHelp( blkH );

try 
l_SetMaskDisplay( blkH, blkP );
soc.internal.setBlockIcon( blkH, 'socicons.UDPHostRead' );
catch ME
hadError = true;
rethrow( ME );
end 
end 

function dimsFcn( blkH )

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

function l_SetMaskDisplay( blkH, blkP )

currentBlock = blkH;
soc.blocks.hoistedMaskCallback( 'adaptMaskDisplay' );
md = get_param( currentBlock, 'MaskDisplay' );

portName = [ 'sprintf(''Port: %s'',''', num2str( blkP.localPort ), ''')' ];
md = [ 'color(''black'');',  ...
newline,  ...
'text(0.5, 0.15,', '[', portName, '], ''texmode'', ''off'', ''horizontalAlignment'', ''center'', ''verticalAlignment'', ''middle'');' ...
, newline,  ...
md ];
set_param( currentBlock, 'MaskDisplay', md );
end 

function l_SetMaskHelp( blkH )
helpcmd = 'eval(''soc.internal.helpview(''''soc_udpread_host'''')'')';
set_param( blkH, 'MaskHelp', helpcmd );

blkName = [ get_param( blkH, 'Parent' ), '/', get_param( blkH, 'Name' ), '/', get_param( blkH, 'hoistedMaskSrc' ) ];
set_param( blkH, 'MaskDescription', get_param( blkName, 'MaskDescription' ) );
set_param( blkH, 'MaskType', get_param( blkName, 'MaskType' ) );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpdwebSL.p.
% Please follow local copyright laws when handling this file.

