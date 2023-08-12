function simrfV2varphase( block, action )





top_sys = bdroot( block );
if strcmpi( top_sys, 'simrfV2elements' )
return ;
end 





switch ( action )
case 'simrfInit'

MaskVals = get_param( block, 'MaskValues' );
idxMaskNames = simrfV2getblockmaskparamsindex( block );
MaskWSValues = simrfV2getblockmaskwsvalues( block );

MaskDisplay = sprintf( [ 'simrfV2icon_var_phase\n',  ...
'port_label(''input'', 1,''Phase'')' ] );
set_param( block, 'MaskDisplay', MaskDisplay )


switch lower( MaskVals{ idxMaskNames.InternalGrounding } )
case 'on'

simrfV2repblk( struct( 'RepBlk', 'In-', 'SrcBlk',  ...
'simrfV2elements/Gnd', 'SrcLib', 'simrfV2elements',  ...
'DstBlk', 'Gnd1' ), block );
replace_gnd_complete = simrfV2repblk( struct( 'RepBlk',  ...
'Out-', 'SrcBlk', 'simrfV2elements/Gnd',  ...
'SrcLib', 'simrfV2elements', 'DstBlk', 'Gnd2' ), block );

if replace_gnd_complete
simrfV2connports( struct( 'SrcBlk', 'short1',  ...
'SrcBlkPortStr', 'RConn', 'SrcBlkPortIdx', 1,  ...
'DstBlk', 'Gnd1', 'DstBlkPortStr', 'LConn',  ...
'DstBlkPortIdx', 1 ), block );
simrfV2connports( struct( 'SrcBlk', 'short2',  ...
'SrcBlkPortStr', 'RConn', 'SrcBlkPortIdx', 1,  ...
'DstBlk', 'Gnd2', 'DstBlkPortStr', 'LConn',  ...
'DstBlkPortIdx', 1 ), block );
end 
MaskDisplay = simrfV2_add_portlabel( MaskDisplay, 1,  ...
{ 'In' }, 1, { 'Out' }, true );

case 'off'

simrfV2repblk( struct( 'RepBlk', 'Gnd1', 'SrcBlk',  ...
'nesl_utility_internal/Connection Port', 'SrcLib',  ...
'nesl_utility_internal', 'DstBlk', 'In-', 'Param',  ...
{ { 'Side', 'Left', 'Orientation', 'Up', 'Port', '3' } } ),  ...
block );
replace_gnd_complete = simrfV2repblk( struct(  ...
'RepBlk', 'Gnd2',  ...
'SrcBlk', 'nesl_utility_internal/Connection Port',  ...
'SrcLib', 'nesl_utility_internal',  ...
'DstBlk', 'Out-', 'Param',  ...
{ { 'Side', 'Right', 'Orientation', 'Up', 'Port', '4' } } ),  ...
block );
if replace_gnd_complete
simrfV2connports( struct( 'SrcBlk', 'short1',  ...
'SrcBlkPortStr', 'RConn', 'SrcBlkPortIdx', 1,  ...
'DstBlk', 'In-', 'DstBlkPortStr', 'RConn',  ...
'DstBlkPortIdx', 1 ), block );
simrfV2connports( struct( 'SrcBlk', 'short2',  ...
'SrcBlkPortStr', 'RConn', 'SrcBlkPortIdx', 1,  ...
'DstBlk', 'Out-', 'DstBlkPortStr', 'RConn',  ...
'DstBlkPortIdx', 1 ), block );
end 
MaskDisplay = simrfV2_add_portlabel( MaskDisplay, 2,  ...
{ 'In' }, 2, { 'Out' }, false );
end 
set_param( block, 'MaskDisplay', MaskDisplay );


if regexpi( get_param( top_sys, 'SimulationStatus' ),  ...
'^(updating|initializing)$' )
phaseUnit = get_param( block, 'PhaseShift_unit' );

if strcmpi( phaseUnit, 'rad' )
radDegGain = '1';
else 
radDegGain = 'pi/180';
end 
set_param( [ block, '/rad_deg' ], 'Gain', radDegGain )

Z0 = MaskWSValues.SparamZ0;
if isscalar( Z0 )
validateattributes( Z0, { 'numeric' },  ...
{ 'nonempty', 'scalar', 'real', 'positive', 'finite' },  ...
mfilename, 'Reference impedance' )
Z0 = [ 1, 1 ] * Z0;
else 
validateattributes( Z0, { 'numeric' },  ...
{ 'nonempty', 'numel', 2, 'real', 'positive', 'finite' },  ...
mfilename, 'Reference impedance' )
end 
str1 = simrfV2vector2str( [ Z0( 1 ), 50 ] );
set_param( [ block, '/BlockFc1' ], 'ZO', str1 );
set_param( [ block, '/BlockDC1' ], 'ZO', str1 );
str2 = simrfV2vector2str( [ 50, Z0( 2 ) ] );
set_param( [ block, '/BlockFc2' ], 'ZO', str2 );
set_param( [ block, '/BlockDC2' ], 'ZO', str2 );
end 
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp8pkSvM.p.
% Please follow local copyright laws when handling this file.

