function simrfV2xline( block, action )





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



lumpedElement = false;
try 
switch MaskVals{ idxMaskNames.Model_type }
case { 'Coaxial' }
maskName = 'Coaxial';
outerradius = convert2meter( MaskWSValues.OuterRadius,  ...
MaskVals{ idxMaskNames.OuterRadius_unit } );
innerradius = convert2meter( MaskWSValues.InnerRadius,  ...
MaskVals{ idxMaskNames.InnerRadius_unit } );
linelength = convert2meter( MaskWSValues.LineLength,  ...
MaskVals{ idxMaskNames.LineLength_unit } );
conductivity = simrfV2convert2baseunit(  ...
MaskWSValues.SigmaCond,  ...
MaskVals{ idxMaskNames.SigmaCond_unit } );
mur = MaskWSValues.MuR;
epsr = MaskWSValues.EpsilonR;
tand = MaskWSValues.LossTangent;


checkparam( outerradius, 'Outer Radius' );
checkparam( innerradius, 'Inner Radius' );
checkparam( mur, 'Relative permeability' );
checkparam( epsr, 'Relative permittivity' );
checkparam( tand, 'Loss tangent of dielectric', 1 );
checkparam( linelength, 'Line length' );
checkconductivity( conductivity );

ckt = rfckt.coaxial;
set( ckt, 'Block', block, 'InnerRadius', innerradius,  ...
'OuterRadius', outerradius, 'MuR', mur,  ...
'EpsilonR', epsr, 'SigmaCond', conductivity,  ...
'LossTangent', tand, 'LineLength', linelength );

case { 'Coplanar waveguide' }
maskName = 'CPW';
condwidth = convert2meter(  ...
MaskWSValues.ConductorWidth,  ...
MaskVals{ idxMaskNames.ConductorWidth_unit } );
slotwidth = convert2meter( MaskWSValues.SlotWidth,  ...
MaskVals{ idxMaskNames.SlotWidth_unit } );
height = convert2meter( MaskWSValues.Height,  ...
MaskVals{ idxMaskNames.Height_unit } );
thickness = convert2meter( MaskWSValues.Thickness,  ...
MaskVals{ idxMaskNames.Thickness_unit } );
linelength = convert2meter( MaskWSValues.LineLength,  ...
MaskVals{ idxMaskNames.LineLength_unit } );
conductivity = simrfV2convert2baseunit(  ...
MaskWSValues.SigmaCond,  ...
MaskVals{ idxMaskNames.SigmaCond_unit } );
epsr = MaskWSValues.EpsilonR;
tand = MaskWSValues.LossTangent;
condback = strcmp( MaskVals{ idxMaskNames.ConductorBacked }, 'on' );


checkparam( condwidth, 'Conductor width' );
checkparam( slotwidth, 'Slot Width' );
checkparam( height, 'Substrate Height' );
checkparam( thickness, 'Strip thickness' );
checkparam( epsr, 'Relative permittivity' );
checkparam( tand, 'Loss tangent of dielectric', 1 );
checkparam( linelength, 'Line length' );
checkconductivity( conductivity );

ckt = txlineCPW(  ...
'ConductorBacked', condback,  ...
'ConductorWidth', condwidth,  ...
'SlotWidth', slotwidth, 'Height', height,  ...
'Thickness', thickness, 'EpsilonR', epsr,  ...
'SigmaCond', conductivity, 'LossTangent', tand,  ...
'LineLength', linelength );

case { 'Microstrip' }
maskName = 'Microstrip';
stripwidth = convert2meter( MaskWSValues.SWidth,  ...
MaskVals{ idxMaskNames.SWidth_unit } );
stripthickness = convert2meter( MaskWSValues.Thickness,  ...
MaskVals{ idxMaskNames.Thickness_unit } );
conductivity = simrfV2convert2baseunit(  ...
MaskWSValues.SigmaCond,  ...
MaskVals{ idxMaskNames.SigmaCond_unit } );
epsr = MaskWSValues.EpsilonR;
tand = MaskWSValues.LossTangent;
linelength = convert2meter( MaskWSValues.LineLength,  ...
MaskVals{ idxMaskNames.LineLength_unit } );


checkparam( stripwidth, 'Strip width' );
checkparam( stripthickness, 'Strip thickness', true );


switch MaskVals{ idxMaskNames.StructureMicrostrip }
case 'Inverted'
stripheight = convert2meter( MaskWSValues.StripHeight,  ...
MaskVals{ idxMaskNames.StripHeight_unit } );
dielectricthickness = convert2meter(  ...
MaskWSValues.Height_inv,  ...
MaskVals{ idxMaskNames.Height_inv_unit } );
case 'Suspended'
stripheight = convert2meter( MaskWSValues.StripHeight,  ...
MaskVals{ idxMaskNames.StripHeight_unit } );
dielectricthickness = convert2meter(  ...
MaskWSValues.Height_spd,  ...
MaskVals{ idxMaskNames.Height_spd_unit } );
case 'Embedded'
stripheight = convert2meter( MaskWSValues.StripHeight,  ...
MaskVals{ idxMaskNames.StripHeight_unit } );
dielectricthickness = convert2meter(  ...
MaskWSValues.Height_emb,  ...
MaskVals{ idxMaskNames.Height_emb_unit } );
otherwise 
dielectricthickness = convert2meter(  ...
MaskWSValues.Height,  ...
MaskVals{ idxMaskNames.Height_unit } );
stripheight = dielectricthickness;
end 
checkconductivity( conductivity );
checkparam( stripheight, 'Strip height' )
checkparam( dielectricthickness, 'Substrate Height' );
checkparam( epsr, 'Relative permittivity' );
checkparam( tand, 'Loss tangent of dielectric', 1 );
checkparam( linelength, 'Line length' );

ckt = txlineMicrostrip(  ...
'Type', MaskVals{ idxMaskNames.StructureMicrostrip },  ...
'Width', stripwidth,  ...
'Thickness', stripthickness,  ...
'Height', stripheight,  ...
'SigmaCond', conductivity,  ...
'DielectricThickness', dielectricthickness,  ...
'EpsilonR', epsr, 'LossTangent', tand,  ...
'LineLength', linelength );

case { 'Stripline' }
maskName = 'Stripline';
stripwidth = convert2meter( MaskWSValues.SWidth,  ...
MaskVals{ idxMaskNames.SWidth_unit } );
stripthickness = convert2meter( MaskWSValues.Thickness,  ...
MaskVals{ idxMaskNames.Thickness_unit } );
conductivity = simrfV2convert2baseunit(  ...
MaskWSValues.SigmaCond,  ...
MaskVals{ idxMaskNames.SigmaCond_unit } );
dielectricthickness = convert2meter( MaskWSValues.Height,  ...
MaskVals{ idxMaskNames.Height_unit } );
epsr = MaskWSValues.EpsilonR;
tand = MaskWSValues.LossTangent;
linelength = convert2meter( MaskWSValues.LineLength,  ...
MaskVals{ idxMaskNames.LineLength_unit } );


checkparam( stripwidth, 'Strip width' );
checkparam( stripthickness, 'Strip thickness' );
checkconductivity( conductivity );
checkparam( dielectricthickness, 'Substrate Height' );
checkparam( epsr, 'Relative permittivity' );
checkparam( tand, 'Loss tangent of dielectric', 1 );
checkparam( linelength, 'Line length' );

ckt = txlineStripline(  ...
'Width', stripwidth,  ...
'Thickness', stripthickness,  ...
'SigmaCond', conductivity,  ...
'DielectricThickness', dielectricthickness,  ...
'EpsilonR', epsr, 'LossTangent', tand,  ...
'LineLength', linelength );

case { 'Two-wire' }
maskName = 'Two-wire';
radius = convert2meter( MaskWSValues.Radius,  ...
MaskVals{ idxMaskNames.Radius_unit } );
separation = convert2meter( MaskWSValues.Separation,  ...
MaskVals{ idxMaskNames.Separation_unit } );
linelength = convert2meter( MaskWSValues.LineLength,  ...
MaskVals{ idxMaskNames.LineLength_unit } );
conductivity = simrfV2convert2baseunit(  ...
MaskWSValues.SigmaCond,  ...
MaskVals{ idxMaskNames.SigmaCond_unit } );
mur = MaskWSValues.MuR;
epsr = MaskWSValues.EpsilonR;
tand = MaskWSValues.LossTangent;


checkparam( radius, 'Wire radius' );
checkparam( separation, 'Wire separation' );
checkparam( mur, 'Relative permeability' );
checkparam( epsr, 'Relative permittivity' );
checkparam( tand, 'Loss tangent of dielectric', 1 );
checkparam( linelength, 'Line length' );
checkconductivity( conductivity );

ckt = rfckt.twowire;
set( ckt, 'Block', block, 'Radius', radius,  ...
'Separation', separation, 'MuR', mur,  ...
'EpsilonR', epsr, 'SigmaCond', conductivity,  ...
'LossTangent', tand, 'LineLength', linelength );

case { 'Parallel-plate' }
maskName = 'Parallel-plate';
pwidth = convert2meter( MaskWSValues.PWidth,  ...
MaskVals{ idxMaskNames.PWidth_unit } );
pseparation = convert2meter( MaskWSValues.PSeparation,  ...
MaskVals{ idxMaskNames.PSeparation_unit } );
linelength = convert2meter( MaskWSValues.LineLength,  ...
MaskVals{ idxMaskNames.LineLength_unit } );
conductivity = simrfV2convert2baseunit(  ...
MaskWSValues.SigmaCond,  ...
MaskVals{ idxMaskNames.SigmaCond_unit } );
mur = MaskWSValues.MuR;
epsr = MaskWSValues.EpsilonR;
tand = MaskWSValues.LossTangent;


checkparam( pwidth, 'Plate width' );
checkparam( pseparation, 'Plate separation' );
checkparam( mur, 'Relative permeability' );
checkparam( epsr, 'Relative permittivity' );
checkparam( tand, 'Loss tangent of dielectric', 1 );
checkparam( linelength, 'Line length' );
checkconductivity( conductivity );

ckt = rfckt.parallelplate;
set( ckt, 'Block', block, 'Width', pwidth,  ...
'Separation', pseparation, 'MuR', mur,  ...
'EpsilonR', epsr, 'SigmaCond', conductivity,  ...
'LossTangent', tand, 'LineLength', linelength );

case { 'Equation-based' }
maskName = 'Equation\nbased';
Freq = simrfV2convert2baseunit( MaskWSValues.Freq,  ...
MaskVals{ idxMaskNames.Freq_unit } );
z0 = simrfV2convert2baseunit( MaskWSValues.CharImped,  ...
MaskVals{ idxMaskNames.CharImped_unit } );
linelength = convert2meter( MaskWSValues.LineLength,  ...
MaskVals{ idxMaskNames.LineLength_unit } );
pv = MaskWSValues.PV;
loss = MaskWSValues.Loss;
freqlength = length( Freq );


simrfV2checkfreqs( Freq, 'gtez' );
simrfV2checkparam( pv, 'Phase velocity', 'gtez', freqlength );
simrfV2checkparam( real( z0 ), 'Characteristic impedance',  ...
'gtez', freqlength );
simrfV2checkparam( loss, 'Loss', 'gtez', freqlength );
checkparam( linelength, 'Line length' );

ckt = rfckt.txline;
set( ckt, 'Block', block, 'Z0', z0, 'PV', pv,  ...
'Loss', loss, 'LineLength', linelength,  ...
'Freq', Freq,  ...
'IntpType', MaskVals{ idxMaskNames.Interp_type } );

case { 'RLCG' }
maskName = 'RLCG';
Freq = simrfV2convert2baseunit( MaskWSValues.Freq,  ...
MaskVals{ idxMaskNames.Freq_unit } );
Res = simrfV2convert2baseunit( MaskWSValues.Resistance,  ...
MaskVals{ idxMaskNames.Resistance_unit } );
Ind = simrfV2convert2baseunit( MaskWSValues.Inductance,  ...
MaskVals{ idxMaskNames.Inductance_unit } );
Cap = simrfV2convert2baseunit( MaskWSValues.Capacitance,  ...
MaskVals{ idxMaskNames.Capacitance_unit } );
Cond = simrfV2convert2baseunit(  ...
MaskWSValues.Conductance,  ...
MaskVals{ idxMaskNames.Conductance_unit } );

linelength = convert2meter( MaskWSValues.LineLength,  ...
MaskVals{ idxMaskNames.LineLength_unit } );
freqlength = length( Freq );


simrfV2checkfreqs( Freq, 'gtez' );
simrfV2checkparam( Res, 'Resistance', 'gtez', freqlength );
simrfV2checkparam( Ind, 'Inductance', 'gtez', freqlength );
simrfV2checkparam( Cap, 'Capacitance', 'gtez', freqlength );
simrfV2checkparam( Cond, 'Conductance', 'gtez', freqlength );
checkparam( linelength, 'Line length' );

ckt = rfckt.rlcgline;
set( ckt, 'Block', block, 'R', Res, 'L', Ind, 'C', Cap,  ...
'G', Cond, 'Freq', Freq, 'IntpType',  ...
MaskVals{ idxMaskNames.Interp_type },  ...
'LineLength', linelength );


case { 'Delay-based and lossless' }
maskName = 'Delay-based\nlossless';
lumpedElement = true;
case { 'Delay-based and lossy' }
maskName = 'Delay-based\nlossy';
lumpedElement = true;
case { 'Lumped parameter L-section' }
maskName = 'Lumped-L';
lumpedElement = true;
case { 'Lumped parameter Pi-section' }
maskName = 'Lumped-Pi';
lumpedElement = true;
end 

if ~lumpedElement
switch MaskVals{ idxMaskNames.StubMode }
case 'Shunt'
set( ckt, 'StubMode', 'Shunt', 'Termination',  ...
MaskVals{ idxMaskNames.Termination } );
case 'Series'
set( ckt, 'StubMode', 'Series', 'Termination',  ...
MaskVals{ idxMaskNames.Termination } );
otherwise 
set( ckt, 'StubMode', 'NotAStub', 'Termination',  ...
'NotApplicable' );
end 


auxData = simrfV2_getauxdata( block );
auxData.Ckt = ckt;
set_param( [ block, '/AuxData' ], 'UserData', auxData );
simrfV2_cachefit( block, MaskWSValues );
end 

catch mex
if strcmpi( get_param( top_sys, 'SimulationStatus' ), 'stopped' )
errordlg( [ block, ': ', mex.message ],  ...
'SimRF Transmission line error', 'on' );
else 
throw( mex )
end 
end 



RepBlk = simrfV2_find_repblk( block,  ...
'^(TRANSMISSION_LINE_RF|f2port|s2port|d2port)$' );
if regexpi( MaskVals{ idxMaskNames.Model_type },  ...
[ '^(Delay-based and lossless|Delay-based and lossy|' ...
, 'Lumped parameter L-section|Lumped parameter Pi-section)$' ] )
SrcBlk = 'simrfV2_lib/Elements/TRANSMISSION_LINE_RF';
Srclib = 'simrfV2_lib';
DstBlk = 'TRANSMISSION_LINE_RF';


modtypecombo = simrfV2_mask_combos( 'transmission_line_rf',  ...
'model_type' );
modtype = int2str( find( strcmp( MaskVals{ idxMaskNames.Model_type },  ...
modtypecombo.Entries ) ) );
lc_paramcombo = simrfV2_mask_combos( 'transmission_line_rf',  ...
'LC_param' );
xlinetype = int2str( find( strcmp(  ...
MaskVals{ idxMaskNames.Parameterization },  ...
lc_paramcombo.Entries ) ) );
else 

if strcmpi( MaskVals{ idxMaskNames.SparamRepresentation },  ...
'Time domain (rationalfit)' )
cacheData = get_param( block, 'UserData' );
if isfield( cacheData, 'RationalModel' ) &&  ...
all( cellfun( 'isempty', cacheData.RationalModel.C ) )
SrcBlk = 'simrfV2_lib/Sparameters/D2PORT_RF';
Srclib = 'simrfV2_lib';
DstBlk = 'd2port';
else 
SrcBlk = 'simrfV2_lib/Sparameters/S2PORT_RF';
Srclib = 'simrfV2_lib';
DstBlk = 's2port';
end 
else 
SrcBlk = 'simrfV2_lib/Sparameters/F2PORT_RF';
Srclib = 'simrfV2_lib';
DstBlk = 'f2port';
end 
end 


replace_src_complete = simrfV2repblk( struct(  ...
'RepBlk', RepBlk, 'SrcBlk', SrcBlk, 'SrcLib', Srclib,  ...
'DstBlk', DstBlk ), block );


if replace_src_complete
simrfV2connports( struct( 'DstBlk', DstBlk,  ...
'DstBlkPortStr', 'LConn', 'DstBlkPortIdx', 1,  ...
'SrcBlk', '1', 'SrcBlkPortStr', 'RConn',  ...
'SrcBlkPortIdx', 1 ), block );

simrfV2connports( struct( 'DstBlk', DstBlk,  ...
'DstBlkPortStr', 'RConn', 'DstBlkPortIdx', 1,  ...
'SrcBlk', '2', 'SrcBlkPortStr', 'RConn',  ...
'SrcBlkPortIdx', 1 ), block );
end 


if strcmpi( MaskVals{ idxMaskNames.InternalGrounding }, 'on' )


negSrcBlk = { 'Gnd1', 'Gnd2' };
negSrcBlkPortStr = 'LConn';
for p_idx = 1:2
p_idx_str = int2str( p_idx );
replace_gnd_complete = simrfV2repblk( struct(  ...
'RepBlk', [ p_idx_str, '-' ],  ...
'SrcBlk', 'simrfV2elements/Gnd',  ...
'SrcLib', 'simrfV2_lib', 'DstBlk', negSrcBlk{ p_idx } ),  ...
block );
end 
newMaskDisplay = simrfV2_add_portlabel( 'simrfV2icon_xline2t',  ...
1, { '1' }, 1, { '2' }, true );
else 

side = { 'Left', 'Right' };
negSrcBlk = { '1-', '2-' };
negSrcBlkPortStr = 'RConn';
for p_idx = 1:2
p_idx_str = int2str( p_idx );
gnd_str = [ 'Gnd', p_idx_str ];
replace_gnd_complete = simrfV2repblk( struct(  ...
'RepBlk', gnd_str,  ...
'SrcBlk', 'nesl_utility_internal/Connection Port',  ...
'SrcLib', 'nesl_utility_internal',  ...
'DstBlk', [ p_idx_str, '-' ],  ...
'Param', { { 'Side', side{ p_idx }, 'Orientation', 'Up',  ...
'Port', int2str( p_idx + 2 ) } } ), block );
end 
newMaskDisplay = simrfV2_add_portlabel( 'simrfV2icon_xline',  ...
2, { '1' }, 2, { '2' }, false );
end 


if replace_gnd_complete || replace_src_complete
connect_side = { 'LConn', 'RConn' };
for p_idx = 1:2
simrfV2connports( struct( 'DstBlk', DstBlk,  ...
'DstBlkPortStr', connect_side{ p_idx }, 'DstBlkPortIdx',  ...
2, 'SrcBlk', negSrcBlk{ p_idx }, 'SrcBlkPortStr',  ...
negSrcBlkPortStr, 'SrcBlkPortIdx', 1 ), block );
end 
end 


set_mask_display( block, maskName, newMaskDisplay );


if regexpi( get_param( top_sys, 'SimulationStatus' ),  ...
'^(updating|initializing)$' )
switch MaskVals{ idxMaskNames.Model_type }
case { 'Delay-based and lossless' }

checkparam( MaskWSValues.TransDelay, 'Transmission delay' );
checkparam( MaskWSValues.CharImped, 'Characteristic impedance' );
simrfV2_set_param( [ block, '/', DstBlk ],  ...
'model_type', modtype, 'LC_param', xlinetype,  ...
'TD', num2str( MaskWSValues.TransDelay, 16 ),  ...
'TD_unit', MaskVals{ idxMaskNames.TransDelay_unit },  ...
'Z0_delay_based', simrfV2vector2str(  ...
MaskWSValues.CharImped ),  ...
'Z0_delay_based_unit',  ...
MaskVals{ idxMaskNames.CharImped_unit } );
return 

case { 'Delay-based and lossy' }
checkparam( MaskWSValues.TransDelay, 'Transmission delay' );
checkparam( MaskWSValues.CharImped, 'Characteristic impedance' );
checkparam( MaskWSValues.Resistance,  ...
'Resistance per unit length' );
checkparam( MaskWSValues.LineLength, 'Line length' );
validateattributes( MaskWSValues.NumSegments,  ...
{ 'numeric' }, { 'nonempty', 'scalar', 'finite', 'real',  ...
'positive', 'integer' }, '', 'Number of segments' );
simrfV2_set_param( [ block, '/', DstBlk ],  ...
'model_type', modtype, 'LC_param', xlinetype,  ...
'TD', num2str( MaskWSValues.TransDelay, 16 ),  ...
'TD_unit', MaskVals{ idxMaskNames.TransDelay_unit },  ...
'Z0_delay_based', simrfV2vector2str(  ...
MaskWSValues.CharImped ),  ...
'Z0_delay_based_unit',  ...
MaskVals{ idxMaskNames.CharImped_unit },  ...
'R', num2str( MaskWSValues.Resistance, 16 ),  ...
'R_unit', MaskVals{ idxMaskNames.Resistance_unit },  ...
'LEN', num2str( MaskWSValues.LineLength, 16 ),  ...
'LEN_unit', MaskVals{ idxMaskNames.LineLength_unit },  ...
'N', num2str( MaskWSValues.NumSegments, 16 ) );
return 

case { 'Lumped parameter L-section', 'Lumped parameter Pi-section' }
checkparam( MaskWSValues.Resistance,  ...
'Resistance per unit length', true );
checkparam( MaskWSValues.Capacitance,  ...
'Capacitance per unit length' );
validateattributes( MaskWSValues.Conductance,  ...
{ 'numeric' }, { 'nonempty', 'scalar', 'finite', 'real',  ...
'nonnegative' }, '', 'Conductance per unit length' );
checkparam( MaskWSValues.LineLength, 'Line length' );
validateattributes( MaskWSValues.NumSegments,  ...
{ 'numeric' }, { 'nonempty', 'scalar', 'finite', 'real',  ...
'positive', 'integer' }, '', 'Number of segments' );
if strcmpi( MaskVals{ idxMaskNames.Parameterization },  ...
'By inductance and capacitance' )
checkparam( MaskWSValues.Inductance,  ...
'Inductance per unit length' );
simrfV2_set_param( [ block, '/', DstBlk ],  ...
'model_type', modtype, 'LC_param', xlinetype,  ...
'R', num2str( MaskWSValues.Resistance, 16 ),  ...
'R_unit', MaskVals{ idxMaskNames.Resistance_unit },  ...
'C', num2str( MaskWSValues.Capacitance, 16 ),  ...
'C_unit', MaskVals{ idxMaskNames.Capacitance_unit },  ...
'L', num2str( MaskWSValues.Inductance, 16 ),  ...
'L_unit', MaskVals{ idxMaskNames.Inductance_unit },  ...
'G', num2str( MaskWSValues.Conductance, 16 ),  ...
'G_unit', MaskVals{ idxMaskNames.Conductance_unit },  ...
'LEN', num2str( MaskWSValues.LineLength, 16 ),  ...
'LEN_unit', MaskVals{ idxMaskNames.LineLength_unit },  ...
'N', num2str( MaskWSValues.NumSegments, 16 ) );
elseif strcmpi( MaskVals{ idxMaskNames.Parameterization },  ...
'By characteristic impedance and capacitance' )
checkparam( MaskWSValues.CharImped,  ...
'Characteristic impedance' );
simrfV2_set_param( [ block, '/', DstBlk ],  ...
'model_type', modtype, 'LC_param', xlinetype,  ...
'Z0', simrfV2vector2str( MaskWSValues.CharImped ),  ...
'Z0_unit', MaskVals{ idxMaskNames.CharImped_unit },  ...
'R', num2str( MaskWSValues.Resistance, 16 ),  ...
'R_unit', MaskVals{ idxMaskNames.Resistance_unit },  ...
'C', num2str( MaskWSValues.Capacitance, 16 ),  ...
'C_unit', MaskVals{ idxMaskNames.Capacitance_unit },  ...
'G', num2str( MaskWSValues.Conductance, 16 ),  ...
'G_unit', MaskVals{ idxMaskNames.Conductance_unit },  ...
'LEN', num2str( MaskWSValues.LineLength, 16 ),  ...
'LEN_unit', MaskVals{ idxMaskNames.LineLength_unit },  ...
'N', num2str( MaskWSValues.NumSegments, 16 ) );
end 
return 
end 
end 



if strcmpi( get_param( top_sys, 'SimulationStatus' ), 'stopped' )

dialog = simrfV2_find_dialog( block );
if ~isempty( dialog )
dialog.refresh;
end 
else 
if strcmpi( MaskVals{ idxMaskNames.SparamRepresentation },  ...
'Time domain (rationalfit)' )
simrfV2sparamblockinit( block );
else 

[ solverfreq, ~, ~, ~, ~, step ] =  ...
simrfV2_find_solverparams( top_sys, block );
if isempty( solverfreq )
return 
end 


if MaskWSValues.AutoImpulseLength
impulse_length = 128 * step;
else 
impulse_length =  ...
simrfV2convert2baseunit( MaskWSValues.ImpulseLength,  ...
MaskWSValues.ImpulseLength_unit );
if impulse_length < 0
error( message(  ...
'simrf:simrfV2errors:NegativeImpulseLength' ) );
end 
end 









if impulse_length < step
new_freqs = solverfreq;
else 
bandwidth = 1 / step;
max_freq = max( solverfreq ) + bandwidth;

df = 1 / impulse_length;
if max_freq / df > 1000
df = max_freq / 1000;
end 
new_freqs = 0:df:max_freq;
end 

auxData = get_param( [ block, '/AuxData' ], 'UserData' );
ckt = auxData.Ckt;
if regexp( MaskVals{ idxMaskNames.Model_type },  ...
'^(Coplanar waveguide|Stripline|Microstrip)$' )
sparsStruct = sparameters( ckt, new_freqs, 50 );

dc_idx = find( abs( new_freqs ) < 1e-3 );
sparsStruct.Parameters( :, :, dc_idx ) =  ...
abs( sparsStruct.Parameters( :, :, dc_idx ) );
zo_vec = ones( 1, sparsStruct.NumPorts ) * sparsStruct.Impedance;
s_1D = simrfV2_sparams3d_to_1d( sparsStruct.Parameters );
else 
analyze( ckt, new_freqs );

ckt.AnalyzedResult.S_Parameters( :, :, 1 ) =  ...
real( ckt.AnalyzedResult.S_Parameters( :, :, 1 ) );
s_1D = simrfV2_sparams3d_to_1d(  ...
ckt.AnalyzedResult.S_Parameters );
numPorts = auxData.Spars.NumPorts;
zo_vec = ones( 1, numPorts ) * ckt.AnalyzedResult.Z0;
end 
set_param( [ block, '/f2port' ],  ...
'ZO', simrfV2vector2str( zo_vec ),  ...
'freqs', simrfV2vector2str( new_freqs ),  ...
'S', simrfV2vector2str( s_1D ),  ...
'Tau', simrfV2vector2str( impulse_length ) );
end 
end 

case 'simrfDelete'

case 'simrfCopy'
auxData = get_param( [ block, '/AuxData' ], 'UserData' );
if isfield( auxData, 'Plot' )
simrfV2Constants = simrfV2_constants(  );
auxData.Plot = simrfV2Constants.Plot;
end 
if isfield( auxData, 'Ckt' ) &&  ...
( isa( auxData.Ckt, 'rfckt.basetxline' ) ||  ...
isa( auxData.Ckt, 'rfckt.txline' ) )
auxData.Ckt = copy( auxData.Ckt );
end 
set_param( [ block, '/AuxData' ], 'UserData', auxData );

case 'simrfDefault'

end 

end 

function Outval = convert2meter( Inval, Unit )

switch Unit
case 'cm'
Outval = 1e-2 * Inval;
case 'mm'
Outval = 1e-3 * Inval;
case 'um'
Outval = 1e-6 * Inval;
case 'in'
Outval = 0.0254 * Inval;
case 'ft'
Outval = 0.3048 * Inval;
otherwise 
Outval = Inval;
end 

end 

function set_mask_display( block, maskname, newMaskDisplay )

newMaskDisplay = sprintf( [ newMaskDisplay ...
, '\ntext(0.5,0.17,''%s'',', '''horizontalAlignment'',''center'');' ],  ...
maskname );
set_param( block, 'MaskDisplay', newMaskDisplay );

end 

function checkparam( value, paramname, canbezero )

if nargin < 3
canbezero = 0;
end 

if ( canbezero == 0 )
validateattributes( value, { 'numeric' },  ...
{ 'nonempty', 'scalar', 'finite', 'real', 'positive' }, '', paramname );
else 
validateattributes( value, { 'numeric' },  ...
{ 'nonempty', 'scalar', 'finite', 'real', 'nonnegative' }, '', paramname );
end 

end 

function checkconductivity( value )

validateattributes( value, { 'numeric' },  ...
{ 'nonempty', 'scalar', 'nonnan', 'real', 'positive' },  ...
'', 'Conductivity of conductor' );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpTi6rHM.p.
% Please follow local copyright laws when handling this file.

