function hNewC = getSinCosCordicComp( hN, hInSignals, hOutSignals, cordicInfo, fName, usePipelines, customLatency, latencyStrategy, hC_Name )




if ( strcmpi( fName, 'sincos' ) )
outNames = { 'sin', 'cos' };
outTypes = [ hOutSignals( 1 ).Type, hOutSignals( 1 ).Type ];
networkName = 'SinCos_cordic_nw';
elseif ( strcmpi( fName, 'cos' ) )
outNames = { 'cos' };
outTypes = [ hOutSignals( 1 ).Type ];
networkName = 'Cos_cordic_nw';
elseif ( strcmpi( fName, 'sin' ) )
outNames = { 'sin' };
networkName = 'Sin_cordic_nw';
outTypes = [ hOutSignals( 1 ).Type ];
else 
outNames = { 'sincos' };
networkName = 'SinCos_cordic_nw';
outTypes = [ hOutSignals( 1 ).Type ];
end 

hCoreNet = pirelab.createNewNetwork(  ...
'Network', hN,  ...
'Name', networkName,  ...
'InportNames', { 'angle' },  ...
'InportTypes', [ hInSignals( 1 ).Type ],  ...
'InportRates', [ hInSignals( 1 ).SimulinkRate ],  ...
'OutportNames', outNames,  ...
'OutportTypes', outTypes );
for itr = 1:length( hOutSignals )
hCoreNet( 1 ).PirOutputSignals( itr ).SimulinkRate = hInSignals( 1 ).SimulinkRate;
end 

hNewC = pirelab.instantiateNetwork( hN, hCoreNet, hInSignals, hOutSignals,  ...
[ hC_Name, '_inst' ] );



if ( nargin < 5 )
usePipelines = true;
end 
hInSigs = hCoreNet.PirInputSignals;
hOutSigs = hCoreNet.PirOutputSignals;

angle = hInSigs( 1 );
if ( strcmpi( fName, 'sin' ) )
sin = hOutSigs( 1 );
elseif ( strcmpi( fName, 'cos' ) )
cos = hOutSigs( 1 );
elseif ( strcmpi( fName, 'sincos' ) )
sin = hOutSigs( 1 );
cos = hOutSigs( 2 );
else 
sincos = hOutSigs( 1 );
end 
if ( angle.Type.isArrayType || angle.Type.isMatrix )
[ dimLen, inputType ] = pirelab.getVectorTypeInfo( angle, true );
vectorEnable = 1;
else 
inputType = angle.Type.BaseType;
vectorEnable = 0;
end 
sin.SimulinkRate = hInSignals( 1 ).SimulinkRate;
cos.SimulinkRate = hInSignals( 1 ).SimulinkRate;

cordicInfo = initialize_parameters( cordicInfo, inputType );
totalPipelinestages = cordicInfo.iterNum + 1;
pipelinestageArray = customPipelineStages( totalPipelinestages, customLatency, latencyStrategy );


K = cordicInfo.scaleFactor;
intermType_k = pirelab.numerictype2pirType( K );
if ( vectorEnable == 1 )
intermType = pirelab.createPirArrayType( intermType_k, dimLen );
else 
intermType = intermType_k;
end 
intermDT = numerictype( K );



angle_ex = pirelab.getTypeInfoAsFi( inputType );
intermFimath = eml_al_cordic_fimath( angle_ex );
if ( vectorEnable == 1 )
ufix1Type = pirelab.createPirArrayType( pir_ufixpt_t( 1, 0 ), dimLen );
else 
ufix1Type = pir_ufixpt_t( 1, 0 );
end 
thetaWordLength = inputType.WordLength;
thetaFractionLength =  - inputType.FractionLength;



z0 = hCoreNet.addSignal( intermType, 'z0' );
negate = hCoreNet.addSignal( ufix1Type, 'negate' );
negate.SimulinkRate = hInSignals( 1 ).SimulinkRate;
if ( strcmpi( fName, 'cos + jsin' ) )
cos = hCoreNet.addSignal( intermType, 'cos' );
sin = hCoreNet.addSignal( intermType, 'sin' );
end 

if ( ( thetaWordLength - ( thetaFractionLength ) - 1 ) <= 1 )

pirelab.getConstComp( hCoreNet, negate, 0, 'Constant', 'on', 1, '', '', '' );
pirelab.getDTCComp( hCoreNet, angle, z0, 'Floor', 'Wrap', 'RWV', 'z0' );
else 

Cmp_thetaMinusOnePi_PiOver2 = hCoreNet.addSignal( ufix1Type, 'Cmp_thetaMinusOnePi_PiOver2' );
Cmp_thetaPlusOnepi_neg_PiOver2 = hCoreNet.addSignal( ufix1Type, 'Cmp_thetaPlusOnepi_neg_PiOver2' );
Cmp_theta_PiOver2 = hCoreNet.addSignal( ufix1Type, 'Cmp_theta_PiOver2' );
Cmp_theta_negatepiOver2 = hCoreNet.addSignal( ufix1Type, 'Cmp_theta_negatepiOver2' );
Constant = hCoreNet.addSignal( ufix1Type, 'Constant' );
Constant.SimulinkRate = hInSignals( 1 ).SimulinkRate;



contant_theta_Wordlength = max( thetaWordLength, 16 );
if ( vectorEnable == 1 )
constant_thetaType = pirelab.createPirArrayType( pir_sfixpt_t( contant_theta_Wordlength,  - ( contant_theta_Wordlength - 4 ) ), dimLen );
else 
constant_thetaType = pir_sfixpt_t( contant_theta_Wordlength,  - ( contant_theta_Wordlength - 4 ) );
end 

if ( vectorEnable == 1 )
corrected_theta_type = pirelab.createPirArrayType( pir_sfixpt_t( thetaWordLength,  - ( thetaWordLength - 2 ) ), dimLen );
else 
corrected_theta_type = pir_sfixpt_t( thetaWordLength,  - ( thetaWordLength - 2 ) );
end 
corrected_theta = hCoreNet.addSignal( corrected_theta_type, 'corrected_theta' );


negatepiOver2 = hCoreNet.addSignal( constant_thetaType, 'negatepiOver2' );
onePi = hCoreNet.addSignal( constant_thetaType, 'onePi' );
onePi.SimulinkRate = hInSignals( 1 ).SimulinkRate;
piOver2 = hCoreNet.addSignal( constant_thetaType, 'piOver2' );
piOver2.SimulinkRate = hInSignals( 1 ).SimulinkRate;
thetaMinusOnePi = hCoreNet.addSignal( constant_thetaType, 'thetaMinusOnePi' );
thetaMinusOnePi.SimulinkRate = hInSignals( 1 ).SimulinkRate;
thetaMinusTwoPi = hCoreNet.addSignal( constant_thetaType, 'thetaMinusTwoPi' );
thetaMinusTwoPi.SimulinkRate = hInSignals( 1 ).SimulinkRate;

thetaPlusOnePi = hCoreNet.addSignal( constant_thetaType, 'thetaPlusOnePi' );
thetaPlusOnePi.SimulinkRate = hInSignals( 1 ).SimulinkRate;
thetaPlusTwoPi = hCoreNet.addSignal( constant_thetaType, 'thetaPlusTwoPi' );
thetaPlusTwoPi.SimulinkRate = hInSignals( 1 ).SimulinkRate;

twoPi = hCoreNet.addSignal( constant_thetaType, 'twoPi' );
twoPi.SimulinkRate = hInSignals( 1 ).SimulinkRate;
Switch_c1 = hCoreNet.addSignal( ufix1Type, 'Switch_c1' );
Switch3_c1 = hCoreNet.addSignal( ufix1Type, 'Switch3_c1' );
Switch4_c1 = hCoreNet.addSignal( ufix1Type, 'Switch4_c1' );
if ( ( thetaWordLength - ( thetaFractionLength ) ) > 4 )
corrected_theta_type_temp = constant_thetaType;
else 
corrected_theta_type_temp = corrected_theta_type;
end 

thetaMinusOnePi_dtc = hCoreNet.addSignal( corrected_theta_type_temp, 'thetaMinusOnePi_dtc' );
thetaMinusTwoPi_dtc = hCoreNet.addSignal( corrected_theta_type_temp, 'thetaMinusTwoPi_dtc' );
thetaPlusOnePi_dtc = hCoreNet.addSignal( corrected_theta_type_temp, 'thetaPlusOnePi_dtc' );
thetaPlusTwoPi_dtc = hCoreNet.addSignal( corrected_theta_type_temp, 'thetaPlusTwoPi_dtc' );
Switch = hCoreNet.addSignal( corrected_theta_type_temp, 'Switch' );
Switch3 = hCoreNet.addSignal( corrected_theta_type_temp, 'Switch3' );
Switch4 = hCoreNet.addSignal( corrected_theta_type_temp, 'Switch4' );


pirelab.getConstComp( hCoreNet, Constant, 0, 'Constant', 'on', 1, '', '', '' );


if ( ( thetaWordLength - ( thetaFractionLength ) ) > 4 )
if ( vectorEnable == 1 )
theta_intermType = pirelab.createPirArrayType( pir_sfixpt_t( thetaWordLength,  - ( thetaWordLength - 4 ) ), dimLen );
else 
theta_intermType = pir_sfixpt_t( thetaWordLength,  - ( thetaWordLength - 4 ) );
end 
moveFractionLengthUp = hCoreNet.addSignal( theta_intermType, 'moveFractionLengthUp' );
moveFractionLengthUp_dtc = hCoreNet.addSignal( theta_intermType, 'moveFractionLengthUp_dtc' );
pirelab.getDTCComp( hCoreNet, angle, moveFractionLengthUp, 'Floor', 'Wrap', 'RWV', 'moveFractionLengthUp' );
pirelab.getDTCComp( hCoreNet, moveFractionLengthUp, moveFractionLengthUp_dtc, 'Floor', 'Wrap', 'RWV', 'moveFractionLengthUp_dtc' );
else 
if ( vectorEnable == 1 )
theta_intermType = pirelab.createPirArrayType( pir_sfixpt_t( thetaWordLength,  - thetaFractionLength ), dimLen );
else 
theta_intermType = pir_sfixpt_t( thetaWordLength,  - thetaFractionLength );
end 
moveFractionLengthUp = hCoreNet.addSignal( theta_intermType, 'moveFractionLengthUp' );
moveFractionLengthUp_dtc = hCoreNet.addSignal( corrected_theta_type, 'moveFractionLengthUp_dtc' );

pirelab.getDTCComp( hCoreNet, angle, moveFractionLengthUp, 'Floor', 'Wrap', 'RWV', 'moveFractionLengthUp' );
pirelab.getDTCComp( hCoreNet, moveFractionLengthUp, moveFractionLengthUp_dtc, 'Floor', 'Wrap', 'RWV', 'moveFractionLengthUp' );
end 

fiMath1 = fimath( 'RoundingMethod', 'Nearest', 'OverflowAction', 'Saturate', 'ProductMode', 'FullPrecision', 'SumMode', 'FullPrecision' );
nt2 = numerictype( 1, contant_theta_Wordlength, contant_theta_Wordlength - 4 );

pirelab.getConstComp( hCoreNet, piOver2, fi( pi / 2, nt2, fiMath1 ), 'piOver2', 'on', 0, '', '', '' );

pirelab.getConstComp( hCoreNet, twoPi, fi( 2 * pi, nt2, fiMath1 ), 'twoPi', 'on', 0, '', '', '' );

pirelab.getConstComp( hCoreNet, onePi, fi( pi, nt2, fiMath1 ), 'onePi', 'on', 0, '', '', '' );

pirelab.getUnaryMinusComp( hCoreNet, piOver2, negatepiOver2, 'Wrap', 'negatepiOver2' );
pirelab.getAddComp( hCoreNet, [ moveFractionLengthUp, onePi ], thetaMinusOnePi, 'Floor', 'Wrap', 'thetaMinusOnePi', constant_thetaType, '+-' );
pirelab.getDTCComp( hCoreNet, thetaMinusOnePi, thetaMinusOnePi_dtc, 'Floor', 'Wrap', 'RWV', 'thetaMinusOnePi_dtc' );
pirelab.getAddComp( hCoreNet, [ moveFractionLengthUp, twoPi ], thetaMinusTwoPi, 'Floor', 'Wrap', 'thetaMinusTwoPi', constant_thetaType, '+-' );
pirelab.getDTCComp( hCoreNet, thetaMinusTwoPi, thetaMinusTwoPi_dtc, 'Floor', 'Wrap', 'RWV', 'thetaMinusTwoPi_dtc' );
pirelab.getAddComp( hCoreNet, [ moveFractionLengthUp, onePi ], thetaPlusOnePi, 'Floor', 'Wrap', 'thetaPlusOnePi', constant_thetaType, '++' );
pirelab.getDTCComp( hCoreNet, thetaPlusOnePi, thetaPlusOnePi_dtc, 'Floor', 'Wrap', 'RWV', 'thetaPlusOnePi_dtc' );
pirelab.getAddComp( hCoreNet, [ moveFractionLengthUp, twoPi ], thetaPlusTwoPi, 'Floor', 'Wrap', 'thetaPlusTwoPi', constant_thetaType, '++' );
pirelab.getDTCComp( hCoreNet, thetaPlusTwoPi, thetaPlusTwoPi_dtc, 'Floor', 'Wrap', 'RWV', 'thetaPlusTwoPi_dtc' );

pirelab.getRelOpComp( hCoreNet, [ moveFractionLengthUp, piOver2 ], Cmp_theta_PiOver2, '>', 0, 'Cmp_theta_PiOver2' );
pirelab.getRelOpComp( hCoreNet, [ thetaMinusOnePi, piOver2 ], Cmp_thetaMinusOnePi_PiOver2, '<=', 0, 'Cmp_thetaMinusOnePi_PiOver2' );
pirelab.getRelOpComp( hCoreNet, [ thetaPlusOnePi, negatepiOver2 ], Cmp_thetaPlusOnepi_neg_PiOver2, '>=', 0, 'Cmp_thetaPlusOnepi_neg_PiOver2' );
pirelab.getRelOpComp( hCoreNet, [ moveFractionLengthUp, negatepiOver2 ], Cmp_theta_negatepiOver2, '<', 0, 'Cmp_theta_negatepiOver2' );
pirelab.getSwitchComp( hCoreNet, [ thetaMinusOnePi_dtc, thetaMinusTwoPi_dtc ], Switch, Cmp_thetaMinusOnePi_PiOver2, 'Switch', '>', 0, 'Floor', 'Wrap' );
pirelab.getSwitchComp( hCoreNet, [ Switch, Switch4 ], corrected_theta, Cmp_theta_PiOver2, 'Switch1', '>', 0, 'Floor', 'Wrap' );
pirelab.getDTCComp( hCoreNet, corrected_theta, z0, 'Floor', 'Wrap', 'RWV', 'z0' );
pirelab.getSwitchComp( hCoreNet, [ thetaPlusOnePi_dtc, thetaPlusTwoPi_dtc ], Switch3, Cmp_thetaPlusOnepi_neg_PiOver2, 'Switch3', '>', 0, 'Floor', 'Wrap' );
pirelab.getSwitchComp( hCoreNet, [ Switch3, moveFractionLengthUp_dtc ], Switch4, Cmp_theta_negatepiOver2, 'Switch4', '>', 0, 'Floor', 'Wrap' );

pirelab.getSwitchComp( hCoreNet, [ Cmp_thetaMinusOnePi_PiOver2, Constant ], Switch_c1, Cmp_thetaMinusOnePi_PiOver2, 'Switch_c1', '>', 0, 'Floor', 'Wrap' );
pirelab.getSwitchComp( hCoreNet, [ Cmp_thetaPlusOnepi_neg_PiOver2, Constant ], Switch3_c1, Cmp_thetaPlusOnepi_neg_PiOver2, 'Switch3_c1', '>', 0, 'Floor', 'Wrap' );
pirelab.getSwitchComp( hCoreNet, [ Switch3_c1, Constant ], Switch4_c1, Cmp_theta_negatepiOver2, 'Switch4_c1', '>', 0, 'Floor', 'Wrap' );
pirelab.getSwitchComp( hCoreNet, [ Switch_c1, Switch4_c1 ], negate, Cmp_theta_PiOver2, 'Switch1_c1', '>', 0, 'Floor', 'Wrap' );
end 




if ( usePipelines )
z0_p = hCoreNet.addSignal( intermType, 'z0_p' );
d1C = pirelab.getIntDelayComp( hCoreNet, z0, z0_p, pipelinestageArray( 1 ), 'z0_reg' );
if ( pipelinestageArray( 1 ) )
d1C.addComment( 'Pipeline registers' );
end 
else 
z0_p = z0;
end 
pStageSum = sum( pipelinestageArray( 1:end  ) );
if ( usePipelines )
negate_p = hCoreNet.addSignal( ufix1Type, 'negate_p' );
pirelab.getIntDelayComp( hCoreNet, negate, negate_p, pStageSum, 'negate_reg' );
else 
negate_p = negate;
end 



x0 = hCoreNet.addSignal( intermType, 'x0' );
y0 = hCoreNet.addSignal( intermType, 'y0' );

x0.SimulinkRate = hInSignals( 1 ).SimulinkRate;
y0.SimulinkRate = hInSignals( 1 ).SimulinkRate;

pirelab.getConstComp( hCoreNet, x0, K );
pirelab.getConstComp( hCoreNet, y0, 0 );


tInSignals = [ x0, y0, z0_p ];
for stageNum = 1:cordicInfo.iterNum


x = hCoreNet.addSignal( intermType, sprintf( 'x%d', stageNum ) );
y = hCoreNet.addSignal( intermType, sprintf( 'y%d', stageNum ) );
z = hCoreNet.addSignal( intermType, sprintf( 'z%d', stageNum ) );



lutValues = cordicInfo.lutValue;
lut_value = fi( lutValues( stageNum ), intermDT, intermFimath );

























rt_shift = stageNum - 1;

x_shift = hCoreNet.addSignal( intermType, sprintf( 'x_shift%d', stageNum ) );
y_shift = hCoreNet.addSignal( intermType, sprintf( 'y_shift%d', stageNum ) );


x_temp = hCoreNet.addSignal( intermType, sprintf( 'x_temp_1_%d', stageNum ) );
y_temp = hCoreNet.addSignal( intermType, sprintf( 'y_temp_1_%d', stageNum ) );
lut_value_temp = hCoreNet.addSignal( intermType, sprintf( 'lut_value_temp_1_%d', stageNum ) );
x_temp_0 = hCoreNet.addSignal( intermType, sprintf( 'x_temp_0_%d', stageNum ) );
y_temp_0 = hCoreNet.addSignal( intermType, sprintf( 'y_temp_0_%d', stageNum ) );
lut_value_temp_0 = hCoreNet.addSignal( intermType, sprintf( 'lut_value_temp_0_%d', stageNum ) );
lut_value_s = hCoreNet.addSignal( intermType, sprintf( 'lut_value_s%d', stageNum ) );
lut_value_s.SimulinkRate = hInSignals( 1 ).SimulinkRate;
comp_zero = hCoreNet.addSignal( ufix1Type, sprintf( 'comp_zero%d', stageNum ) );
pirelab.getCompareToValueComp( hCoreNet, tInSignals( 3 ), comp_zero, '<', double( 0 ), sprintf( 'ComparetoZero%d', stageNum ) );
pirelab.getConstComp( hCoreNet, lut_value_s, lut_value, 'lut_value', 'on', 0, '', '', '' );
pirelab.getBitShiftComp( hCoreNet, tInSignals( 1 ), x_shift, 'sra', rt_shift, 0, sprintf( 'Bit_shift_comp_x_%d', stageNum ) );
pirelab.getBitShiftComp( hCoreNet, tInSignals( 2 ), y_shift, 'sra', rt_shift, 0, sprintf( 'Bit_shift_comp_y_%d', stageNum ) );

pirelab.getAddComp( hCoreNet, [ tInSignals( 1 ), y_shift ], x_temp, 'Floor', 'Wrap', sprintf( 'x_temp_1_%d', stageNum ), intermType, '++' );
pirelab.getAddComp( hCoreNet, [ tInSignals( 2 ), x_shift ], y_temp, 'Floor', 'Wrap', sprintf( 'y_temp_1_%d', stageNum ), intermType, '+-' );
pirelab.getAddComp( hCoreNet, [ tInSignals( 3 ), lut_value_s ], lut_value_temp, 'Floor', 'Wrap', sprintf( 'lut_value_temp_1_%d', stageNum ), intermType, '++' );

pirelab.getAddComp( hCoreNet, [ tInSignals( 1 ), y_shift ], x_temp_0, 'Floor', 'Wrap', sprintf( 'x_temp_0_%d', stageNum ), intermType, '+-' );
pirelab.getAddComp( hCoreNet, [ tInSignals( 2 ), x_shift ], y_temp_0, 'Floor', 'Wrap', sprintf( 'y_temp_0_%d', stageNum ), intermType, '++' );
pirelab.getAddComp( hCoreNet, [ tInSignals( 3 ), lut_value_s ], lut_value_temp_0, 'Floor', 'Wrap', sprintf( 'lut_value_temp_0_%d', stageNum ), intermType, '+-' );

pirelab.getSwitchComp( hCoreNet, [ x_temp, x_temp_0 ], x, comp_zero, sprintf( 'x_rotated_%d', stageNum ), '>', 0, 'Floor', 'Wrap' );
pirelab.getSwitchComp( hCoreNet, [ y_temp, y_temp_0 ], y, comp_zero, sprintf( 'y_rotated_%d', stageNum ), '>', 0, 'Floor', 'Wrap' );
pirelab.getSwitchComp( hCoreNet, [ lut_value_temp, lut_value_temp_0 ], z, comp_zero, sprintf( 'lut_value_rotated_%d', stageNum ), '>', 0, 'Floor', 'Wrap' );


if ( usePipelines )

x_p = hCoreNet.addSignal( intermType, sprintf( 'x%d_p', stageNum ) );
y_p = hCoreNet.addSignal( intermType, sprintf( 'y%d_p', stageNum ) );

d2C = pirelab.getIntDelayComp( hCoreNet, x, x_p, pipelinestageArray( 1 + stageNum ), 'x_reg' );
if ( pipelinestageArray( 1 + stageNum ) )
d2C.addComment( 'Pipeline registers' );
end 
pirelab.getIntDelayComp( hCoreNet, y, y_p, pipelinestageArray( 1 + stageNum ), 'y_reg' );
else 
x_p = x;
y_p = y;
end 

if all( [ stageNum ~= cordicInfo.iterNum, usePipelines ] )
z_p = hCoreNet.addSignal( intermType, sprintf( 'z%d_p', stageNum ) );
pirelab.getIntDelayComp( hCoreNet, z, z_p, pipelinestageArray( 1 + stageNum ), 'z_reg' );
else 
z_p = z;
end 


tInSignals = [ x_p, y_p, z_p ];
end 



tInSignals = [ x_p, y_p, negate_p ];















x_p_negate = hCoreNet.addSignal( intermType, sprintf( 'x_p_negate' ) );
y_p_negate = hCoreNet.addSignal( intermType, sprintf( 'y_p_negate' ) );


pirelab.getUnaryMinusComp( hCoreNet, tInSignals( 1 ), x_p_negate, 'Wrap', sprintf( 'x_p_negate' ) );
pirelab.getUnaryMinusComp( hCoreNet, tInSignals( 2 ), y_p_negate, 'Wrap', sprintf( 'y_p_negate' ) );

if ( strcmpi( fName, 'sin' ) )
pirelab.getSwitchComp( hCoreNet, [ y_p_negate, tInSignals( 2 ) ], sin, tInSignals( 3 ), sprintf( 'yout_post' ), '>', 0, 'Floor', 'Wrap' );
elseif ( strcmpi( fName, 'cos' ) )
pirelab.getSwitchComp( hCoreNet, [ x_p_negate, tInSignals( 1 ) ], cos, tInSignals( 3 ), sprintf( 'xout_post' ), '>', 0, 'Floor', 'Wrap' );
elseif ( strcmpi( fName, 'sincos' ) )
pirelab.getSwitchComp( hCoreNet, [ y_p_negate, tInSignals( 2 ) ], sin, tInSignals( 3 ), sprintf( 'yout_post' ), '>', 0, 'Floor', 'Wrap' );
pirelab.getSwitchComp( hCoreNet, [ x_p_negate, tInSignals( 1 ) ], cos, tInSignals( 3 ), sprintf( 'xout_post' ), '>', 0, 'Floor', 'Wrap' );
else 
pirelab.getSwitchComp( hCoreNet, [ y_p_negate, tInSignals( 2 ) ], sin, tInSignals( 3 ), sprintf( 'yout_post' ), '>', 0, 'Floor', 'Wrap' );
pirelab.getSwitchComp( hCoreNet, [ x_p_negate, tInSignals( 1 ) ], cos, tInSignals( 3 ), sprintf( 'xout_post' ), '>', 0, 'Floor', 'Wrap' );
pirelab.getRealImag2Complex( hCoreNet, [ cos, sin ], sincos );
end 


end 



function cordicInfo = initialize_parameters( cordicInfo, inputType )

if ~isfield( cordicInfo, 'iterNum' )
cordicInfo.iterNum = 11;
end 

if ~isfield( cordicInfo, 'networkName' )
cordicInfo.networkName = 'sincos_cordic';
end 


if ~isfield( cordicInfo, 'scaleFactor' )
inputWL = inputType.WordLength;
intermWL = inputWL;
intermFL = inputWL - 2;
intermDT = numerictype( 1, intermWL, intermFL );
cordicInfo.scaleFactor = fi( 1 / 1.6467602, intermDT );
end 


if ~isfield( cordicInfo, 'lutValue' )
intermDT = numerictype( cordicInfo.scaleFactor );
cordicInfo.lutValue = fi( atan( 1 ./ ( 2 .^ ( 0:cordicInfo.iterNum - 1 ) ) ), intermDT );
end 

if inputType.isFloatType || ~inputType.Signed
error( message( 'hdlcommon:hdlcommon:InputTypeMustBeSigned' ) );
end 

end 


function cordicFimath = eml_al_cordic_fimath( angle )




if isfloat( angle )


eml_assert( 0 );
else 


angleType = numerictype( angle );
ioWordLength = angleType.WordLength;
ioFracLength = ioWordLength - 2;




cordicFimath = fimath( 'SumMode', 'SpecifyPrecision',  ...
'SumWordLength', ioWordLength,  ...
'SumFractionLength', ioFracLength,  ...
'RoundMode', 'floor',  ...
'OverflowMode', 'wrap' ...
 );
end 
end 

function pipelinestageArray = customPipelineStages( totalPipelineStages, latency, latencyStrategy )

pipelinestageArray = zeros( 1, totalPipelineStages );
if ( strcmpi( latencyStrategy, 'MAX' ) )
pipelinestageArray = ones( 1, totalPipelineStages );
elseif ( strcmpi( latencyStrategy, 'CUSTOM' ) )


if ( latency ~= 0 )



if ( latency == 1 )
if ( ( totalPipelineStages - 3 ) > 0 )
pipelinestageArray( end  - ( end  - 3 ) ) = 1;
else 
pipelinestageArray( 1 ) = 1;
end 
elseif ( latency == 2 )
if ( totalPipelineStages ~= 6 )


if ( ( totalPipelineStages - 3 ) > 0 )
pipelinestageArray( 3 ) = 1;
pipelinestageArray( end  - 3 ) = 1;
else 
pipelinestageArray( 1 ) = 1;
pipelinestageArray( end  ) = 1;
end 

else 

pipelinestageArray( 2 ) = 1;
pipelinestageArray( end  - 3 ) = 1;
end 

else 


k = ceil( totalPipelineStages / latency );

j = 1;
temp = 1;

for i = 1:latency
if ( latency > 1 )
if ( i == latency )

pipelinestageArray( end  ) = 1;
else 
pipelinestageArray( j ) = 1;


if ( j < totalPipelineStages - k )
j = j + k;
else 

j = temp + 1;

temp = temp + 1;
end 
end 

else 
pipelinestageArray( j ) = 1;
end 

end 
end 
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpK5lUzg.p.
% Please follow local copyright laws when handling this file.

