function varargout = RegisterWriteCb( func, blkH, varargin )


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

function MaskInitFcn( blkH )%#ok<*DEFNU>
persistent hadError
if isempty( hadError )
hadError = false;
end 

blkPath = soc.blkcb.cbutils( 'GetBlkPath', blkH );
blkP = soc.blkcb.cbutils( 'GetDialogParams', blkH, 'slResolve' );
l_SetMaskHelp( blkH );
try 
hAXI4RegisterWrite = [ blkPath, '/Variant/CODEGEN/AXI4-Register Write' ];
set_param( hAXI4RegisterWrite, 'DeviceName', blkP.DeviceName );
set_param( hAXI4RegisterWrite, 'RegisterOffset', num2str( blkP.OffsetAddress ) );
hSinkVariant = [ blkPath, '/Variant/SIM/Sink Variant' ];
switch blkP.OutputSink
case 'To output port'
set_param( hSinkVariant, 'LabelModeActiveChoice', 'ToOutputPort' );
case 'Base workspace'
set_param( hSinkVariant, 'LabelModeActiveChoice', 'TunableParameter' );
set_param( [ hSinkVariant, '/Tunable Parameter/Tunable Parametere Updater' ],  ...
'TunableParamName', get_param( blkH, 'TunableParamName' ) );
case 'IP core register'
set_param( hSinkVariant, 'LabelModeActiveChoice', 'IPCoreRegister' );
otherwise 
error( '(internal) illegal input' );
end 
if ismember( get_param( bdroot( blkH ), 'SimulationStatus' ), { 'stopped', 'initializing' } )
updatePorts( blkPath, blkP );
end 
l_SetMaskDisplay( blkH, blkP );
soc.internal.setBlockIcon( blkH, 'socicons.RegisterWrite' );
catch ME
hadError = true;
rethrow( ME );
end 
end 

function InitFcn( blkH )
blkP = soc.blkcb.cbutils( 'GetDialogParams', blkH, 'slResolve' );
if isequal( blkP.OutputSink, 'Base workspace' )
tunableParamName = get_param( blkH, 'TunableParamName' );
if ~isvarname( tunableParamName )
error( message( 'soc:utils:InvalidTunableParameterName', tunableParamName ) );
end 
end 
end 

function l_SetMaskDisplay( blkH, blkP )
fulltext1 = sprintf( 'color(''black'')' );
switch ( blkP.OutputSink )
case 'To output port'
fulltext4 = '';
case 'Base workspace'
fulltext4 = sprintf( 'text(0.5, 0.85,''%s'',''horizontalAlignment'',''center'',''texmode'',''off'')', get_param( blkH, 'TunableParamName' ) );
case 'IP core register'
fulltext4 = sprintf( 'text(0.5, 0.85,''%s'',''horizontalAlignment'',''center'',''texmode'',''off'')', get_param( blkH, 'RegisterName' ) );
otherwise 
error( '(internal) illegal input' );
end 
fulltext2 = sprintf( 'text(0.5, 0.3,''%s'',''horizontalAlignment'',''center'',''texmode'',''off'')', blkP.DeviceName );
fulltext3 = sprintf( 'text(0.5, 0.15,''0x%s'',''horizontalAlignment'',''center'',''texmode'',''off'')', dec2hex( blkP.OffsetAddress ) );

md = sprintf( '%s;\n%s;\n%s;\n%s;\n%s;', fulltext1, fulltext4, fulltext2, fulltext3 );
set_param( blkH, 'MaskDisplay', md );
end 

function l_SetMaskHelp( blkH )
helpcmd = 'eval(''soc.internal.helpview(''''soc_registerwrite'''')'')';
set_param( blkH, 'MaskHelp', helpcmd );
end 

function [ vis, ens ] = OutputSinkCb( ~, val, vis, ens, idxMap )

switch val
case 'To output port'
vis{ idxMap( 'TunableParamName' ) } = 'off';
ens{ idxMap( 'TunableParamName' ) } = 'off';
vis{ idxMap( 'RegisterName' ) } = 'off';
ens{ idxMap( 'RegisterName' ) } = 'off';
case 'Base workspace'
vis{ idxMap( 'TunableParamName' ) } = 'on';
ens{ idxMap( 'TunableParamName' ) } = 'on';
vis{ idxMap( 'RegisterName' ) } = 'off';
ens{ idxMap( 'RegisterName' ) } = 'off';
case 'IP core register'
vis{ idxMap( 'TunableParamName' ) } = 'off';
ens{ idxMap( 'TunableParamName' ) } = 'off';
vis{ idxMap( 'RegisterName' ) } = 'on';
ens{ idxMap( 'RegisterName' ) } = 'on';
otherwise 
error( '(internal) illegal input type' );
end 
end 

function RegisterNameCb( blkH )
RegisterName = get_param( blkH, 'RegisterName' );
if ~isvarname( RegisterName )
error( 'soc:msgs:InvalidRegisterName',  ...
'Register name must be a valid MATLAB variable name.' );
end 
end 

function updatePorts( blkPath, blkP )
msgPortStr = 'msg';
msgBlock = find_system( blkPath, 'SearchDepth', '1', 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'Name', msgPortStr );
assert( ~isempty( msgBlock ), message( 'soc:msgs:InternalNoNewBlkFor', 'data outport' ) );
blockType = get_param( msgBlock{ 1 }, 'BlockType' );
switch blkP.OutputSink
case 'To output port'
if isequal( blockType, 'Outport' )
return ;
end 
msgBlock = replace_block( blkPath, 'SearchDepth', '1', 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'Name', msgPortStr, 'Outport', 'noprompt' );
assert( ~isempty( msgBlock ), message( 'soc:msgs:InternalNoNewBlkFor', 'data outport' ) );
set_param( msgBlock{ 1 }, 'Name', msgPortStr );
set_param( msgBlock{ 1 }, 'Port', '1' );
case { 'Base workspace', 'IP core register' }
if isequal( blockType, 'Terminator' )
return ;
end 
msgBlock = replace_block( blkPath, 'SearchDepth', '1', 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'Name', msgPortStr, 'Terminator', 'noprompt' );
assert( ~isempty( msgBlock ), message( 'soc:msgs:InternalNoNewBlkFor', 'data terminator' ) );
set_param( msgBlock{ 1 }, 'Name', msgPortStr );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpSvpIxT.p.
% Please follow local copyright laws when handling this file.

