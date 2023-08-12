function simrfV2vga( block, action )





top_sys = bdroot( block );
if strcmpi( top_sys, 'simrfV2elements' )
return ;
end 





switch ( action )
case 'simrfInit'

if any( strcmpi( get_param( top_sys, 'SimulationStatus' ),  ...
{ 'running', 'paused' } ) )
return 
end 


MaskVals = get_param( block, 'MaskValues' );
idxMaskNames = simrfV2getblockmaskparamsindex( block );
MaskWSValues = simrfV2getblockmaskwsvalues( block );

MaskDisplay = sprintf( [ 'simrfV2icon_vga\n',  ...
'port_label(''input'',1,''Gain'')\n',  ...
'port_label(''input'',2,''IP2'')\n',  ...
'port_label(''input'',3,''IP3'')' ] );
MaskDisplay_2term = simrfV2_add_portlabel( MaskDisplay, 1,  ...
{ 'In' }, 1, { 'Out' }, true );
MaskDisplay_4term = simrfV2_add_portlabel( MaskDisplay, 2,  ...
{ 'In' }, 2, { 'Out' }, false );
currentMaskDisplay = get_param( block, 'MaskDisplay' );

if isequal( currentMaskDisplay, MaskDisplay_4term ) ...
 && strcmpi( MaskVals{ idxMaskNames.InternalGrounding }, 'on' )
set_param( block, 'MaskDisplay', MaskDisplay_2term )
end 


switch lower( MaskVals{ idxMaskNames.InternalGrounding } )
case 'on'

replace_gnd_complete = simrfV2repblk( struct( 'RepBlk',  ...
'In-', 'SrcBlk', 'simrfV2elements/Gnd', 'SrcLib',  ...
'simrfV2elements', 'DstBlk', 'Gnd1' ), block );

if replace_gnd_complete
phtemp = get_param( [ block, '/', 'Zin' ], 'PortHandles' );
simrfV2deletelines( get( phtemp.RConn, 'Line' ) );
simrfV2connports( struct( 'SrcBlk', 'Zin',  ...
'SrcBlkPortStr', 'RConn', 'SrcBlkPortIdx', 1,  ...
'DstBlk', 'Gnd1',  ...
'DstBlkPortStr', 'LConn', 'DstBlkPortIdx', 1 ),  ...
block );
end 
reconnect_negterm = simrfV2repblk( struct( 'RepBlk',  ...
'Out-', 'SrcBlk', 'simrfV2elements/Gnd', 'SrcLib',  ...
'simrfV2elements', 'DstBlk', 'Gnd2' ), block );
negterm_out = 'Gnd2';
negterm_portstr = 'LConn';
MaskDisplay = MaskDisplay_2term;

case 'off'

replace_gnd_complete = simrfV2repblk( struct(  ...
'RepBlk', 'Gnd1',  ...
'SrcBlk', 'nesl_utility_internal/Connection Port',  ...
'SrcLib', 'nesl_utility_internal',  ...
'DstBlk', 'In-', 'Param',  ...
{ { 'Side', 'Left', 'Orientation', 'Up', 'Port',  ...
'3' } } ), block );
if replace_gnd_complete
phtemp = get_param( [ block, '/', 'Zin' ], 'PortHandles' );
simrfV2deletelines( get( phtemp.RConn, 'Line' ) );
simrfV2connports( struct( 'SrcBlk', 'Zin',  ...
'SrcBlkPortStr', 'RConn', 'SrcBlkPortIdx', 1,  ...
'DstBlk', 'In-',  ...
'DstBlkPortStr', 'RConn', 'DstBlkPortIdx', 1 ),  ...
block );
end 
reconnect_negterm = simrfV2repblk( struct(  ...
'RepBlk', 'Gnd2',  ...
'SrcBlk', 'nesl_utility_internal/Connection Port',  ...
'SrcLib', 'nesl_utility_internal',  ...
'DstBlk', 'Out-', 'Param',  ...
{ { 'Side', 'Right', 'Orientation', 'Up', 'Port',  ...
'4' } } ), block );
negterm_out = 'Out-';
negterm_portstr = 'RConn';
MaskDisplay = MaskDisplay_4term;
end 




switch lower( MaskVals{ idxMaskNames.IO } )
case 'input'
set_param( [ block ...
, '/ProcessSimulinkInputs/IPreferredType' ], 'Value', '1' );
case 'output'
set_param( [ block ...
, '/ProcessSimulinkInputs/IPreferredType' ], 'Value', '2' );
end 

simrfV2_set_param( block, 'MaskDisplay', MaskDisplay )

if replace_gnd_complete
simrfV2connports( struct( 'SrcBlk', 'VGA_CORE_RF',  ...
'SrcBlkPortStr', 'LConn', 'SrcBlkPortIdx', 2,  ...
'DstBlk', 'Zin', 'DstBlkPortStr', 'RConn',  ...
'DstBlkPortIdx', 1 ), block );
end 
if reconnect_negterm
simrfV2connports( struct( 'DstBlk', 'VGA_CORE_RF',  ...
'DstBlkPortStr', 'RConn', 'DstBlkPortIdx', 2,  ...
'SrcBlk', negterm_out, 'SrcBlkPortStr',  ...
negterm_portstr, 'SrcBlkPortIdx', 1 ), block );
end 


if regexpi( get_param( top_sys, 'SimulationStatus' ),  ...
'^(updating|initializing)$' )
simrfV2checkimpedance( MaskWSValues.Zin, 1,  ...
'Input impedance of the VGA', 0, 1 );
simrfV2checkimpedance( MaskWSValues.Zout, 1,  ...
'Output impedance of the VGA', 1, 0 );
end 

case 'simrfDelete'

case 'simrfCopy'

case 'simrfDefault'

end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmppGp8Uj.p.
% Please follow local copyright laws when handling this file.

