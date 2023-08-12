function simrfV2sparam( block, action )















switch ( action )
case 'simrfInit'

top_sys = bdroot( block );
if any( strcmpi( get_param( top_sys, 'SimulationStatus' ),  ...
{ 'running', 'paused' } ) )
return 
end 


MaskVals = get_param( block, 'MaskValues' );
idxMaskNames = simrfV2getblockmaskparamsindex( block );
MaskWSValues = simrfV2getblockmaskwsvalues( block );


switch MaskVals{ idxMaskNames.DataSource }
case { 'Data file', 'Network-parameters' }
cacheData = simrfV2_cachefit( block, MaskWSValues );
case 'Rational model'
cacheData = simrfV2_process_rational_model( block, MaskWSValues );
end 




if strcmpi( MaskVals{ idxMaskNames.SparamRepresentation },  ...
'Time domain (rationalfit)' ) ||  ...
strcmpi( MaskVals{ idxMaskNames.DataSource }, 'Rational model' )
isTimeDomainFit = true;
auxData = get_param( [ block, '/AuxData' ], 'UserData' );
if isfield( auxData.Spars, 'Parameters' ) &&  ...
length( auxData.Spars.Frequencies ) == 1 &&  ...
~isreal( auxData.Spars.Parameters )
isTimeDomainFit = false;
end 
else 
isTimeDomainFit = false;
end 




num_ports = cacheData.NumPorts;


if num_ports == 0
return 
end 



simrfV2spartypeoption( block, idxMaskNames, num_ports )








RepBlk = simrfV2_find_repblk( block, '^[sdf][1-9][0-9]?port$' );
numPortsOldBlk = str2double( regexp( RepBlk, '\d+', 'match', 'once' ) );
[ SrcBlk, SrcLib, sboxstr ] = get_sparam_block( cacheData, num_ports,  ...
isTimeDomainFit );
replace_snport_complete = simrfV2repblk( struct(  ...
'RepBlk', RepBlk, 'SrcBlk', SrcBlk, 'SrcLib', SrcLib,  ...
'DstBlk', sboxstr ), block );


InternalGrounding = strcmpi(  ...
MaskVals{ idxMaskNames.InternalGrounding }, 'on' );

for ii = 1:num_ports
if mod( ii, 2 ) ~= 0
Side = 'Left';
PortStr = 'LConn';
Orientation = 'right';
idxSide = ii;
else 
Side = 'Right';
PortStr = 'RConn';
Orientation = 'left';
idxSide = ii - 1;
end 
if InternalGrounding
Port = num2str( ii );
else 
Port = num2str( 2 * ii - 1 );
end 

replace_posterm_complete = simrfV2repblk( struct(  ...
'RepBlk', 'dummy',  ...
'SrcBlk', 'nesl_utility_internal/Connection Port',  ...
'SrcLib', 'nesl_utility_internal',  ...
'DstBlk', sprintf( '%d+', ii ), 'Param',  ...
{ { 'Port', Port, 'Orientation', Orientation,  ...
'Side', Side,  ...
'Position', get_conn_pos( idxSide, Side ) } } ), block );


simrfV2repblk( struct(  ...
'RepBlk', 'dummy',  ...
'DstBlk', sprintf( '%d+', ii ), 'Param',  ...
{ { 'Side', Side } } ), block );

if replace_posterm_complete || replace_snport_complete
simrfV2connports( struct(  ...
'SrcBlk', sboxstr, 'SrcBlkPortStr', PortStr,  ...
'SrcBlkPortIdx', idxSide,  ...
'DstBlk', sprintf( '%d+', ii ),  ...
'DstBlkPortStr', 'RConn', 'DstBlkPortIdx', 1 ), block );
end 
if InternalGrounding
replace_negterm_complete = simrfV2repblk( struct(  ...
'RepBlk', sprintf( '%d-', ii ),  ...
'SrcBlk', 'simrfV2elements/Gnd',  ...
'SrcLib', 'simrfV2elements',  ...
'DstBlk', sprintf( 'Gnd%d', ii ), 'Param',  ...
{ { 'Position', get_conn_pos( idxSide + 1, Side ) } } ), block );
if replace_negterm_complete || replace_snport_complete
simrfV2connports( struct(  ...
'SrcBlk', sboxstr, 'SrcBlkPortStr', PortStr,  ...
'SrcBlkPortIdx', idxSide + 1,  ...
'DstBlk', sprintf( 'Gnd%d', ii ),  ...
'DstBlkPortStr', 'LConn', 'DstBlkPortIdx', 1 ),  ...
block );
end 
else 
replace_gnd_complete = simrfV2repblk( struct(  ...
'RepBlk', sprintf( 'Gnd%d', ii ),  ...
'SrcBlk', 'nesl_utility_internal/Connection Port',  ...
'SrcLib', 'nesl_utility_internal',  ...
'DstBlk', sprintf( '%d-', ii ),  ...
'Param', { { 'Port', num2str( 2 * ii ),  ...
'Orientation', Orientation, 'Side', Side,  ...
'Position', get_conn_pos( idxSide + 1, Side ) } } ), block );


simrfV2repblk( struct(  ...
'RepBlk', 'dummy',  ...
'DstBlk', sprintf( '%d-', ii ),  ...
'Param', { { 'Side', Side } } ), block );


if replace_gnd_complete || replace_snport_complete
simrfV2connports( struct(  ...
'SrcBlk', sboxstr, 'SrcBlkPortStr', PortStr,  ...
'SrcBlkPortIdx', idxSide + 1,  ...
'DstBlk', sprintf( '%d-', ii ),  ...
'DstBlkPortStr', 'RConn', 'DstBlkPortIdx', 1 ),  ...
block );
end 
end 
end 
if replace_snport_complete
for ii = num_ports + 1:numPortsOldBlk
simrfV2repblk( struct(  ...
'RepBlk', sprintf( '%d+', ii ),  ...
'DstBlk', 'dummy' ), block );
simrfV2repblk( struct(  ...
'RepBlk', sprintf( 'Gnd%d', ii ),  ...
'DstBlk', 'dummy' ), block );
simrfV2repblk( struct(  ...
'RepBlk', sprintf( '%d-', ii ),  ...
'DstBlk', 'dummy' ), block );
end 
end 


halfPorts = ceil( num_ports / 2 );
oddStr = cell( 1, halfPorts );
evenStr = cell( 1, halfPorts );
for i = 1:halfPorts
oddStr( i ) = { int2str( 2 * i - 1 ) };
evenStr( i ) = { int2str( 2 * i ) };
end 
if InternalGrounding
MaskDisplay = simrfV2_add_portlabel( [  ],  ...
ceil( num_ports / 2 ), oddStr,  ...
floor( num_ports / 2 ), evenStr, true );
else 
MaskDisplay = simrfV2_add_portlabel( [  ],  ...
2 * ceil( num_ports / 2 ), oddStr,  ...
2 * floor( num_ports / 2 ), evenStr, false );
end 
set_param( block, 'MaskDisplay', MaskDisplay )

if ~strcmpi( get_param( top_sys, 'SimulationStatus' ), 'stopped' )
if isTimeDomainFit
simrfV2sparamblockinit( block, sboxstr )
else 
simrfV2sparam_freq_domain_blockinit( block,  ...
[ block, '/', sboxstr ],  ...
simrfV2getblockmaskwsvalues( block ) )
end 
else 
dialog = simrfV2_find_dialog( block );
if ~isempty( dialog )
dialog.refresh;
end 
end 

case 'simrfDelete'

case 'simrfCopy'
auxData = get_param( [ block, '/AuxData' ], 'UserData' );
if isfield( auxData, 'Plot' )
simrfV2Constants = simrfV2_constants(  );
auxData.Plot = simrfV2Constants.Plot;
set_param( [ block, '/AuxData' ], 'UserData', auxData );
end 

case 'simrfDefault'

end 
end 

function pos = get_conn_pos( idx, side )

if strcmpi( side, 'left' )
start_pos = [ 30, 61, 60, 79 ];
indent = 5 * ( idx - 1 );
else 
start_pos = [ 345, 61, 375, 79 ];
indent =  - 5 * ( idx - 1 );
end 
offset = 120;
pos = [ start_pos( 1 ) + indent, start_pos( 2 ) + ( idx - 1 ) * offset,  ...
start_pos( 3 ) + indent, start_pos( 4 ) + ( idx - 1 ) * offset ];

end 

function [ SrcBlk, SrcLib, DstBlk ] =  ...
get_sparam_block( Udata, num_ports, isTimeDomainFit )

SrcLib = 'simrfV2_lib';
if num_ports <= 8
if ~isTimeDomainFit
SrcBlk = sprintf( 'simrfV2_lib/Sparameters/F%dPORT_RF', num_ports );
DstBlk = sprintf( 'f%dport', num_ports );
elseif ~all( cellfun( 'isempty', Udata.RationalModel.C ) )
SrcBlk = sprintf( 'simrfV2_lib/Sparameters/S%dPORT_RF', num_ports );
DstBlk = sprintf( 's%dport', num_ports );
else 
SrcBlk = sprintf( 'simrfV2_lib/Sparameters/D%dPORT_RF', num_ports );
DstBlk = sprintf( 'd%dport', num_ports );
end 
else 
if ~isTimeDomainFit
SrcBlk = sprintf( 'simrfV2_lib/SparsVM/F%dPORT_RF', num_ports );
DstBlk = sprintf( 'f%dport', num_ports );
elseif ~all( cellfun( 'isempty', Udata.RationalModel.C ) )
SrcBlk = sprintf( 'simrfV2_lib/SparsVM/S%dPORT_RF', num_ports );
DstBlk = sprintf( 's%dport', num_ports );
else 
SrcBlk = sprintf( 'simrfV2_lib/SparsVM/D%dPORT_RF', num_ports );
DstBlk = sprintf( 'd%dport', num_ports );
end 
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpU6ageQ.p.
% Please follow local copyright laws when handling this file.

