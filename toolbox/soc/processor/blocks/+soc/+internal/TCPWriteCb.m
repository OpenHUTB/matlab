function varargout = TCPWriteCb( func, blkH, varargin )
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
hHWSWMessageSend = [ blkPath, '/Variant/SIM/HWSW Message Send' ];

l_SetMaskDisplay( blkH, blkP );
soc.internal.setBlockIcon( blkH, 'socicons.TCPWrite' );
catch ME
hadError = true;
rethrow( ME );
end 
end 

function l_SetMaskDisplay( blkH, blkP )%#ok<INUSD>
soc.blocks.hoistedMaskCallback( 'adaptMaskDisplay' );
md = get_param( blkH, 'MaskDisplay' );
md = [ md, newline, 'port_label(''input'', 1, ''data'')' ];
md = [ md, newline, 'port_label(''output'', 1, ''msg'')' ];
set_param( blkH, 'MaskDisplay', md );
end 

function l_SetMaskHelp( blkH )
helpcmd = 'eval(''soc.internal.helpview(''''soc_tcpwrite'''')'')';
set_param( blkH, 'MaskHelp', helpcmd );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpYFX3Mz.p.
% Please follow local copyright laws when handling this file.

