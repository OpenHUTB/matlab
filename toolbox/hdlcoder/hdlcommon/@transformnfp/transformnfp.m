

classdef transformnfp < handle



methods ( Static )



hNewC = transformComplexComp( hN, hC, targetCompMap, nfpComp, hInSignals,  ...
hOutSignals, idx, isSingleType, compositeNFPOptions );
hNewC = transformScalarComp( hN, hC, targetCompMap, nfpComp, hInSignals,  ...
hOutSignals, idx, isRealFactor, isSingleType );
hNew = addNfpAbsComp( hN, slRate, isSingle );
hNew = addNfpAddComp( hN, latency, slRate, isSingle, isHalf );
hNew = addNfpDivComp( hN, latency, slRate, isSingle, isHalf );
hNew = addNfpExpComp( hN, latency, slRate, isSingle, isHalf )
hNew = addNfpLogComp( hN, latency, slRate, isSingle, isHalf );
hNew = addNfpLog2Comp( hN, slRate, isSingle );
hNew = addNfpLog10Comp( hN, latency, slRate, isSingle, isHalf );
hNew = addNfpPowComp( hN, slRate, isSingle );
hNew = addNfpPow2Comp( hN, slRate, isSingle );
hNew = addNfpPow10Comp( hN, slRate, isSingle );
hNew = addNfpMinMaxComp( hN, slRate, isSingle );
hNew = addNfpMulComp( hN, latency, slRate, isSingle, isHalf );
hNew = addNfpGainPow2Comp( hN, latency, slRate, isSingle, isHalf );
hNew = addNfpRecipComp( hN, latency, slRate, isSingle, isHalf );
hNew = addNfpHDLRecipComp( hN, slRate, numIters, isSingle );
hNew = addNfpRelopComp( hN, opName, latency, slRate, isSingle, isHalf );
hNew = addNfpRemComp( hN, slRate, isSingle );
hNew = addNfpRoundComp( hN, latency, slRate, isSingle );
hNew = addNfpFloorComp( hN, latency, slRate, isSingle );
hNew = addNfpFixComp( hN, latency, slRate, isSingle );
hNew = addNfpCeilComp( hN, latency, slRate, isSingle );
hNew = addNfpRSqrtComp( hN, latency, slRate, isSingle );
hNew = addNfpSqrtComp( hN, latency, slRate, isSingle, isHalf );
hNew = addNfpSubComp( hN, latency, slRate, isSingle, isHalf );
hNew = addNfpTrigComp( hN, slRate, isSingle );
hNew = addNfpATanComp( hN, slRate, isSingle );
hNew = addNfpASinComp( hN, slRate, isSingle );
hNew = addNfpACosComp( hN, slRate, isSingle );
hNew = addNfpATan2Comp( hN, slRate, isSingle );
hNew = addNfpSinhComp( hN, slRate, isSingle );
hNew = addNfpCoshComp( hN, slRate, isSingle );
hnew = addNfpTanhComp( hN, slRate, isSingle );
hnew = addNfpAsinhComp( hN, hC, slRate, isSingle );
hnew = addNfpAcoshComp( hN, hC, slRate, isSingle );
hnew = addNfpAtanhComp( hN, hC, slRate, isSingle );
hNew = addNfpModComp( hN, slRate, isSingle );
hNew = addNfpSignumComp( hN, slRate, isSingle );
hNew = addNfpSinComp( hN, latency, slRate, argReduction, partMultOpt, isSingle, isHalf );
hNew = addNfpSinCosComp( hN, slRate, argReduction, partMultOpt, isSingle );
hNew = addNfpCosComp( hN, latency, slRate, argReduction, partMultOpt, isSingle, isHalf );
hNew = addNfpTanComp( hN, slRate, argReduction, isSingle );
hNew = addNfpUminusComp( hN, slRate, isSingle, isHalf );
hNew = addNfpNZUminusComp( hN, uniqNtwkName, slRate, isSingle, isHalf );
hNew = addNfpFixed2Float( hN, latency, slRate, WL, UWL, FL, isSingle, isHalf );
hNew = addNfpFloat2Fixed( hN, latency, slRate, WL, UWL, FL, rndMode,  ...
satMode, flGtZero, isSingle, isHalf );
hNew = addNfpFMAComp( hN, slRate, isSingle );
hNew = addNfpHypotComp( hN, slRate, isSingle );

hNew = getSingleAbsComp( hN, slRate );
hNew = getSingleAddComp( hN, latency, slRate );
hNew = getSingleDivComp( hN, latency, slRate );
hNew = getSingleLogComp( hN, latency, slRate, denormal );
hNew = getSingleLogPolyApproxComp( hN, slRate, denormal );
hNew = getSingleLog2Comp( hN, latency, slRate, denormal );
hNew = getSingleLog10Comp( hN, slRate, denormal );
hNew = getSinglePowComp( hN, slRate, denormal );
hNew = getSinglePow2Comp( hN, slRate, denormal );
hNew = getSingleExpPow10Comp( hN, slRate, fname, denormal );
hNew = getSingleMinMaxComp( hN, slRate );
hNew = getSingleMulComp( hN, latency, slRate, denormal, mantMulStrategy, partAddShiftMulSize );
hNew = getSingleGainPow2Comp( hN, latency, slRate );
hNew = getSingleRecipComp( hN, latency, slRate, denormal );
hNew = getSingleHDLRecipComp( hN, slRate, denormal, numIters );
hNew = getSingleRelopComp( hN, hC, latency, slRate );
hNew = getSingleModRemComp( hN, slRate, modOrRem, maxIterations, checkReset );
hNew = getSingleRoundComp( hN, latency, slRate );
hNew = getSingleFloorComp( hN, latency, slRate );
hNew = getSingleFixComp( hN, latency, slRate );
hNew = getSingleCeilComp( hN, latency, slRate );
hNew = getSingleRSqrtComp( hN, latency, slRate );
hNew = getSingleSignumComp( hN, slRate );
hNew = getSingleSqrtComp( hN, latency, slRate, denormal );
hNew = getSingleSubComp( hN, latency, slRate );
hNew = getSingleTrigComp( hN, slRate );
hNew = getSingleATanComp( hN, slRate );
hNew = getSingleASinComp( hN, slRate );
hNew = getSingleACosComp( hN, slRate );
hNew = getSingleATan2Comp( hN, slRate, denormal );
hNew = getSingleSinOrCosComp( hN, isSin, partMultOpt, slRate );
hNew = getSingleSinCosComp( hN, partMultOpt, slRate );
hNew = getSingleTanComp( hN, argReduction, slRate );
hNew = getSingleFMAComp( hN, slRate, denormal, mantMulStrategy, partAddShiftMulSize );
hNew = getSingleHypotComp( hN, slRate );

hNew = getSingleSinhComp( hN, slRate );
hNew = getSingleCoshComp( hN, slRate );
hNew = getSingleTanhComp( hN, slRate );
hNew = getSingleSinOrCosCompArgReduce( hN, isSinModel, partMultOpt, slRate );
hNew = getSingleSinCosCompArgReduce( hN, partMultOpt, slRate );
hNew = getSingleAsinhComp( hN, hC, slRate, blkNameSuffix );
hNew = getSingleAcoshComp( hN, hC, slRate, blkNameSuffix );
hNew = getSingleAtanhComp( hN, hC, slRate, blkNameSuffix );

hNew = getSingleUminusComp( hN, slRate );
hNew = getSingleNZUminusComp( hN, uniqNtwkName, slRate );
hNew = getConvertFixed2Single( hN, pipestage, slRate, WL, UWL, FL );
hNew = getConvertSingle2Fixed( hN, pipestage, slRate, WL, UWL, FL,  ...
rndMode, satMode, flGtZero );

hNew = getConvertSingle2HalfComp( hN, slRate, denormal );
hNew = getConvertHalf2SingleComp( hN, slRate, denormal );



hNew = getHalfMulComp( hN, latency, slRate, denormal, mantMulStrategy );
hNew = getHalfAddComp( hN, latency, slRate );
hNew = getHalfSubComp( hN, latency, slRate );
hNew = getHalfDivComp( hN, latency, slRate );
hNew = getHalfRecipComp( hN, latency, slRate, denormal );
hNew = getHalfGainPow2Comp( hN, latency, slRate );
hNew = getHalfUminusComp( hN, slRate );
hNew = getHalfNZUminusComp( hN, uniqNtwkName, slRate );
hNew = getHalfRelopComp( hN, opName, latency, slRate );

hNew = getHalfSqrtComp( hN, latency, slRate, denormal );
hNew = getHalfExpComp( hN, latency, slRate, denormal );
hNew = getHalfLog10Comp( hN, latency, slRate, denormal );
hNew = getHalfLogComp( hN, latency, slRate, denormal );
hNew = getHalfSinComp( hN, latency, slRate, denormal );
hNew = getHalfCosComp( hN, latency, slRate, denormal );
hNew = getConvertFixed2Half( hN, slRate, WL, UWL, FL );
hNew = getConvertHalf2Fixed( hN, slRate, WL, UWL, FL, rndMode, satMode, flGtZero );


hNew = getDoubleAbsComp( hN, slRate );
hNew = getDoubleAddComp( hN, latency, slRate );
hNew = getDoubleDivComp( hN, latency, slRate );
hNew = getDoubleExpComp( hN, slRate );
hNew = getDoubleLogComp( hN, latency, slRate, denormal );
hNew = getDoubleMinMaxComp( hN, slRate );
hNew = getDoubleMulComp( hN, slRate, latency, denormal );
hNew = getDoubleGainPow2Comp( hN, latency, slRate );
hNew = getDoubleRecipComp( hN, latency, slRate );
hNew = getDoubleRoundComp( hN, latency, slRate );
hNew = getDoubleFloorComp( hN, latency, slRate );
hNew = getDoubleCeilComp( hN, latency, slRate );
hNew = getDoubleFixComp( hN, latency, slRate );
hNew = getDoubleHDLRecipComp( hN, slRate, denormal, numIters );
hNew = getDoubleRelopComp( hN, opName, latency, slRate );
hNew = getDoubleRSqrtComp( hN, latency, slRate );
hNew = getDoubleSignumComp( hN, slRate );
hNew = getDoubleSqrtComp( hN, latency, slRate, denormal );
hNew = getDoubleSubComp( hN, latency, slRate );
hNew = getDoubleTrigComp( hN, slRate );
hNew = getDoubleATanComp( hN, slRate );
hNew = getDoubleASinComp( hN, slRate );
hNew = getDoubleACosComp( hN, slRate );
hNew = getDoubleATan2Comp( hN, slRate, denormal );
hNew = getDoubleSinComp( hN, slRate );
hNew = getDoubleCosComp( hN, slRate );
hNew = getDoubleTanComp( hN, argReduction, slRate );
hNew = getDoubleUminusComp( hN, slRate );
hNew = getDoubleNZUminusComp( hN, uniqNtwkName, slRate );
hNew = getConvertFixed2Double( hN, latency, slRate, WL, UWL, FL );
hNew = getConvertDouble2Fixed( hN, latency, slRate, WL, UWL, FL, rndMode, satMode, flGtZero );
hNew = getConvertSingle2DoubleComp( hN, latency, slRate );
hNew = getConvertDouble2SingleComp( hN, latency, slRate );

createSingle27x27PartMulComp( p, hN, slRate );
createSingle27xS27PartMulComp( p, hN, slRate );
createSingle27x24PartMulComp( p, hN, slRate );
createSingle27x27FullMulComp( p, hN, slRate );
createSingle27xS27FullMulComp( p, hN, slRate );
createSingle27x24FullMulComp( p, hN, slRate );

create24x24MulComp_FullMultiplier( p, hN, Pipeline1, Pipeline2, slRate );
create24x24MulComp_PartMultiplier_18x24( p, hN, Pipeline1, Pipeline2, Pipeline3, Pipeline4, Pipeline5, slRate );
create24x24MulComp_PartMultiplier_18x18( p, hN, Pipeline1, Pipeline2, Pipeline3, Pipeline4, Pipeline5, Pipeline6, slRate );
create24x24MulComp_PartMultiplier_17x17( p, hN, Pipeline1, Pipeline2, Pipeline3, Pipeline4, Pipeline5, Pipeline6, slRate );
create24x24MulComp_FullAddShift( p, hN, Pipeline1, Pipeline2, Pipeline3, Pipeline4, Pipeline5, Pipeline6, slRate );



getHalfPackComp( hN, hInSignals, hOutSignals, compName );
getHalfUnpackComp( hN, hInSignals, hOutSignals, compName );
getSinglePackComp( hN, hInSignals, hOutSignals, compName );
getSingleUnpackComp( hN, hInSignals, hOutSignals, compName );
getDoublePackComp( hN, hInSignals, hOutSignals, compName );
getDoubleUnpackComp( hN, hInSignals, hOutSignals, compName );
[ nfpNetwork, customLatency ] = addNfpNetwork( hN, hC, compName, isSingle, compositeNFPOptions );
hNew = createTargetWrapper( hN, hC, nfpNetwork, compName, isSingle, compositeNFPOptions );



lowerNFPSparseConstMultiply( hN, multiplyAddMap );
hNewC = elabNFPSparseConstMultiply( hN, hC, constMatrix, sharingFactor, earlyElaborate, multiplyAddMap, nfpCustomLatency, useRAM );
outSignals = scmMultiplyAndAdd( selOutSignalsRow, selOutSignalsCol, selOut, hN, inSignal, delayNum, earlyElaborate, multiplyAddMap, nfpCustomLatency, useRAM );
hNewC = scmGetSumOfElements( hN, hInSignals, hOutSignals, nfpOptions, earlyElaborate );




function doIt( hPir )

transformnfp.partAddShiftMultiplierSize( hPir.getNFPResolvedPartMulStrategy );

vNetworks = hPir.Networks;
multiplyAddMap = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );
for i = 1:length( vNetworks )
hN = vNetworks( i );
transformnfp.lowerNFPSparseConstMultiply( hN, multiplyAddMap );
end 

vNetworks = hPir.Networks;

targetCompMap = transformnfp.getTargetCompMap( true );

for i = 1:length( vNetworks )
hN = vNetworks( i );
transformnfp.lowerNetwork( hN, targetCompMap );
end 
end 

function lowerNetwork( hN, targetCompMap )
vComps = hN.Components;
for j = 1:length( vComps )
hC = vComps( j );
sigT = [  ];




if hC.isFirstInPortConnected
sigT = hC.PirInputSignals( 1 ).Type.getLeafType;
end 



if ~isempty( sigT ) && ~( sigT.isFloatType ) &&  ...
( hC.NumberOfPirOutputPorts > 0 )
sigT = hC.PirOutputSignals( 1 ).Type.getLeafType;
end 

if ~isempty( sigT ) && sigT.isFloatType
className = hC.ClassName;
switch className
case 'target_abs_comp'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_abs_comp', sigT.isSingleType );
case 'target_signum_comp'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_signum_comp', sigT.isSingleType );
case 'target_add_comp'
signs = hC.getInputSigns(  );
if strcmp( signs, '++' )
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_add_comp', sigT.isSingleType );
elseif strcmp( signs, '--' )
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_add2_comp', sigT.isSingleType );
elseif strcmp( signs, '+-' ) || strcmp( signs, '-+' )
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_sub_comp', sigT.isSingleType );
end 
case 'target_mul_comp'
signs = hC.getInputSigns(  );
if strcmp( signs, '**' )
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_mul_comp', sigT.isSingleType );
elseif strcmp( signs, '*/' )
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_div_comp', sigT.isSingleType );
end 
case 'target_relop_comp'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_relop_comp', sigT.isSingleType );
case 'target_rounding_comp'
op = hC.getOperatorMode;
switch op
case 'round'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_round_comp', sigT.isSingleType );
case 'ceil'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_ceil_comp', sigT.isSingleType );
case 'floor'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_floor_comp', sigT.isSingleType );
case 'fix'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_fix_comp', sigT.isSingleType );
end 
case 'target_sqrt_comp'
fcn = hC.getFunctionName;
switch fcn
case 'rSqrt'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_rsqrt_comp', sigT.isSingleType );
case 'sqrt'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_sqrt_comp', sigT.isSingleType );
end 
case 'target_math_comp'
fcn = hC.getFunctionName;
switch fcn
case 'exp'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_exp_comp', sigT.isSingleType );
case 'pow2'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_pow2_comp', sigT.isSingleType );
case '10^u'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_pow10_comp', sigT.isSingleType );
case 'log'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_log_comp', sigT.isSingleType );
case 'log2'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_log2_comp', sigT.isSingleType );
case 'log10'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_log10_comp', sigT.isSingleType );
case 'reciprocal'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_recip_comp', sigT.isSingleType );
end 
case 'target_hdlrecip_comp'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_hdlrecip_comp', sigT.isSingleType );
case 'target_math2_comp'
fcn = hC.getFunctionName;
switch fcn
case 'mod'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_mod_comp', sigT.isSingleType );
case 'rem'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_rem_comp', sigT.isSingleType );
case 'pow'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_pow_comp', sigT.isSingleType );
case 'hypot'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_hypot_comp', sigT.isSingleType );
end 
case 'target_minmax_comp'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_minmax_comp', sigT.isSingleType );
case 'target_trig_comp'
switch ( hC.getFunctionName )
case 'sin'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_sin_comp', sigT.isSingleType );
case 'cos'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_cos_comp', sigT.isSingleType );
case 'tan'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_tan_comp', sigT.isSingleType );
case 'atan'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_atan_comp', sigT.isSingleType );
case 'asin'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_asin_comp', sigT.isSingleType );
case 'acos'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_acos_comp', sigT.isSingleType );
case 'sinh'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_sinh_comp', sigT.isSingleType );
case 'cosh'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_cosh_comp', sigT.isSingleType );
case 'tanh'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_tanh_comp', sigT.isSingleType );
case 'asinh'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_asinh_comp', sigT.isSingleType );
case 'acosh'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_acosh_comp', sigT.isSingleType );
case 'atanh'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_atanh_comp', sigT.isSingleType );
end 
case 'target_trig2_comp'
switch ( hC.getFunctionName )
case 'sincos'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_sincos_comp', sigT.isSingleType );
end 
case 'target_trig3_comp'
switch ( hC.getFunctionName )
case 'atan2'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_atan2_comp', sigT.isSingleType );
end 
case 'target_uminus_comp'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_uminus_comp', sigT.isSingleType );
case 'target_conv_comp'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_conv_comp', sigT.isSingleType );
case 'target_gain_pow2_comp'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_gain_pow2_comp', sigT.isSingleType );
case 'nfpreinterpretcast_comp'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_cast_comp', sigT.isSingleType );
case 'target_scalarmac_comp'
transformnfp.transformNFPComp( hN, hC, targetCompMap,  ...
'nfp_fma_comp', sigT.isSingleType );
end 
end 
end 
end 

function transformNFPComp( hN, hC, targetCompMap, nfpComp, isSingleType )
hInSignals = hC.PirInputSignals;
dimlen = 1;

for i = 1:length( hInSignals )
if ( dimlen < 2 )
[ dimlen, ~ ] = pirelab.getVectorTypeInfo( hInSignals( i ) );
end 
end 
if dimlen > 1
hNewC = transformnfp.transformVectorComp( hN, hC, targetCompMap,  ...
nfpComp, isSingleType );
else 
hOutSignals = hC.PirOutputSignals;
compositeNFPOptions = {  };
hNewC = transformnfp.transformComplexComp( hN, hC, targetCompMap,  ...
nfpComp, hInSignals, hOutSignals, 1, isSingleType, compositeNFPOptions );
end 
hNewC.addComment( hC.getComment );
hN.removeComponent( hC );
end 

function hNewC = transformVectorComp( hN, hC, targetCompMap, nfpComp, isSingleType )
maxDimLen = 1;
hInSignals = hC.PirInputSignals;
hOutSignals = hC.PirOutputSignals;
for i = 1:length( hInSignals )
[ dimLen( i ), baseTypeIn( i ) ] = pirelab.getVectorTypeInfo( hInSignals( i ) );
if dimLen( i ) > maxDimLen
maxDimLen = dimLen( i );
end 
end 

for i = 1:length( hInSignals )
if ( dimLen( i ) ) == 1
for ii = 1:maxDimLen
hNewInSignals( i, ii ) = hInSignals( i );
end 
else 
for ii = 1:maxDimLen
hNewInSignals( i, ii ) = hN.addSignal( baseTypeIn( i ), sprintf( '%nfp_in_%d_%d', ii, i ) );
hNewInSignals( i, ii ).SimulinkRate = hInSignals( i ).SimulinkRate;
end 
end 
end 


for i = 1:length( hInSignals )
if dimLen( i ) > 1
hNewC = pirelab.getDemuxComp( hN, hInSignals( i ), hNewInSignals( i, : ) );
end 
end 


for i = 1:length( hOutSignals )
[ outputDimLen, baseTypeOut ] = pirelab.getVectorTypeInfo( hOutSignals( i ) );
for ii = 1:outputDimLen
hNewOutSignals( i, ii ) = hN.addSignal( baseTypeOut, sprintf( 'nfp_out_%d_%d', ii, i ) );
hNewOutSignals( i, ii ).SimulinkRate = hOutSignals( i ).SimulinkRate;
end 
end 

for i = 1:length( hOutSignals )
pirelab.getMuxComp( hN, hNewOutSignals( i, : ), hOutSignals( i ) );
end 


newcomps = hdlhandles( outputDimLen, 1 );
for ii = outputDimLen: - 1:1
newComps( ii ) = transformnfp.transformComplexComp( hN, hC, targetCompMap, nfpComp,  ...
hNewInSignals( :, ii ), hNewOutSignals( :, ii ), ii, isSingleType, {  } );
end 

end 


function hNewC = instantiateNetwork( hN, hC, targetCompMap, targetCompStr, hInSignals,  ...
hOutSignals, isSingle, compositeNFPOptions )
if nargin < 8




compositeNFPOptions = [  ];
end 

hasLatency = false;
hasDenormals = false;
hasMantissaMul = false;
hasModRem = false;
hasRangeReduction = false;
hasRadix = false;
switch targetCompStr



case { 'nfp_mul_comp', 'nfp_fma_comp' }
hasLatency = true;
hasDenormals = true;
hasMantissaMul = true;
case { 'nfp_add_comp', 'nfp_add2_comp', 'nfp_sub_comp',  ...
'nfp_asin_comp', 'nfp_acos_comp',  ...
'nfp_cosh_comp', 'nfp_sinh_comp', 'nfp_tanh_comp',  ...
'nfp_hypot_comp' }
hasLatency = true;
case { 'nfp_sqrt_comp', 'nfp_hdlrecip_comp' ...
, 'nfp_rsqrt_comp', 'nfp_log2_comp', 'nfp_exp_comp' ...
, 'nfp_log10_comp', 'nfp_pow2_comp', 'nfp_pow10_comp', 'nfp_pow_comp' }
hasLatency = true;
hasDenormals = true;
case { 'nfp_log_comp', 'nfp_atan2_comp' }
hasLatency = true;
hasDenormals = true;
case { 'nfp_div_comp', 'nfp_recip_comp' }
hasLatency = true;
hasDenormals = true;
hasRadix = true;
case { 'nfp_mod_comp', 'nfp_rem_comp' }
hasLatency = true;
hasDenormals = true;
hasModRem = true;
case { 'nfp_sin_comp', 'nfp_cos_comp', 'nfp_sincos_comp' }
hasLatency = true;
hasMantissaMul = true;
hasRangeReduction = true;
case { 'nfp_tan_comp' }
hasLatency = true;
hasRangeReduction = true;
case { 'nfp_round_comp', 'nfp_ceil_comp', 'nfp_floor_comp',  ...
'nfp_fix_comp', 'nfp_relop_comp', 'nfp_atan_comp' }
hasLatency = true;
case { 'nfp_asinh_comp', 'nfp_acosh_comp', 'nfp_atanh_comp' }
hasLatency = true;
hasMantissaMul = true;
otherwise 


end 



if isempty( compositeNFPOptions )


transformnfp.setNFPCompOptions( hC, hasLatency, hasDenormals, hasMantissaMul, hasModRem, hasRangeReduction, hasRadix );
elseif hC.getNFPLatency ~= 3



transformnfp.getLatencyStrategy( compositeNFPOptions.latencyStrategy );
transformnfp.setDelayValues;
end 


nfpOptStr = transformnfp.getNFPOptionKeyStr( hC, hasDenormals, hasMantissaMul, hasModRem, hasRangeReduction, hasRadix );

switch targetCompStr
case { 'nfp_hdlrecip_comp' }
nfpOptStr = [ nfpOptStr, num2str( hC.getIterNum ) ];
case { 'nfp_relop_comp' }
if ~isempty( compositeNFPOptions )
relopStr = compositeNFPOptions.opName;
else 
relopStr = hC.getOpName;
end 
nfpOptStr = [ relopStr, nfpOptStr ];
end 



if isHalfType( hC.PirInputSignals( 1 ).Type.BaseType )
strUniqueType = 'half';
elseif isSingleType( hC.PirInputSignals( 1 ).Type.BaseType )
strUniqueType = 'single';
else 
strUniqueType = 'double';
end 


targetCompKey = [ targetCompStr, nfpOptStr, strUniqueType ...
, num2str( hC.PirInputSignals( 1 ).SimulinkRate ) ];


if ~( transformnfp.getLatencyStrategy == 3 ||  ...
( transformnfp.getLatencyStrategy == 4 &&  ...
hC.getNFPCustomLatency(  ) == 0 ) )
targetCompKey = [ targetCompKey, '_', num2str( hN.isUsingTriggerAsClock ) ];
end 

if ~targetCompMap.isKey( targetCompKey )
[ nfpNetwork, customLatency ] = transformnfp.createNewNFPNetwork( hN, hC, targetCompStr,  ...
isSingle, compositeNFPOptions );

transformnfp.addSrcAndRptComment( nfpNetwork, hC, targetCompStr, hasLatency,  ...
hasDenormals, hasMantissaMul, customLatency, hasModRem, hasRangeReduction, hasRadix );
targetCompMap( targetCompKey ) = nfpNetwork;
else 
nfpNetwork = targetCompMap( targetCompKey );
end 

if strcmp( targetCompStr, 'nfp_relop_comp' )
[ hCInSignals, hCOutSignals ] = transformnfp.createRelopInstantiation( hN, hInSignals, hOutSignals );
elseif strcmp( targetCompStr, 'nfp_trig_comp' )
[ hCInSignals, hCOutSignals ] = transformnfp.createTrigometricInstantiation( hN, hC, hInSignals, hOutSignals );
elseif strcmp( targetCompStr, 'nfp_minmax_comp' )
[ hCInSignals, hCOutSignals ] = transformnfp.createMinMaxInstantiation( hN, hC, hInSignals, hOutSignals );
elseif strcmp( targetCompStr, 'nfp_sub_comp' )
if ~isempty( compositeNFPOptions )
hCInSignals = hInSignals;
hCOutSignals = hOutSignals;
else 
[ hCInSignals, hCOutSignals ] = transformnfp.createSubInstantiation( hN, hC, hInSignals, hOutSignals );
end 
else 
hCInSignals = hInSignals;
hCOutSignals = hOutSignals;
end 

hNewC = pirelab.instantiateNetwork( hN, nfpNetwork, hCInSignals, hCOutSignals, targetCompStr );


nfpNetwork.setNFPSource( transformnfp.getCompUniqName( hC, targetCompStr ) );
if isempty( compositeNFPOptions )
hNewC.copyTags( hC );
hNewC.OrigModelHandle = hC.SimulinkHandle;
end 
end 

function setNFPCompOptions( hC, hasLatency, hasDenormals, hasMantMul, isModRem, hasRangeReduction, hasRadix )
if nargin < 7
hasRadix = false;
end 

if nargin < 6
hasRangeReduction = false;
end 

if nargin < 5
isModRem = false;
end 

if nargin < 4
hasMantMul = false;
end 

if nargin < 3
hasDenormals = false;
end 

if nargin < 2
hasLatency = false;
end 

if hasLatency
lat = hC.getNFPLatency;
assert( lat ~= 0 );
transformnfp.getLatencyStrategy( lat );
else 
transformnfp.getLatencyStrategy( 1 );
end 

if hasDenormals
de = hC.getNFPDenormals;
if ( de == 0 )
sigT = hC.PirInputSignals( 1 ).Type;
if isHalfType( sigT.getLeafType )
de = 1;
else 
de = 2;
end 
end 
assert( de ~= 0 );
transformnfp.getHandleDenormal( de );
else 
transformnfp.getHandleDenormal( 1 );
end 

if hasMantMul
mms = hC.getNFPMantMul;
assert( mms ~= 0 );

transformnfp.mantissaMultiplyStrategy( mms );
else 
transformnfp.mantissaMultiplyStrategy( 1 );
end 

if isModRem
transformnfp.getModRemCheckResetToZero( hC.getNFPModRemCheckResetToZero );
transformnfp.getModRemMaxIterations( hC.getNFPModRemMaxIterations );
else 
transformnfp.getModRemCheckResetToZero( true );
transformnfp.getModRemMaxIterations( 32 );
end 

if hasRangeReduction
transformnfp.getTrigArgumentReduction( hC.getNFPArgReduction );
else 
transformnfp.getTrigArgumentReduction( true );
end 

if hasRadix
transformnfp.getRadix( hC.getNFPRadix );
else 
transformnfp.getRadix( 2 );
end 


transformnfp.setDelayValues;
end 

function keyStr = getNFPOptionKeyStr( hC, hasDenormals, hasMantMul, modrem, hasRangeReduction, hasRadix )
if nargin < 6
hasRadix = false;
end 

if nargin < 5
hasRangeReduction = false;
end 

if nargin < 4
modrem = false;
end 

if nargin < 3
hasMantMul = false;
end 

if nargin < 2
hasDenormals = false;
end 

switch transformnfp.getLatencyStrategy
case 1
keyStr = 'L1';
case 2
keyStr = 'L2';
case 3
keyStr = 'L0';
case 4
keyStr = 'L4';
keyStr = [ keyStr, num2str( hC.getNFPCustomLatency(  ) ) ];
otherwise 
assert( 0 );
end 

if hasDenormals
keyStr = [ keyStr, 'D', int2str( transformnfp.getHandleDenormal ) ];
end 

if hasMantMul
keyStr = [ keyStr, 'M', int2str( transformnfp.mantissaMultiplyStrategy ) ];
end 

if modrem
if transformnfp.getModRemCheckResetToZero
keyStr = [ keyStr, 'C1' ];
else 
keyStr = [ keyStr, 'C2' ];
end 

maxIterations = transformnfp.getModRemMaxIterations;
if ( maxIterations == 128 )
keyStr = [ keyStr, 'I128' ];
elseif ( maxIterations == 64 )
keyStr = [ keyStr, 'I64' ];
else 
keyStr = [ keyStr, 'I32' ];
end 
end 

if hasRadix
keyStr = [ keyStr, int2str( transformnfp.getRadix ) ];
end 

if hasRangeReduction
keyStr = [ keyStr, int2str( transformnfp.getTrigArgumentReduction ) ];
end 
end 

function addSrcAndRptComment( hN, hC, targetCompStr, hasLatency, hasDenormal,  ...
printMantissaMultiply, customLatency, modrem, hasArgReduction, hasRadix )
if ( nargin < 10 )
hasRadix = false;
end 
if ( nargin < 9 )
hasArgReduction = false;
end 
if ( nargin < 8 )
modrem = false;
end 
if ( nargin < 7 )
customLatency =  - 1;
end 

if ~hasLatency
return 
end 

srcComment = '{Latency Strategy = ';
rptComment = '(Latency = ';
if customLatency >  - 1
latStr = [ '"Custom = (', num2str( customLatency ), ')"' ];
else 
switch transformnfp.getLatencyStrategy
case 1
latStr = '"Max"';
case 2
latStr = '"Min"';
case 3
latStr = '"Zero"';
case 4
latStr = [ '"Custom = (', num2str( hC.getNFPCustomLatency(  ) ), ')"' ];
otherwise 
error( 'Component latency property still set to inherit' );
end 
end 
srcComment = [ srcComment, latStr ];
rptComment = [ rptComment, latStr ];

if hasDenormal
srcComment = [ srcComment, ', Denormal Handling = ' ];
rptComment = [ rptComment, ', Denormal = ' ];
switch transformnfp.getHandleDenormal
case 1
deStr = '"on"';
case 2
deStr = '"off"';
otherwise 
error( 'Component handles denormals property still set to inherit' );
end 
srcComment = [ srcComment, deStr ];
rptComment = [ rptComment, deStr ];
end 

srcComment = [ srcComment, '}' ];

if printMantissaMultiply
switch transformnfp.mantissaMultiplyStrategy
case 1
mantissaMultiplyStrategyStr = 'FullMultiplier';
case 2
mantissaMultiplyStrategyStr = 'PartMultiplierPartAddShift';
case 3
mantissaMultiplyStrategyStr = 'NoMultiplierFullAddShift';
otherwise 
error( 'Component mantissa mul property still set to inherit' );
end 

if contains( targetCompStr, 'sin' ) || contains( targetCompStr, 'cos' )
if ( transformnfp.mantissaMultiplyStrategy ~= 2 ) || ( transformnfp.partAddShiftMultiplierSize == 3 )
mantissaMultiplyStrategyStr = 'FullMultiplier';
end 
end 
srcComment = [ srcComment, newline, '{Mantissa Multiply Strategy = "' ...
, mantissaMultiplyStrategyStr, '"}' ];
rptComment = [ rptComment, ', Mantissa Multiply = "' ...
, mantissaMultiplyStrategyStr, '"' ];

if transformnfp.mantissaMultiplyStrategy == 2
if ~( contains( targetCompStr, 'sin' ) || contains( targetCompStr, 'cos' ) )
switch transformnfp.partAddShiftMultiplierSize
case 1
partAddShiftMultiplierSizeStr = '18x24';
case 2
partAddShiftMultiplierSizeStr = '18x18';
case 3
partAddShiftMultiplierSizeStr = '17x17';
otherwise 
error( 'Unknown value for part add shift multiplier size' );
end 
srcComment = [ srcComment, newline, '{Part Add Shift Multiplier Size = "' ...
, partAddShiftMultiplierSizeStr, '"}' ];
rptComment = [ rptComment, ', Part Add Shift Multiplier Size = "' ...
, partAddShiftMultiplierSizeStr, '"' ];
else 
partAddShiftMultiplierSizeStr = '18x24';
if transformnfp.partAddShiftMultiplierSize ~= 3
srcComment = [ srcComment, newline, '{Part Add Shift Multiplier Size = "' ...
, partAddShiftMultiplierSizeStr, '"}' ];
rptComment = [ rptComment, ', Part Add Shift Multiplier Size = "' ...
, partAddShiftMultiplierSizeStr, '"' ];
end 
end 
end 
end 

if modrem
if transformnfp.getModRemCheckResetToZero
checkResetToZeroStr = 'on';
else 
checkResetToZeroStr = 'off';
end 

maxIterationsStr = int2str( transformnfp.getModRemMaxIterations );

srcComment = [ srcComment, newline, '{CheckResetToZero = "' ...
, checkResetToZeroStr, '"}', newline ...
, '{MaxIterations = "', maxIterationsStr, '"}' ];
rptComment = [ rptComment, ', CheckResetToZero = "' ...
, checkResetToZeroStr, '", MaxIterations = "' ...
, maxIterationsStr, '"' ];
end 

if hasArgReduction
if transformnfp.getTrigArgumentReduction
argumentReductionStr = 'on';
else 
argumentReductionStr = 'off';
end 

srcComment = [ srcComment, newline, '{Input Range Reduction = "', argumentReductionStr, '"}' ];
rptComment = [ rptComment, ', Input Range Reduction = "', argumentReductionStr, '"' ];
end 

if ( hasRadix )
radixStr = int2str( transformnfp.getRadix );

srcComment = [ srcComment, newline, '{Radix = "', radixStr, '"}' ];
rptComment = [ rptComment, ', Radix = "', radixStr, '"' ];
end 


rptComment = [ rptComment, ')' ];

hN.addComment( srcComment );
hN.setNFPReportComment( rptComment );
end 

function flattenNFPHelper( hNtwk )
hNtwk.setFlattenHierarchy( 'on' );
vComps = hNtwk.Components;
for jj = 1:length( vComps )
hC = vComps( jj );
if isa( hC, 'hdlcoder.ntwk_instance_comp' )
hC.flatten( true );
transformnfp.flattenNFPHelper( hC.ReferenceNetwork );
end 
end 
hNtwk.flatten( true );
hNtwk.flattenHierarchy(  );
end 

function [ hNew, customLatency ] = createNewNFPNetwork( hN, hC, compName, isSingle, compositeNFPOptions )
[ nfpNetwork, customLatency ] = transformnfp.addNfpNetwork( hN, hC, compName, isSingle, compositeNFPOptions );
hNew = transformnfp.createTargetWrapper( hN, hC, nfpNetwork, compName, isSingle, compositeNFPOptions );
if ~contains( [ 'nfp_asinh_comp', 'nfp_acosh_comp', 'nfp_atanh_comp' ], compName )
transformnfp.flattenNFPHelper( hNew );
end 
end 



function [ hInSigs, hOutSig ] = createRelopInstantiation( hN, hInSignals, hOutSignal )
hInSigs = hInSignals;
outType = pir_ufixpt_t( 1, 0 );
destType = hOutSignal.Type;


if ~( destType.isBooleanType || destType.isEqual( outType ) )
outSig = hN.addSignal( outType, hOutSignal.Name );
outSig.SimulinkHandle =  - 1;
outSig.SimulinkRate = hOutSignal.SimulinkRate;
driverPort = hOutSignal.getDrivers;



if ( ~isempty( driverPort ) )
hOutSignal.disconnectDriver( driverPort );
outSig.addDriver( driverPort );
end 
pirelab.getDTCComp( hN, outSig, hOutSignal, 'Nearest', 'Saturate' );
hOutSig = outSig;
else 
hOutSig = hOutSignal;
end 
end 

function [ hInSigs, hOutSigs ] = createTrigometricInstantiation( hN, hC, hInSignals, hOutSignals )
hInSigs = hInSignals;
dummySignal = hN.addSignal;
dummySignal.Name = 'term';
dummySignal.Type = hOutSignals( 1 ).Type;
dummySignal.SimulinkHandle = 0;
dummySignal.SimulinkRate = hOutSignals( 1 ).SimulinkRate;
hOutSigs = [  ];
switch ( hC.getFunctionName )
case 'sin'
hOutSigs = [ hOutSignals, dummySignal ];
case 'cos'
hOutSigs = [ dummySignal, hOutSignals ];
case 'sincos'
hOutSigs = hOutSignals;
otherwise 
assert( true );
end 
end 

function [ hInSigs, hOutSigs ] = createMinMaxInstantiation( hN, hC, hInSignals, hOutSignals )
hInSigs = hInSignals;
dummySignal = hN.addSignal;
dummySignal.Name = 'term';
dummySignal.Type = hOutSignals( 1 ).Type;
dummySignal.SimulinkHandle = 0;
dummySignal.SimulinkRate = hOutSignals( 1 ).SimulinkRate;
hOutSigs = [  ];
switch ( hC.getOpName )
case 'max'
hOutSigs = [ hOutSignals, dummySignal ];
case 'min'
hOutSigs = [ dummySignal, hOutSignals ];
otherwise 
assert( true );
end 
end 


function [ hInSigs, hOutSigs ] = createSubInstantiation( ~, hC, hInSignals, hOutSignals )
hInSigs = hInSignals;
hOutSigs = hOutSignals;
signs = hC.getInputSigns(  );
if strcmp( signs, '-+' )
hInSigs = hInSignals( end : - 1:1 );
end 
end 

function compuniqname = getCompUniqName( hC, targetCompStr )%#ok<INUSL>
compuniqname = lower( targetCompStr );
end 



function hNewC = instantiateWireComp( hN, hC, targetCompMap, hInSignals,  ...
hOutSignals, isSingleType )

outType = hOutSignals.Type;
inType = hInSignals.Type;

isHalfType = inType.isHalfType || outType.isHalfType;
if ( isHalfType )
dtcSigType = pir_ufixpt_t( 16, 0 );
dtcstr = 'h';
elseif isSingleType
dtcSigType = pir_ufixpt_t( 32, 0 );
dtcstr = 's';
else 
dtcSigType = pir_ufixpt_t( 64, 0 );
dtcstr = 'd';
end 
if ( outType.isFloatType )
toFixed = '0';
else 
toFixed = '1';
end 
slRate = num2str( hInSignals.SimulinkRate );
targetCompKey = [ 'nfp_wire_', dtcstr, '_', toFixed, '_', slRate ];
if ~targetCompMap.isKey( targetCompKey )
assert( hC.NumberOfPirInputPorts == 1 );
assert( hC.NumberOfPirOutputPorts == 1 );
hInportNames = cell( 1, 1 );
hInportNames{ 1 } = 'nfp_in';
hInportRates = hInSignals.SimulinkRate;
hCInputPorts = hC.PirInputPorts;
hInportKinds = cell( 1, 1 );
hInportKinds{ 1 } = hCInputPorts.Kind;
hOutportNames = cell( 1, 1 );
hOutportNames{ 1 } = 'nfp_out';
hOutportTypes( 1 ) = dtcSigType;
hInportTypes( 1 ) = dtcSigType;


nfpWireCompName = 'nfp_wire';
if ( isSingleType )
networkName = [ nfpWireCompName, '_single' ];
elseif ( isHalfType )
networkName = [ nfpWireCompName, '_half' ];
else 
networkName = [ nfpWireCompName, '_double' ];
end 

nfpNetwork = pirelab.createNewNetwork(  ...
'Network', hN,  ...
'Name', networkName,  ...
'InportNames', hInportNames,  ...
'InportTypes', hInportTypes,  ...
'InportRates', hInportRates,  ...
'InportKinds', hInportKinds,  ...
'OutportNames', hOutportNames,  ...
'OutportTypes', hOutportTypes );
nfpNetwork.Name = networkName;
hTopOutSigs = nfpNetwork.PirOutputSignals;
hTopOutSigs.SimulinkRate = hOutSignals.SimulinkRate;
hTopInSigs = nfpNetwork.PirInputSignals;
pirelab.getWireComp( nfpNetwork, hTopInSigs, hTopOutSigs );
targetCompMap( targetCompKey ) = nfpNetwork;
else 
nfpNetwork = targetCompMap( targetCompKey );
end 
hNewC = pirelab.instantiateNetwork( hN, nfpNetwork, hInSignals, hOutSignals, nfpNetwork.Name );
nfpNetwork.setNFPSource( transformnfp.getCompUniqName( hC, targetCompKey ) );
hNewC.copyTags( hC );
hNewC.OrigModelHandle = hC.SimulinkHandle;
end 

function hNewC = instantiateGainPow2Comp( hN, hC, targetCompMap, hInSignal, hOutSignal,  ...
idx, isRealFactor, isSingle )
slRate = hInSignal.SimulinkRate;

gainVal = hC.getGainValue;
if ( numel( gainVal ) > 1 )
gainVal = gainVal( idx );
end 

assert( hdlispowerof2( gainVal ) );
pirTyp1 = pir_ufixpt_t( 1, 0 );
nt1 = numerictype( 0, 1, 0 );
fiMath1 = fimath( 'RoundingMethod', 'Nearest', 'OverflowAction', 'Saturate', 'ProductMode', 'FullPrecision', 'SumMode', 'FullPrecision' );
signConst = transformnfp.addSignal( hN, 'pw2_sign_const', pirTyp1, slRate );
sign = 0;




if imag( gainVal ) ~= 0 && real( gainVal ) == 0
gainVal = imag( gainVal );
if isRealFactor
gainVal =  - gainVal;
end 
end 

if gainVal < 0
sign = 1;
end 
pirelab.getConstComp( hN, signConst, fi( sign, nt1, fiMath1 ), 'Constant1', 'on', 0, '', '', '' );

shiftVal = log2( abs( gainVal ) );
if ( hInSignal.Type.isHalfType )
pirTyp2 = pir_sfixpt_t( 6, 0 );
nt2 = numerictype( 1, 6, 0 );
elseif ( hInSignal.Type.isDoubleType )
pirTyp2 = pir_sfixpt_t( 12, 0 );
nt2 = numerictype( 1, 12, 0 );
else 
pirTyp2 = pir_sfixpt_t( 9, 0 );
nt2 = numerictype( 1, 9, 0 );
end 
shiftConst = transformnfp.addSignal( hN, 'pw2_shift_const', pirTyp2, slRate );
pirelab.getConstComp( hN, shiftConst, fi( shiftVal, nt2, fiMath1 ), 'Constant1', 'on', 0, '', '', '' );

[ N_slRate, D_slRate ] = rat( slRate );
hasLatency = true;
hasDenormals = true;
hasMantissaMul = false;
transformnfp.setNFPCompOptions( hC, hasLatency, hasDenormals, hasMantissaMul );
nfpOptStr = transformnfp.getNFPOptionKeyStr( hC, hasDenormals, hasMantissaMul );
targetCompKey = sprintf( 'nfp_gain_pow2_%d_rate_%s_%d/%d', isSingle, nfpOptStr, N_slRate, D_slRate );
if ~targetCompMap.isKey( targetCompKey )
[ latency, customLatency ] = transformnfp.getLatencyFromNfpComp( hC, 'GainPow2', hOutSignal( 1 ).Type.getLeafType );
isHalf = isHalfType( hInSignal.Type.BaseType );
hNew = transformnfp.addNfpGainPow2Comp( hN, latency, slRate, isSingle, isHalf );
nfpNetwork = transformnfp.createGainPow2NFPWrapper( hN, hC, hNew, [ signConst, shiftConst ], isSingle );

targetCompMap( targetCompKey ) = nfpNetwork;
transformnfp.addSrcAndRptComment( nfpNetwork, hC, 'nfp_gain_pow2', hasLatency, hasDenormals, hasMantissaMul, customLatency );
transformnfp.flattenNFPHelper( nfpNetwork );
else 
nfpNetwork = targetCompMap( targetCompKey );
end 
hNewC = pirelab.instantiateNetwork( hN, nfpNetwork, [ hInSignal, signConst, shiftConst ], hOutSignal, nfpNetwork.Name );
nfpNetwork.setNFPSource( transformnfp.getCompUniqName( hC, targetCompKey ) );
hNewC.copyTags( hC );
hNewC.OrigModelHandle = hC.SimulinkHandle;
end 

function hTopNwk = createGainPow2NFPWrapper( hN, hC, hNew, hFixptInputs, isSingle )
hTopNwk = transformnfp.createGainPow2NFPTopWrapper( hN, hC, 'nfp_gain_pow2_comp', hFixptInputs, isSingle );
hInSignals = hTopNwk.PirInputSignals;
hOutSignals = hTopNwk.PirOutputSignals;
isHalf = isHalfType( hC.PirInputSignals( 1 ).Type.BaseType );
if isHalf
dtcSigType = pir_ufixpt_t( 16, 0 );
elseif isSingle
dtcSigType = pir_ufixpt_t( 32, 0 );
else 
dtcSigType = pir_ufixpt_t( 64, 0 );
end 

nfpInSigs = hNew.PirInputSignals;
unpackSigs = [  ];
for ii = 1:3
compSig = nfpInSigs( ii );
sig = transformnfp.addSignal( hTopNwk, compSig.Name, compSig.Type, compSig.SimulinkRate );
unpackSigs = [ unpackSigs, sig ];
end 
dtcSigName = [ hInSignals( 1 ).Name, '_unpack' ];
dtcSig = transformnfp.addSignal( hTopNwk, dtcSigName, dtcSigType, hInSignals( 1 ).SimulinkRate );
pirelab.getDTCComp( hTopNwk, hInSignals( 1 ), dtcSig );

if isHalf
transformnfp.getHalfUnpackComp( hTopNwk, dtcSig,  ...
unpackSigs, 'add_unpack' );
elseif isSingle
transformnfp.getSingleUnpackComp( hTopNwk, dtcSig,  ...
unpackSigs, 'add_unpack' );
else 
transformnfp.getDoubleUnpackComp( hTopNwk, dtcSig,  ...
unpackSigs, 'add_unpack' );
end 

nfpOutSigs = hNew.PirOutputSignals;
packSigs = [  ];
for ii = 1:numel( nfpOutSigs )
compSig = nfpOutSigs( ii );
sig = transformnfp.addSignal( hTopNwk, compSig.Name,  ...
compSig.Type, compSig.SimulinkRate );
packSigs = [ packSigs, sig ];
end 
dtcSigName = [ hOutSignals( 1 ).Name, '_pack' ];
dtcSig = transformnfp.addSignal( hTopNwk, dtcSigName,  ...
dtcSigType, hOutSignals( 1 ).SimulinkRate );
pirelab.getDTCComp( hTopNwk, dtcSig, hOutSignals( 1 ) );

if isHalf
transformnfp.getHalfPackComp( hTopNwk, packSigs,  ...
dtcSig, 'add_pack' );
elseif isSingle
transformnfp.getSinglePackComp( hTopNwk, packSigs,  ...
dtcSig, 'add_pack' );
else 
transformnfp.getDoublePackComp( hTopNwk, packSigs,  ...
dtcSig, 'add_pack' );
end 
pirelab.instantiateNetwork( hTopNwk, hNew, [ unpackSigs, hInSignals( 2 ), hInSignals( 3 ) ],  ...
packSigs, [ 'u_', hNew.Name ] );

end 

function hTopWrapper = createGainPow2NFPTopWrapper( hN, hC, compName, hFixptInputs, isSingle )
hInSignals = hC.PirInputSignals;
hOutSignals = hC.PirOutputSignals;
assert( hC.NumberOfPirInputPorts == 1 );
assert( hC.NumberOfPirOutputPorts == 1 );

hInportNames = cell( 3, 1 );
hInportNames{ 1 } = 'nfp_in1';
hInportNames{ 2 } = 'nfp_in2';
hInportNames{ 3 } = 'nfp_in3';

hInportTypes = hdlhandles( 3, 1 );
hInportTypes( 1 ) = hInSignals( 1 ).Type;
hInportTypes( 2 ) = hFixptInputs( 1 ).Type;
hInportTypes( 3 ) = hFixptInputs( 2 ).Type;

hInportRates = zeros( 3, 1 );
hInportKinds = cell( 3, 1 );
hCInputPorts = hC.PirInputPorts;
for ii = 1:3
hInportRates( ii ) = hInSignals( 1 ).SimulinkRate;
hInportKinds{ ii } = hCInputPorts( 1 ).Kind;
end 

hOutportNames = cell( 1, 1 );
hOutportNames{ 1 } = 'nfp_out';
hOutportTypes = hdlhandles( 1, 1 );
hOutportTypes( 1 ) = hOutSignals( 1 ).Type;
isHalf = isHalfType( hInSignals( 1 ).Type.BaseType );
if isHalf
hOutportTypes( 1 ) = pir_ufixpt_t( 16, 0 );
hInportTypes( 1 ) = pir_ufixpt_t( 16, 0 );
elseif isSingle
hOutportTypes( 1 ) = pir_ufixpt_t( 32, 0 );
hInportTypes( 1 ) = pir_ufixpt_t( 32, 0 );
else 
hOutportTypes( 1 ) = pir_ufixpt_t( 64, 0 );
hInportTypes( 1 ) = pir_ufixpt_t( 64, 0 );
end 

if hC.NumberOfPirInputPorts > 0
sigT = hC.PirInputSignals( 1 ).Type.getLeafType;
end 
if ( ~isempty( sigT ) )
isHalf = sigT.isHalfType;
else 
isHalf = false;
end 


nfpGainPow2CompName = extractBefore( compName, '_comp' );
if ( isSingle )
networkName = [ nfpGainPow2CompName, '_single' ];
elseif ( isHalf )
networkName = [ nfpGainPow2CompName, '_half' ];
else 
networkName = [ nfpGainPow2CompName, '_double' ];
end 

hTopWrapper = pirelab.createNewNetwork(  ...
'Network', hN,  ...
'Name', networkName,  ...
'InportNames', hInportNames,  ...
'InportTypes', hInportTypes,  ...
'InportRates', hInportRates,  ...
'InportKinds', hInportKinds,  ...
'OutportNames', hOutportNames,  ...
'OutportTypes', hOutportTypes );
hTopWrapper.Name = networkName;
hTopOutSigs = hTopWrapper.PirOutputSignals;
hTopOutSigs( 1 ).SimulinkRate = hOutSignals( 1 ).SimulinkRate;
end 

function hNewC = instantiateDTC( hN, hC, targetCompMap, hInSignals, hOutSignals, isSingle )
inSigT = hInSignals( 1 ).Type;
outSigT = hOutSignals( 1 ).Type;

slRate = hInSignals( 1 ).SimulinkRate;

float2Fixed = 1;

hasLatency = true;
hasDenormals = false;
hasMantissaMul = false;
transformnfp.setNFPCompOptions( hC, hasLatency, hasDenormals, hasMantissaMul );

if ( inSigT.isFloatType )
if ( outSigT.isFloatType )
nfpOptStr = transformnfp.getNFPOptionKeyStr( hC, hasDenormals, hasMantissaMul );
denormal = transformnfp.handleDenormal;

if ( ( inSigT.isSingleType ) && ( outSigT.isHalfType ) )
slTypeKey = 'single2half';
targetCompKey = [ 'nfp_conv_', slTypeKey, num2str( slRate ), nfpOptStr ];

if ~targetCompMap.isKey( targetCompKey )
hNew = transformnfp.getConvertSingle2HalfComp( hN, slRate, denormal );

nfpNetwork = transformnfp.createDTCNFPWrapper( hN, hC, hNew, hInSignals, hOutSignals, 'single', 'half' );

targetCompMap( targetCompKey ) = nfpNetwork;%#ok<*NASGU>
transformnfp.addSrcAndRptComment( nfpNetwork, hC, 'nfp_conv', hasLatency, hasDenormals, hasMantissaMul );
transformnfp.flattenNFPHelper( nfpNetwork );
else 
nfpNetwork = targetCompMap( targetCompKey );
end 
elseif ( ( inSigT.isHalfType ) && ( outSigT.isSingleType ) )
slTypeKey = 'half2single';
targetCompKey = [ 'nfp_conv_', slTypeKey, num2str( slRate ), nfpOptStr ];

if ~targetCompMap.isKey( targetCompKey )
hNew = transformnfp.getConvertHalf2SingleComp( hN, slRate, denormal );

nfpNetwork = transformnfp.createDTCNFPWrapper( hN, hC, hNew, hInSignals, hOutSignals, 'half', 'single' );

targetCompMap( targetCompKey ) = nfpNetwork;%#ok<*NASGU>
transformnfp.addSrcAndRptComment( nfpNetwork, hC, 'nfp_conv', hasLatency, hasDenormals, hasMantissaMul );
transformnfp.flattenNFPHelper( nfpNetwork );
else 
nfpNetwork = targetCompMap( targetCompKey );
end 
elseif ( ( inSigT.isDoubleType ) && ( outSigT.isSingleType ) )
slTypeKey = 'double2single';
targetCompKey = [ 'nfp_conv_', slTypeKey, num2str( slRate ), nfpOptStr ];

if ~targetCompMap.isKey( targetCompKey )
[ latency, customLatency ] = transformnfp.getLatencyFromNfpComp( hC, 'Convert',  ...
inSigT.getLeafType, outSigT.getLeafType );
hNew = transformnfp.getConvertDouble2SingleComp( hN, latency, slRate );
nfpNetwork = transformnfp.createDTCNFPWrapper( hN, hC, hNew, hInSignals, hOutSignals, 'double', 'single' );

targetCompMap( targetCompKey ) = nfpNetwork;%#ok<*NASGU>
transformnfp.addSrcAndRptComment( nfpNetwork, hC, 'nfp_conv', hasLatency, hasDenormals, hasMantissaMul, customLatency );
transformnfp.flattenNFPHelper( nfpNetwork );
else 
nfpNetwork = targetCompMap( targetCompKey );
end 
elseif ( ( inSigT.isSingleType ) && ( outSigT.isDoubleType ) )
slTypeKey = 'single2double';
targetCompKey = [ 'nfp_conv_', slTypeKey, num2str( slRate ), nfpOptStr ];

if ~targetCompMap.isKey( targetCompKey )
[ latency, customLatency ] = transformnfp.getLatencyFromNfpComp( hC, 'Convert',  ...
inSigT.getLeafType, outSigT.getLeafType );
hNew = transformnfp.getConvertSingle2DoubleComp( hN, latency, slRate );
nfpNetwork = transformnfp.createDTCNFPWrapper( hN, hC, hNew, hInSignals, hOutSignals, 'single', 'double' );

targetCompMap( targetCompKey ) = nfpNetwork;%#ok<*NASGU>
transformnfp.addSrcAndRptComment( nfpNetwork, hC, 'nfp_conv', hasLatency, hasDenormals, hasMantissaMul, customLatency );
transformnfp.flattenNFPHelper( nfpNetwork );
else 
nfpNetwork = targetCompMap( targetCompKey );
end 

else 
hNewC = pirelab.getWireComp( hN, hInSignals, hOutSignals );
return ;
end 

hNewC = pirelab.instantiateNetwork( hN, nfpNetwork, hInSignals, hOutSignals, nfpNetwork.Name );
nfpNetwork.setNFPSource( transformnfp.getCompUniqName( hC, targetCompKey ) );
hNewC.copyTags( hC );
hNewC.OrigModelHandle = hC.SimulinkHandle;

return ;
else 
sigT = outSigT;
end 
else 
if ( outSigT.isFloatType )
float2Fixed = 0;
sigT = inSigT;
end 
end 



inputSig = hInSignals;
outputSig = hOutSignals;
WL = sigT.WordLength;
FL = sigT.FractionLength;
SL = sigT.Signed;
flGtZero = false;


if ( FL > 0 ) || ( abs( FL ) >= WL )
if FL < 0
newWL = abs( FL ) + 1;
else 
newWL = WL + abs( FL ) + 3 + 23;
FL =  - 23;
flGtZero = true;
end 

if flGtZero && float2Fixed
dtcWL = newWL + 1;
else 
dtcWL = newWL;
end 
dtcTyp = pir_sfixpt_t( dtcWL, FL );
dtcSig = hN.addSignal( dtcTyp, outputSig.Name );
dtcSig.SimulinkHandle =  - 1;
dtcSig.SimulinkRate = outputSig.SimulinkRate;
if float2Fixed
rndMode = hC.getRoundingMode;

if strcmpi( rndMode, 'Simplest' )
rndMode = 'Zero';
end 
satMode = hC.getOverflowMode;
pirelab.getDTCComp( hN, dtcSig, outputSig, rndMode, satMode );
outputSig = dtcSig;
else 
pirelab.getDTCComp( hN, inputSig, dtcSig, 'Nearest', 'Saturate' );
inputSig = dtcSig;
end 
WL = newWL;
SL = 1;
end 

FL = abs( FL );
nfpOptStr = transformnfp.getNFPOptionKeyStr( hC, hasDenormals, hasMantissaMul );
slTypeKey = [ int2str( SL ), 'fix', int2str( WL ), '_E', int2str( FL ) ];
if float2Fixed
rndMode = hC.getRoundingMode;

if strcmpi( rndMode, 'Simplest' )
rndMode = 'Zero';
end 
satMode = hC.getOverflowMode;
else 
rndMode = '0';
satMode = '0';
end 
targetCompKey = [ 'nfp_conv_', int2str( isSingle ), int2str( float2Fixed ) ...
, '_', slTypeKey, num2str( slRate ), rndMode, satMode, nfpOptStr ];
if ~targetCompMap.isKey( targetCompKey )
if SL
UWL = WL - 1;
else 
UWL = WL;
end 
customLatency =  - 1;
if float2Fixed



[ latency, customLatency ] = transformnfp.getLatencyFromNfpComp( hC, 'Convert',  ...
inSigT.getLeafType, outSigT.getLeafType );
isHalf = isHalfType( inSigT.getLeafType );
hNew = transformnfp.addNfpFloat2Fixed( hN, latency, slRate, WL, UWL, FL,  ...
rndMode, satMode, flGtZero, isSingle, isHalf );

if isSingleType( inputSig.Type.BaseType )
inFloat = 'single';
elseif isDoubleType( inputSig.Type.BaseType )
inFloat = 'double';
elseif isHalfType( inputSig.Type.BaseType )
inFloat = 'half';
end 
outFloat = 'none';
else 
[ latency, customLatency ] = transformnfp.getLatencyFromNfpComp( hC, 'Convert',  ...
inSigT.getLeafType, outSigT.getLeafType );
isHalf = isHalfType( outSigT.getLeafType );
hNew = transformnfp.addNfpFixed2Float( hN, latency, slRate, WL, UWL, FL, isSingle, isHalf );
inFloat = 'none';

if isSingleType( outSigT.getLeafType )
outFloat = 'single';
elseif isHalfType( outSigT.getLeafType )
outFloat = 'half';
else 
outFloat = 'double';
end 
end 
nfpNetwork = transformnfp.createDTCNFPWrapper( hN, hC, hNew, inputSig, outputSig, inFloat, outFloat );

targetCompMap( targetCompKey ) = nfpNetwork;%#ok<*NASGU>
transformnfp.addSrcAndRptComment( nfpNetwork, hC, 'nfp_conv', hasLatency, hasDenormals, hasMantissaMul, customLatency );
if float2Fixed
moreComments = [ '{Rounding Mode = ', rndMode, '}', newline ];
moreComments = [ moreComments, '{Overflow Mode = ', satMode, '}', newline ];
nfpNetwork.addComment( moreComments );
end 
transformnfp.flattenNFPHelper( nfpNetwork );
else 
nfpNetwork = targetCompMap( targetCompKey );
end 
hNewC = pirelab.instantiateNetwork( hN, nfpNetwork, inputSig, outputSig, nfpNetwork.Name );
nfpNetwork.setNFPSource( transformnfp.getCompUniqName( hC, targetCompKey ) );
hNewC.copyTags( hC );
hNewC.OrigModelHandle = hC.SimulinkHandle;
end 

function hTopNwk = createDTCNFPWrapper( hN, hC, hNew, hInSig, hOutSig, inFloat, outFloat )
hTopNwk = transformnfp.createDTCTopWrapper( hN, hC, hNew, hInSig, hOutSig, inFloat, outFloat );
hInSignals = hTopNwk.PirInputSignals;
hOutSignals = hTopNwk.PirOutputSignals;

if strcmp( inFloat, 'none' )
unpackSigs = hInSignals;
else 
switch inFloat
case 'half'
dtcInSigType = pir_ufixpt_t( 16, 0 );
case 'single'
dtcInSigType = pir_ufixpt_t( 32, 0 );
case 'double'
dtcInSigType = pir_ufixpt_t( 64, 0 );
otherwise 
assert( 0 );
end 

nfpInSigs = hNew.PirInputSignals;
unpackSigs = [  ];
for ii = 1:numel( nfpInSigs )
compSig = nfpInSigs( ii );
sig = transformnfp.addSignal( hTopNwk, compSig.Name,  ...
compSig.Type, compSig.SimulinkRate );
unpackSigs = [ unpackSigs, sig ];%#ok<*AGROW>
end 
dtcSigName = [ hInSignals( 1 ).Name, '_unpack' ];
dtcSig = transformnfp.addSignal( hTopNwk, dtcSigName,  ...
dtcInSigType, hInSignals( 1 ).SimulinkRate );
pirelab.getDTCComp( hTopNwk, hInSignals( 1 ), dtcSig );

switch inFloat
case 'half'
transformnfp.getHalfUnpackComp( hTopNwk, dtcSig,  ...
unpackSigs, 'add_unpack' );
case 'single'
transformnfp.getSingleUnpackComp( hTopNwk, dtcSig,  ...
unpackSigs, 'add_unpack' );
case 'double'
transformnfp.getDoubleUnpackComp( hTopNwk, dtcSig,  ...
unpackSigs, 'add_unpack' );
otherwise 
assert( 0 );
end 
end 

if strcmp( outFloat, 'none' )
packSigs = hOutSignals;
else 
switch outFloat
case 'half'
dtcOutSigType = pir_ufixpt_t( 16, 0 );
case 'single'
dtcOutSigType = pir_ufixpt_t( 32, 0 );
case 'double'
dtcOutSigType = pir_ufixpt_t( 64, 0 );
otherwise 
assert( 0 );
end 

nfpOutSigs = hNew.PirOutputSignals;
packSigs = [  ];
for ii = 1:numel( nfpOutSigs )
compSig = nfpOutSigs( ii );
sig = transformnfp.addSignal( hTopNwk, compSig.Name,  ...
compSig.Type, compSig.SimulinkRate );
packSigs = [ packSigs, sig ];
end 
dtcSigName = [ hOutSignals( 1 ).Name, '_pack' ];
dtcSig = transformnfp.addSignal( hTopNwk, dtcSigName,  ...
dtcOutSigType, hOutSignals( 1 ).SimulinkRate );
pirelab.getDTCComp( hTopNwk, dtcSig, hOutSignals( 1 ) );

switch outFloat
case 'half'
transformnfp.getHalfPackComp( hTopNwk, packSigs,  ...
dtcSig, 'add_pack' );
case 'single'
transformnfp.getSinglePackComp( hTopNwk, packSigs,  ...
dtcSig, 'add_pack' );
case 'double'
transformnfp.getDoublePackComp( hTopNwk, packSigs,  ...
dtcSig, 'add_pack' );
otherwise 
assert( 0 );
end 
end 

pirelab.instantiateNetwork( hTopNwk, hNew, unpackSigs,  ...
packSigs, [ 'u_', hNew.Name ] );
end 

function hTopWrapper = createDTCTopWrapper( hN, hC, hNew, hInSignals,  ...
hOutSignals, inFloat, outFloat )
compName = hNew.Name;
assert( hC.NumberOfPirInputPorts == 1 );
assert( hC.NumberOfPirOutputPorts == 1 );

hInportNames = cell( 1, 1 );
hInportNames{ 1 } = 'nfp_in';
hInportTypes = hdlhandles( 1, 1 );
switch ( inFloat )
case 'half'
hInportTypes( 1 ) = pir_ufixpt_t( 16, 0 );
case 'single'
hInportTypes( 1 ) = pir_ufixpt_t( 32, 0 );
case 'double'
hInportTypes( 1 ) = pir_ufixpt_t( 64, 0 );
otherwise 
hInportTypes( 1 ) = hInSignals( 1 ).Type;
end 

hInportRates = zeros( 1, 1 );
hInportRates( 1 ) = hInSignals( 1 ).SimulinkRate;
hInportKinds = cell( 1, 1 );
hCInputPorts = hC.PirInputPorts;
hInportKinds{ 1 } = hCInputPorts( 1 ).Kind;

hOutportNames = cell( 1, 1 );
hOutportNames{ 1 } = 'nfp_out';
hOutportTypes = hdlhandles( 1, 1 );
switch ( outFloat )
case 'half'
hOutportTypes( 1 ) = pir_ufixpt_t( 16, 0 );
case 'single'
hOutportTypes( 1 ) = pir_ufixpt_t( 32, 0 );
case 'double'
hOutportTypes( 1 ) = pir_ufixpt_t( 64, 0 );
otherwise 
hOutportTypes( 1 ) = hOutSignals( 1 ).Type;
end 

hTopWrapper = pirelab.createNewNetwork(  ...
'Network', hN,  ...
'Name', compName,  ...
'InportNames', hInportNames,  ...
'InportTypes', hInportTypes,  ...
'InportRates', hInportRates,  ...
'InportKinds', hInportKinds,  ...
'OutportNames', hOutportNames,  ...
'OutportTypes', hOutportTypes );
hTopOutSigs = hTopWrapper.PirOutputSignals;
hTopOutSigs( 1 ).SimulinkRate = hOutSignals( 1 ).SimulinkRate;
end 

function hS = addSignal( hN, sigName, pirTyp, simulinkRate )
hS = hN.addSignal;
hS.Name = sigName;
hS.Type = pirTyp;
hS.SimulinkHandle = 0;
hS.SimulinkRate = simulinkRate;
end 


function val = getLatencyStrategy( newVal )





persistent latStrategy;
if isempty( latStrategy )
latStrategy = 1;
end 
if nargin >= 1
latStrategy = newVal;
end 
val = latStrategy;
end 

function val = handleDenormal(  )
val = transformnfp.getHandleDenormal ~= 2;
end 

function val = getHandleDenormal( newVal )



persistent denormalHandling;
if isempty( denormalHandling )
denormalHandling = 1;
end 
if nargin >= 1
denormalHandling = newVal;
end 
val = denormalHandling;
end 

function val = mantissaMultiplyStrategy( newVal )




persistent multStrategy;
if isempty( multStrategy )
multStrategy = 1;
end 
if nargin >= 1
multStrategy = newVal;
end 
val = multStrategy;
end 

function val = partAddShiftMultiplierSize( newVal )



persistent multSize;
if isempty( multSize )
multSize = 1;
end 
if nargin >= 1
multSize = newVal;
end 
val = multSize;
end 

function val = getModRemCheckResetToZero( newVal )
persistent modRemCheckResetToZero;

if isempty( modRemCheckResetToZero )
modRemCheckResetToZero = true;
end 

if nargin >= 1
modRemCheckResetToZero = newVal;
end 
val = modRemCheckResetToZero;
end 

function val = getModRemMaxIterations( newVal )
persistent modRemMaxIterations;

if isempty( modRemMaxIterations )
modRemMaxIterations = 32;
end 

if nargin >= 1
modRemMaxIterations = newVal;
end 
val = modRemMaxIterations;
end 

function val = getTrigArgumentReduction( newVal )
persistent trigArgumentReduction;

if isempty( trigArgumentReduction )
trigArgumentReduction = true;
end 

if nargin >= 1
trigArgumentReduction = newVal;
end 
val = trigArgumentReduction;
end 

function val = getRadix( newVal )
persistent radix;

if isempty( radix )
radix = 2;
end 

if ( nargin >= 1 )
radix = newVal;
end 

val = radix;
end 

function setDelayValues
nonZeroLatencyStrategy = ( transformnfp.getLatencyStrategy ~= 3 );
transformnfp.setIntDelayValues( nonZeroLatencyStrategy );

if transformnfp.getLatencyStrategy == 1
transformnfp.MinLatencyDelay1( 1 );
else 
transformnfp.MinLatencyDelay1( 0 );
end 

if nonZeroLatencyStrategy && ~transformnfp.handleDenormal
transformnfp.NormalOnlyDelay1( 1 );
else 
transformnfp.NormalOnlyDelay1( 0 );
end 
end 

function setIntDelayValues( latency )
newval = zeros( 64, 1 );
if latency
for ii = 1:64
newval( ii ) = ii;
end 
end 
transformnfp.getDelayVal( 1, newval );
end 

function oldval = getDelayVal( index, newval )
persistent val;
if isempty( val )
val = zeros( 64, 1 );
end 
if nargin >= 2
val = newval;
end 
oldval = val( index );
end 


function val = Delay1(  )
val = transformnfp.getDelayVal( 1 );
end 

function val = Delay2(  )
val = transformnfp.getDelayVal( 2 );
end 

function val = Delay3(  )
val = transformnfp.getDelayVal( 3 );
end 

function val = Delay4(  )
val = transformnfp.getDelayVal( 4 );
end 

function val = Delay5(  )
val = transformnfp.getDelayVal( 5 );
end 

function val = Delay6(  )
val = transformnfp.getDelayVal( 6 );
end 

function val = Delay7(  )
val = transformnfp.getDelayVal( 7 );
end 

function val = Delay8(  )
val = transformnfp.getDelayVal( 8 );
end 

function val = Delay9(  )
val = transformnfp.getDelayVal( 9 );
end 

function val = Delay10(  )
val = transformnfp.getDelayVal( 10 );
end 

function val = Delay11(  )
val = transformnfp.getDelayVal( 11 );
end 

function val = Delay12(  )
val = transformnfp.getDelayVal( 12 );
end 

function val = Delay13(  )
val = transformnfp.getDelayVal( 13 );
end 

function val = Delay14(  )
val = transformnfp.getDelayVal( 14 );
end 

function val = Delay15(  )
val = transformnfp.getDelayVal( 15 );
end 

function val = Delay16(  )
val = transformnfp.getDelayVal( 16 );
end 

function val = Delay17(  )
val = transformnfp.getDelayVal( 17 );
end 

function val = Delay18(  )
val = transformnfp.getDelayVal( 18 );
end 

function val = Delay19(  )
val = transformnfp.getDelayVal( 19 );
end 

function val = Delay20(  )
val = transformnfp.getDelayVal( 20 );
end 

function val = Delay21(  )
val = transformnfp.getDelayVal( 21 );
end 

function val = Delay22(  )
val = transformnfp.getDelayVal( 22 );
end 

function val = Delay23(  )
val = transformnfp.getDelayVal( 23 );
end 

function val = Delay24(  )
val = transformnfp.getDelayVal( 24 );
end 

function val = Delay25(  )
val = transformnfp.getDelayVal( 25 );
end 

function val = Delay26(  )
val = transformnfp.getDelayVal( 26 );
end 

function val = Delay27(  )
val = transformnfp.getDelayVal( 27 );
end 

function val = Delay28(  )
val = transformnfp.getDelayVal( 28 );
end 

function val = Delay29(  )
val = transformnfp.getDelayVal( 29 );
end 

function val = Delay30(  )
val = transformnfp.getDelayVal( 30 );
end 

function val = Delay31(  )
val = transformnfp.getDelayVal( 31 );
end 

function val = Delay32(  )
val = transformnfp.getDelayVal( 32 );
end 

function val = Delay35(  )
val = transformnfp.getDelayVal( 35 );
end 

function val = Delay41(  )
val = transformnfp.getDelayVal( 41 );
end 

function val = Delay44(  )
val = transformnfp.getDelayVal( 44 );
end 

function val = Delay51(  )
val = transformnfp.getDelayVal( 51 );
end 

function val = Delay57(  )
val = transformnfp.getDelayVal( 57 );
end 

function val = Delay58(  )
val = transformnfp.getDelayVal( 58 );
end 

function val = Delay59(  )
val = transformnfp.getDelayVal( 59 );
end 

function val = Delay60(  )
val = transformnfp.getDelayVal( 60 );
end 

function val = getTargetCompMap( overwrite )
persistent mTargetCompMap;
createNewMap = false;
if nargin >= 1
createNewMap = overwrite;
end 
if isempty( mTargetCompMap ) || createNewMap
mTargetCompMap = containers.Map;
end 
val = mTargetCompMap;
end 

function val = MinLatencyDelay1( newval )
persistent minLatencyDelay;
if isempty( minLatencyDelay )
minLatencyDelay = 0;
end 
if nargin >= 1
minLatencyDelay = newval;
end 
val = minLatencyDelay;
end 



function val = NormalOnlyDelay1( newval )
persistent normalOnlyDelay;
if isempty( normalOnlyDelay )
normalOnlyDelay = 0;
end 
if nargin >= 1
normalOnlyDelay = newval;
end 
val = normalOnlyDelay;
end 


function [ latency, customLatency ] = getLatencyFromNfpComp( hC, ipName, inType, outType )
if nargin < 4
outType = inType;
end 


if ( ~isempty( inType ) )
if strcmpi( ipName, 'CONVERT' )
if inType.isSingleType
dataType = 'SINGLE';
elseif inType.isHalfType
dataType = 'HALF';
elseif inType.isDoubleType
dataType = 'DOUBLE';
else 
dataType = 'NUMERICTYPE';
end 

dataType = [ dataType, '_TO_' ];

if outType.isSingleType
dataType = [ dataType, 'SINGLE' ];
elseif outType.isHalfType
dataType = [ dataType, 'HALF' ];
elseif outType.isDoubleType
dataType = [ dataType, 'DOUBLE' ];
else 
dataType = [ dataType, 'NUMERICTYPE' ];
end 
else 

if outType.isSingleType
dataType = 'SINGLE';
elseif outType.isHalfType
dataType = 'HALF';
elseif outType.isDoubleType
dataType = 'DOUBLE';
else 
assert( 0, 'NFP operators should have floating-point datatype' );
end 
end 
else 
dataType = 'SINGLE';
end 

fc = hdlgetparameter( 'FloatingPointTargetConfiguration' );
ipSettings = fc.IPConfig.getIPSettings( ipName, dataType );
customLatency =  - 1;
if ( transformnfp.getLatencyStrategy ~= int8( 4 ) ) && ( ipSettings.CustomLatency >= 0 )

latency = ipSettings.CustomLatency;
customLatency = latency;
hdldriver = hdlcurrentdriver;
if ~isempty( hdldriver )
hdldriver.addCheckCurrentDriver( 'Warning', message( 'hdlcommon:nativefloatingpoint:NFPCustomizedLatency', latency, dataType, ipName ) );
else 
warning( message( 'hdlcommon:nativefloatingpoint:NFPCustomizedLatency', latency, dataType, ipName ) );
end 
return ;
end 

switch transformnfp.getLatencyStrategy
case 1
latency = ipSettings.MaxLatency;
if strcmpi( ipName, 'Div' )
if strcmpi( dataType, 'DOUBLE' )
if transformnfp.getRadix == 4
latency = 35;
else 
latency = ipSettings.MaxLatency;
end 
elseif strcmpi( dataType, 'HALF' )
if transformnfp.getRadix == 4
latency = 14;
else 
latency = ipSettings.MaxLatency;
end 
else 
latency = latency - 24 + 12 * ( 4 / transformnfp.getRadix );
end 
end 

if strcmpi( ipName, 'Recip' )
if strcmpi( dataType, 'DOUBLE' )
if transformnfp.getRadix == 4
latency = 34;
else 
latency = ipSettings.MaxLatency;
end 
elseif strcmpi( dataType, 'HALF' )
if transformnfp.getRadix == 4
latency = 14;
else 
latency = ipSettings.MaxLatency;
end 
else 
latency = latency - 24 + 12 * ( 4 / transformnfp.getRadix );
end 
end 


if strcmpi( ipName, 'GainPow2' ) && transformnfp.handleDenormal(  )
if strcmpi( dataType, 'HALF' )
latency = 4;
else 
latency = 5;
end 
end 

if strcmpi( ipName, 'Mul' ) && transformnfp.handleDenormal(  )
if strcmpi( dataType, 'HALF' )
latency = 7;
else 
latency = ipSettings.MaxLatency;
end 
end 
case 2
latency = ipSettings.MinLatency;
if strcmpi( ipName, 'Div' )
if strcmpi( dataType, 'DOUBLE' )
if transformnfp.getRadix == 4
latency = 21;
else 
latency = ipSettings.MinLatency;
end 
elseif strcmpi( dataType, 'HALF' )
if transformnfp.getRadix == 4
latency = 8;
else 
latency = ipSettings.MinLatency;
end 
else 
latency = latency - 12 + 6 * ( 4 / transformnfp.getRadix );
end 
end 

if strcmpi( ipName, 'Recip' )
if strcmpi( dataType, 'DOUBLE' )
if transformnfp.getRadix == 4
latency = 21;
else 
latency = ipSettings.MinLatency;
end 
elseif strcmpi( dataType, 'HALF' )
if transformnfp.getRadix == 4
latency = 8;
else 
latency = ipSettings.MinLatency;
end 
else 
latency = latency - 12 + 6 * ( 4 / transformnfp.getRadix );
end 
end 


if strcmpi( ipName, 'GainPow2' ) && transformnfp.handleDenormal(  )
latency = 3;
end 
case 3
latency = 0;
case 4
latency = hC.getNFPCustomLatency(  );
otherwise 
error( 'Component latency property still set to inherit' );
end 
end 
function noInitflag = needNoInitialize(  )
hDriver = hdlcurrentdriver;
if ( isempty( hDriver ) || ~isa( hDriver, 'slhdlcoder.HDLCoder' ) )
noInitflag = [  ];
else 
noInitflag = ( ( hDriver.getParameter( 'MinimizeGlobalResets' ) ) && strcmpi( hDriver.getParameter( 'NoResetInitializationMode' ), 'None' ) );
end 
end 
function noGlobalReset = needNoGlobalReset(  )
hDriver = hdlcurrentdriver;
if ( isempty( hDriver ) || ~isa( hDriver, 'slhdlcoder.HDLCoder' ) )
noGlobalReset = [  ];
else 
noGlobalReset = ( ( hDriver.getParameter( 'MinimizeGlobalResets' ) ) );
end 
end 
function createDelayWrapper( hN, OutSig, InSig, Type, slRate1 )
fiMath1 = fimath( 'RoundingMethod', 'Nearest', 'OverflowAction', 'Saturate', 'ProductMode', 'FullPrecision', 'SumMode', 'FullPrecision' );
nt2 = numerictype( 0, 1, 0 );
Delay1_out_s2 = transformnfp.addSignal( hN, [ OutSig.Name, '_out' ], Type, slRate1 );
Delay1_Initial_Val_out_s3 = transformnfp.addSignal( hN, [ OutSig.Name, '_Initial_Val_out' ], Type, slRate1 );
Delay1_ctrl_const_out_s4 = transformnfp.addSignal( hN, [ OutSig.Name, '_ctrl_const_out' ], Type, slRate1 );
Delay1_ctrl_delay_out_s5 = transformnfp.addSignal( hN, [ OutSig.Name, '_ctrl_delay_out' ], Type, slRate1 );

pirelab.getIntDelayComp( hN,  ...
InSig,  ...
Delay1_out_s2,  ...
1, [ OutSig.Name, '_init' ],  ...
double( 0 ),  ...
0, 0, [  ], 0, 0 );

pirelab.getConstComp( hN,  ...
Delay1_Initial_Val_out_s3,  ...
fi( 0, nt2, fiMath1, 'hex', '1' ),  ...
[ OutSig.Name, '_Initial_Val' ], 'on', 0, '', '', '' );

pirelab.getConstComp( hN,  ...
Delay1_ctrl_const_out_s4,  ...
1,  ...
[ OutSig.Name, '_ctrl_const' ] );

pirelab.getIntDelayComp( hN,  ...
Delay1_ctrl_const_out_s4,  ...
Delay1_ctrl_delay_out_s5,  ...
1, [ OutSig.Name, '_ctrl_delay' ],  ...
double( 0 ),  ...
0, 0, [  ], 0, 0 );

pirelab.getSwitchComp( hN,  ...
[ Delay1_out_s2, Delay1_Initial_Val_out_s3 ],  ...
OutSig,  ...
Delay1_ctrl_delay_out_s5, [ OutSig.Name, '_switch' ],  ...
'~=', 0, 'Floor', 'Wrap' );


end 
end 
end 







% Decoded using De-pcode utility v1.2 from file /tmp/tmpkT30bP.p.
% Please follow local copyright laws when handling this file.

