function simrfV2spnt( block, action )





top_sys = bdroot( block );
if strcmpi( get_param( top_sys, 'BlockDiagramType' ), 'library' ) &&  ...
strcmpi( top_sys, 'simrfV2junction1' )
return ;
end 





switch ( action )
case 'simrfInit'

if any( strcmpi( get_param( top_sys, 'SimulationStatus' ),  ...
{ 'running', 'paused' } ) )
return 
end 


MaskWSValues = simrfV2getblockmaskwsvalues( block );


MaskDisplay = 'simrfV2icon_switch_spnt';
set_param( block, 'MaskDisplay', MaskDisplay )


validateattributes( MaskWSValues.NumOutputs, { 'numeric' },  ...
{ 'nonempty', 'scalar', 'finite', 'nonnan', 'integer', '>', 1, '<', 9 },  ...
mfilename, 'number of SPnT Switch outputs' );


newSwitchName = [ 'switch_sp', int2str( MaskWSValues.NumOutputs ), 't' ];


RepBlk = simrfV2_find_repblk( block, '^switch_sp[2-8]t$' );
numOutputsRepBlk = str2double( regexp( RepBlk, '\d+', 'match', 'once' ) );


if numOutputsRepBlk ~= MaskWSValues.NumOutputs
hasReplacedSw = true;
SrcBlk = sprintf( 'simrfV2_lib/Elements/SWITCH_SP%dT_RF',  ...
MaskWSValues.NumOutputs );
SrcLib = 'simrfV2_lib';
simrfV2repblk( struct( 'RepBlk', RepBlk, 'SrcBlk', SrcBlk,  ...
'SrcLib', SrcLib, 'DstBlk', newSwitchName ), block );
hBlkPort = get_param( [ block, '/', newSwitchName ], 'PortHandles' );


if numOutputsRepBlk < MaskWSValues.NumOutputs

for port_idx = 1:MaskWSValues.NumOutputs
DstBlk = int2str( port_idx );
simrfV2repblk( struct(  ...
'RepBlk', DstBlk,  ...
'SrcBlk', 'nesl_utility_internal/Connection Port',  ...
'SrcLib', 'nesl_utility_internal',  ...
'DstBlk', DstBlk,  ...
'Param', { { 'Port', sprintf( '%d', port_idx + 1 ),  ...
'Orientation', 'left', 'Side', 'Right',  ...
'Position', get_conn_pos( port_idx, hBlkPort ) ...
, 'NamePlacement', 'Alternate' } } ), block );


simrfV2repblk( struct(  ...
'RepBlk', 'dummy',  ...
'DstBlk', sprintf( '%d', port_idx ), 'Param',  ...
{ { 'Side', 'Right' } } ), block );

end 
else 

for port_idx = numOutputsRepBlk: - 1:( MaskWSValues.NumOutputs + 1 )
simrfV2repblk( struct( 'RepBlk', sprintf( '%d', port_idx ),  ...
'DstBlk', 'dummy' ), block );
end 

for port_idx = 1:MaskWSValues.NumOutputs
set_param( [ block, '/', int2str( port_idx ) ],  ...
'Position', get_conn_pos( port_idx, hBlkPort ) )
end 
end 

for port_idx = 1:MaskWSValues.NumOutputs
simrfV2connports( struct(  ...
'SrcBlk', newSwitchName,  ...
'SrcBlkPortIdx', port_idx, 'SrcBlkPortStr', 'RConn',  ...
'DstBlk', int2str( port_idx ),  ...
'DstBlkPortIdx', 1, 'DstBlkPortStr', 'RConn' ), block );
end 


simrfV2connports( struct(  ...
'SrcBlk', newSwitchName,  ...
'SrcBlkPortIdx', 1, 'SrcBlkPortStr', 'LConn',  ...
'DstBlk', 'In',  ...
'DstBlkPortIdx', 1, 'DstBlkPortStr', 'RConn' ), block );

simrfV2connports( struct(  ...
'SrcBlk', newSwitchName,  ...
'SrcBlkPortIdx', 3, 'SrcBlkPortStr', 'LConn',  ...
'DstBlk', 'SLPS',  ...
'DstBlkPortIdx', 1, 'DstBlkPortStr', 'RConn' ), block );
else 
hasReplacedSw = false;
end 


switch lower( MaskWSValues.InternalGrounding )
case 'on'

replace_gnd_complete = simrfV2repblk( struct( 'RepBlk', 'Sub',  ...
'SrcBlk', 'simrfV2elements/Gnd',  ...
'SrcLib', 'simrfV2elements', 'DstBlk', 'Gnd' ), block );

if replace_gnd_complete || hasReplacedSw
simrfV2connports( struct( 'SrcBlk', newSwitchName,  ...
'SrcBlkPortStr', 'LConn', 'SrcBlkPortIdx', 2,  ...
'DstBlk', 'Gnd', 'DstBlkPortStr', 'LConn',  ...
'DstBlkPortIdx', 1 ), block );
end 

case 'off'

subPortNum = int2str( MaskWSValues.NumOutputs + 2 );
replace_gnd_complete = simrfV2repblk( struct(  ...
'RepBlk', 'Gnd',  ...
'SrcBlk', 'nesl_utility_internal/Connection Port',  ...
'SrcLib', 'nesl_utility_internal',  ...
'DstBlk', 'Sub',  ...
'Param', { { 'Side', 'Left', 'Orientation', 'Up',  ...
'Port', subPortNum } } ),  ...
block );
if replace_gnd_complete || hasReplacedSw
simrfV2connports( struct( 'SrcBlk', newSwitchName,  ...
'SrcBlkPortStr', 'LConn', 'SrcBlkPortIdx', 2,  ...
'DstBlk', 'Sub', 'DstBlkPortStr', 'RConn',  ...
'DstBlkPortIdx', 1 ), block );
end 
end 


validateattributes( MaskWSValues.InsertionLoss, { 'numeric' },  ...
{ 'nonempty', 'scalar', 'positive', 'finite', 'real' },  ...
mfilename, 'Insertion loss' );
validateattributes( MaskWSValues.Isolation, { 'numeric' },  ...
{ 'nonempty', 'scalar', 'positive', 'finite', 'real' },  ...
mfilename, 'Isolation' );
validateattributes( MaskWSValues.Isolation, { 'numeric' },  ...
{ 'scalar', '>', MaskWSValues.InsertionLoss }, mfilename,  ...
'Isolation to be larger than Insertion Loss and' );
validateattributes( MaskWSValues.Z0, { 'numeric' },  ...
{ 'nonempty', 'scalar', 'positive', 'finite', 'real' },  ...
mfilename, 'Port termination values' );
set_param( [ block, '/', newSwitchName ],  ...
'InsertionLoss', num2str( MaskWSValues.InsertionLoss, 16 ),  ...
'Isolation', num2str( MaskWSValues.Isolation, 16 ),  ...
'Z0', num2str( MaskWSValues.Z0, 16 ),  ...
'LoadType', int2str( MaskWSValues.LoadType ) )


maskRight = sprintf( 'port_label(''RConn'', %d, ''%d'')\n',  ...
[ 1:MaskWSValues.NumOutputs;1:MaskWSValues.NumOutputs ] );
MaskDisplay = sprintf( '%s\nport_label(''LConn'', 1, ''In'')\n%s',  ...
MaskDisplay, maskRight );
if strcmpi( MaskWSValues.InternalGrounding, 'off' )
MaskDisplay = sprintf( '%sport_label(''LConn'', 2, ''Ref'')\n',  ...
MaskDisplay );
end 
MaskDisplay = sprintf( '%sport_label(''input'', 1, ''Ctl'')\n',  ...
MaskDisplay );
if MaskWSValues.LoadType == 1
textStr = 'Absorptive';
else 
textStr = 'Reflective';
end 
MaskDisplay = sprintf( '%stext(.2,.1,''%s'');', MaskDisplay, textStr );
set_param( block, 'MaskDisplay', MaskDisplay )
end 

end 

function pos = get_conn_pos( idx, hPorts )



if length( hPorts.RConn ) <= 4
delX = 0;
else 
delX = 30 * ( mod( idx - 1, 4 ) + 1 );
end 

posPort = get_param( hPorts.RConn( idx ), 'Position' );
pos = [ posPort( 1 ) + 10 + delX, posPort( 2 ) - 8 ...
, posPort( 1 ) + 40 + delX, posPort( 2 ) + 8 ];
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpaECa5A.p.
% Please follow local copyright laws when handling this file.

