function varargout = UDPWriteHostCb( func, blkH, varargin )
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

l_SetMaskHelp( blkH );

try 
l_SetMaskDisplay( blkH, blkP );
soc.internal.setBlockIcon( blkH, 'socicons.UDPHostWrite' );
catch ME
hadError = true;
rethrow( ME );
end 
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
remoteName = [ 'sprintf(''Addr: %s'',''', blkP.remoteURL, ''')' ];
portName = [ 'sprintf(''Port: %s'',''', num2str( blkP.remotePort ), ''')' ];
md = [ 'color(''black'');',  ...
newline,  ...
[ 'text(0.5, 0.25, ', '[', remoteName, '], ''texmode'', ''off'', ''horizontalAlignment'', ''center'', ''verticalAlignment'', ''middle'');',  ...
newline ],  ...
'text(0.5, 0.12,', '[', portName, '], ''texmode'', ''off'', ''horizontalAlignment'', ''center'', ''verticalAlignment'', ''middle'');',  ...
newline,  ...
md ];

set_param( currentBlock, 'MaskDisplay', md );
end 

function l_SetMaskHelp( blkH )
helpcmd = 'eval(''soc.internal.helpview(''''soc_udpwrite_host'''')'')';
set_param( blkH, 'MaskHelp', helpcmd );

blkName = [ get_param( blkH, 'Parent' ), '/', get_param( blkH, 'Name' ), '/', get_param( blkH, 'hoistedMaskSrc' ) ];
set_param( blkH, 'MaskDescription', get_param( blkName, 'MaskDescription' ) );
set_param( blkH, 'MaskType', get_param( blkName, 'MaskType' ) );
end 

function LocalPortSource( blkH )
blkP = soc.blkcb.cbutils( 'GetDialogParams', blkH, 'slResolve' );
maskvis = get_param( blkH, 'MaskVisibilities' );
[ ~, visibilityIndex ] = ismember( 'localPort', fieldnames( blkP ) );
if isequal( blkP.localPortSource, 'Specify via dialog' )
maskvis{ visibilityIndex } = 'on';
else 
maskvis{ visibilityIndex } = 'off';
end 
set_param( blkH, 'MaskVisibilities', maskvis );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpRsfTdH.p.
% Please follow local copyright laws when handling this file.

