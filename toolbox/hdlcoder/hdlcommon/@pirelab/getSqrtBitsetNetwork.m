function hSqrtNet = getSqrtBitsetNetwork( topNet, hInSignals, hOutSignals, sqrtInfo )

















hSqrtNet = pirelab.createNewNetwork(  ...
'Network', topNet,  ...
'Name', sqrtInfo.networkName,  ...
'InportNames', { 'din' },  ...
'InportTypes', [ hInSignals( 1 ).Type ],  ...
'InportRates', [ hInSignals( 1 ).SimulinkRate ],  ...
'OutportNames', { 'dout' },  ...
'OutportTypes', [ hOutSignals( 1 ).Type ] );


hSqrtNet_InSignals = hSqrtNet.PirInputSignals( 1 );
hSqrtNet_OutSignals = hSqrtNet.PirOutputSignals( 1 );

hSqrtNet( 1 ).PirOutputSignals( 1 ).SimulinkRate = hOutSignals( 1 ).SimulinkRate;


if strcmpi( sqrtInfo.algorithm, 'UseMultiplier' )
algorithmMultOn = true;

pirelab.getAnnotationComp( hSqrtNet, 'anno', 'Sqrt Implementation using Multiplier' );
elseif strcmpi( sqrtInfo.algorithm, 'UseShift' )
algorithmMultOn = false;

pirelab.getAnnotationComp( hSqrtNet, 'anno', 'Sqrt Implementation using Shift' );
else 
error( message( 'hdlcommon:hdlcommon:UnsupportedAlgorithm', sqrtInfo.networkName ) );
end 

if ~( isfield( sqrtInfo, 'pipeline' ) )
sqrtInfo.pipeline = false;
end 

if ~( isfield( sqrtInfo, 'vt' ) )
sqrtInfo.vt = false;
end 


if hSqrtNet_InSignals( 1 ).Type.isArrayType


arrInSplitter = hSqrtNet_InSignals( 1 ).split(  );
arr_SqrtInSignals = arrInSplitter.PirOutputSignals;

outSplitter = pirelab.getMuxOnOutput( hSqrtNet, hSqrtNet_OutSignals( 1 ) );
arr_SqrtOutSignals = outSplitter( 1 ).PirInputSignals;
for ii = 1:length( arr_SqrtInSignals )
elaborate_scalar( hSqrtNet, arr_SqrtInSignals( ii ), arr_SqrtOutSignals( ii ), sqrtInfo, algorithmMultOn );
end 
else 
elaborate_scalar( hSqrtNet, hSqrtNet_InSignals, hSqrtNet_OutSignals, sqrtInfo, algorithmMultOn );
end 
end 


function elaborate_scalar( hSqrtNet, din, dout, sqrtInfo, algorithmMultOn )

inputType = din.Type;
inSigned = inputType.Signed;
inputWL = inputType.WordLength;
inputFL =  - inputType.FractionLength;
outputType = dout.Type;
outSigned = outputType.Signed;
outputWL = outputType.WordLength;
outputFL =  - outputType.FractionLength;

rndMode = sqrtInfo.rndMode;
satMode = sqrtInfo.satMode;


intermType = pir_ufixpt_t( outputWL,  - outputFL );
mulType = pir_ufixpt_t( outputWL * 2,  - outputFL * 2 );


if outSigned
k = outputWL - 1;
else 
k = outputWL;
end 


if ( ~algorithmMultOn )
inputIntL = inputWL - inputFL;
outputIntL = ceil( inputIntL / 2 );
newoutWL = outputIntL + outputFL;
k = min( k, newoutWL );
end 

if ( k <= 0 )
k = 1;
end 

totalPipelinestages = k + 2;

pipelinestageArray = customPipelineStages( totalPipelinestages, sqrtInfo.customLatency, sqrtInfo.latencyStrategy );
if outputWL == 1 && outSigned == 0

resizedin = hSqrtNet.addSignal( mulType, 'resizedin' );
din_p = hSqrtNet.addSignal( inputType, 'din_p' );
dout_temp = hSqrtNet.addSignal( outputType, 'dout_temp' );
if ( strcmpi( sqrtInfo.pipeline, 'on' ) )

pirelab.getIntDelayComp( hSqrtNet, din, din_p, pipelinestageArray( 1 ), sprintf( 'din_reg' ) );
else 
pirelab.getWireComp( hSqrtNet, din, din_p, 'din_p' );
end 
pirelab.getDTCComp( hSqrtNet, din_p, resizedin, rndMode, 'Saturate' );
if strcmpi( rndMode, 'Ceiling' )
compare_sign = '~=';
compare_value = 0;
elseif ( strcmpi( rndMode, 'Nearest' ) )
compare_sign = '>=';
compare_value = 2 ^ (  - 2 * outputFL - 1 );
else 
compare_sign = '>=';
compare_value = 2 ^ (  - 2 * outputFL );
end 


if strcmpi( sqrtInfo.pipeline, 'on' )
resizedin_p = hSqrtNet.addSignal( mulType, 'resizedin_p' );
for ii = k: - 1:1
resizedin_p_temp = hSqrtNet.addSignal( mulType, sprintf( 'resizedin%d_p', ii ) );
pirelab.getIntDelayComp( hSqrtNet, resizedin, resizedin_p_temp, pipelinestageArray( 1 + ii ), sprintf( 'resizedin%d_reg', k ) );
resizedin_p = resizedin_p_temp;
end 
pirelab.getCompareToValueComp( hSqrtNet, resizedin_p, dout_temp, compare_sign, compare_value );

pirelab.getIntDelayComp( hSqrtNet, dout_temp, dout, pipelinestageArray( end  ), sprintf( 'dout_reg' ) );
else 
pirelab.getCompareToValueComp( hSqrtNet, resizedin, dout_temp, compare_sign, compare_value );
pirelab.getWireComp( hSqrtNet, dout_temp, dout, 'dout' );
end 



elseif inputWL == 1 && inSigned == 0

resizedin = hSqrtNet.addSignal( intermType, 'resizedin' );
din_p = hSqrtNet.addSignal( inputType, 'din_p' );
dout_temp = hSqrtNet.addSignal( outputType, 'dout_temp' );
if ( strcmpi( sqrtInfo.pipeline, 'on' ) )

pirelab.getIntDelayComp( hSqrtNet, din, din_p, pipelinestageArray( 1 ), sprintf( 'din_reg' ) );
else 
pirelab.getWireComp( hSqrtNet, din, din_p, 'din_p' );
end 
pirelab.getDTCComp( hSqrtNet, din_p, resizedin, rndMode, 'Saturate' );


if strcmpi( sqrtInfo.pipeline, 'on' )
resizedin_p = hSqrtNet.addSignal( intermType, 'resizedin_p' );
for ii = k: - 1:1
resizedin_p_temp = hSqrtNet.addSignal( intermType, sprintf( 'resizedin%d_p', k ) );
pirelab.getIntDelayComp( hSqrtNet, resizedin, resizedin_p_temp, pipelinestageArray( 1 + ii ), sprintf( 'resizedin%d_reg', k ) );
resizedin_p = resizedin_p_temp;
end 
pirelab.getDTCComp( hSqrtNet, resizedin_p, dout_temp, rndMode, satMode );

pirelab.getIntDelayComp( hSqrtNet, dout_temp, dout, pipelinestageArray( end  ), sprintf( 'dout_reg' ) );
else 
pirelab.getDTCComp( hSqrtNet, resizedin, dout_temp, rndMode, satMode );
pirelab.getWireComp( hSqrtNet, dout_temp, dout, 'dout' );
end 
else 
if algorithmMultOn






















elabSqrtWithMultiplier( hSqrtNet, din, dout, rndMode, satMode, k, sqrtInfo, pipelinestageArray );
else 



if ( sqrtInfo.vt )
elabSqrtWithShiftVtPipelined( hSqrtNet, din, dout, rndMode, satMode, k )
else 
elabSqrtWithShift( hSqrtNet, din, dout, rndMode, satMode, k, sqrtInfo, pipelinestageArray );
end 

end 
end 

end 


function elabSqrtWithMultiplier( hN, hInSignals, hOutSignals, rndMode, satMode, k, sqrtInfo, pipelinestageArray )



outputType = hOutSignals.Type;
InType = hInSignals.Type;
outputWL = outputType.WordLength;
outputFL =  - outputType.FractionLength;


intermType = pir_ufixpt_t( outputWL,  - outputFL );
mulType = pir_ufixpt_t( outputWL * 2,  - outputFL * 2 );
ufix1Type = pir_ufixpt_t( 1, 0 );


baseksqrv = pirelab.getTypeInfoAsFi( mulType, 'Floor', 'Wrap', 2 ^ ( 2 * ( k - outputFL - 1 ) ) );
baseksqr = hN.addSignal( mulType, sprintf( 'base%dsqr', k - 1 ) );
pirelab.getConstComp( hN, baseksqr, baseksqrv );


rootiniv = pirelab.getTypeInfoAsFi( intermType );
rootini = hN.addSignal( intermType, 'rootini' );
pirelab.getConstComp( hN, rootini, rootiniv );


resizedin = hN.addSignal( mulType, 'resizedin' );

delayName1 = sprintf( '%s_reg', hInSignals( 1 ).Name );
In1_p = hN.addSignal( InType, delayName1 );
if strcmpi( sqrtInfo.pipeline, 'on' )
pirelab.getIntDelayComp( hN, hInSignals( 1 ), In1_p, pipelinestageArray( 1 ), 'In1_p', 0, 0, 0, [  ], 0, 0 );
else 
In1_p = hInSignals( 1 );
end 

pirelab.getDTCComp( hN, In1_p, resizedin, rndMode, 'Saturate' );


for ii = k: - 1:1


basev = pirelab.getTypeInfoAsFi( intermType, 'Floor', 'Wrap', 2 ^ ( ii - outputFL - 1 ) );
base = hN.addSignal( intermType, sprintf( 'base%d', ii - 1 ) );
pirelab.getConstComp( hN, base, basev );


yy = hN.addSignal( mulType, sprintf( 'yy%d', ii - 1 ) );
roottmp = hN.addSignal( intermType, sprintf( 'roottmp%d', ii - 1 ) );
if ( ii == k )
pirelab.getWireComp( hN, baseksqr, yy );
pirelab.getWireComp( hN, base, roottmp );
rootplus = rootini;
else 
rootplus = root;
pirelab.getAddComp( hN, [ base, root ], roottmp, rndMode, satMode );
pirelab.getMulComp( hN, [ roottmp, roottmp ], yy, rndMode, satMode );
end 


root = hN.addSignal( intermType, sprintf( 'root%d', ii - 1 ) );
cmp = hN.addSignal( ufix1Type, sprintf( 'cmp%d', ii - 1 ) );
pirelab.getRelOpComp( hN, [ yy, resizedin ], cmp, '<=', sprintf( 'cmp%d', ii - 1 ) );
pirelab.getSwitchComp( hN, [ rootplus, roottmp ], root, cmp );


root_p = hN.addSignal( intermType, sprintf( 'root%d_p', ii ) );
resizedin_p = hN.addSignal( mulType, sprintf( 'resizedin%d_p', ii ) );
if strcmpi( sqrtInfo.pipeline, 'on' )
pirelab.getIntDelayComp( hN, root, root_p, pipelinestageArray( 1 + ii ), 'root_reg' );
pirelab.getIntDelayComp( hN, resizedin, resizedin_p, pipelinestageArray( 1 + ii ), 'resizedin_reg' );
else 
root_p = root;
resizedin_p = resizedin;

end 
resizedin = resizedin_p;
root = root_p;
end 




if ( strcmpi( rndMode, 'Nearest' ) || strcmpi( rndMode, 'Ceiling' ) )
yytemp = hN.addSignal( mulType, 'yytemp' );
rootout = hN.addSignal( intermType, 'rootout' );
maxcmpout = hN.addSignal( intermType, 'maxcmpout' );
mulComp = pirelab.getMulComp( hN, [ root, root ], yytemp, rndMode, satMode );
mulComp.addComment( sprintf( 'Add a LSB when roundmode is %s', rndMode ) );


output_ex = pirelab.getTypeInfoAsFi( outputType );
maxyv = pirelab.getTypeInfoAsFi( intermType, 'Floor', 'Wrap', realmax( output_ex ) );
maxy = hN.addSignal( intermType, 'maxy' );
pirelab.getConstComp( hN, maxy, maxyv );

cmpmax = hN.addSignal( ufix1Type, 'cmpmax' );
pirelab.getRelOpComp( hN, [ root, maxy ], cmpmax, '<', 'cmpmax' );


lsbyv = pirelab.getTypeInfoAsFi( intermType, 'Floor', 'Wrap', lsb( output_ex ) );
lsby = hN.addSignal( intermType, 'lsby' );
pirelab.getConstComp( hN, lsby, lsbyv );

rootpluslsb = hN.addSignal( intermType, 'rootpluslsb' );
pirelab.getAddComp( hN, [ lsby, root ], rootpluslsb, rndMode, satMode );
outsel = hN.addSignal( ufix1Type, 'outsel' );

if strcmpi( rndMode, 'Ceiling' )

cmpinzero = hN.addSignal( ufix1Type, 'cmpinzero' );
cmptempyy = hN.addSignal( ufix1Type, 'cmptempyy' );
pirelab.getCompareToValueComp( hN, resizedin, cmpinzero, '~=', 0 );
pirelab.getRelOpComp( hN, [ yytemp, resizedin ], cmptempyy, '<', 'cmptempyy' );
pirelab.getBitwiseOpComp( hN, [ cmpinzero, cmptempyy ], outsel, 'AND' );
else 

yypluslsb = hN.addSignal( mulType, 'yypluslsb' );
pirelab.getMulComp( hN, [ rootpluslsb, rootpluslsb ], yypluslsb, rndMode, satMode );
sub1 = hN.addSignal( mulType, 'sub1' );
sub2 = hN.addSignal( mulType, 'sub2' );
pirelab.getSubComp( hN, [ yypluslsb, resizedin ], sub1, rndMode, satMode );
pirelab.getSubComp( hN, [ resizedin, yytemp ], sub2, rndMode, satMode );
pirelab.getRelOpComp( hN, [ sub1, sub2 ], outsel, '<', 'outsel' );
end 
maxcmpout_temp = hN.addSignal( outputType, 'maxcmpout_temp' );
pirelab.getSwitchComp( hN, [ root, rootpluslsb ], rootout, outsel );
pirelab.getSwitchComp( hN, [ root, rootout ], maxcmpout, cmpmax );
pirelab.getDTCComp( hN, maxcmpout, maxcmpout_temp, rndMode, satMode );

if strcmpi( sqrtInfo.pipeline, 'on' )
pirelab.getIntDelayComp( hN, maxcmpout_temp, hOutSignals, pipelinestageArray( end  ), 'out_reg' );
else 
pirelab.getWireComp( hN, maxcmpout_temp, hOutSignals, 'out' );
end 
else 

root_temp = hN.addSignal( outputType, 'root_temp' );
pirelab.getDTCComp( hN, root, root_temp, rndMode, satMode );
if strcmpi( sqrtInfo.pipeline, 'on' )
pirelab.getIntDelayComp( hN, root_temp, hOutSignals, pipelinestageArray( end  ), 'out_reg' );
else 
pirelab.getWireComp( hN, root_temp, hOutSignals, 'out' );
end 
end 

end 


function elabSqrtWithShift( hN, hInSignals, hOutSignals, rndMode, satMode, k, sqrtInfo, pipelinestageArray )



outputType = hOutSignals.Type;
outputWL = outputType.WordLength;
outputFL =  - outputType.FractionLength;


intermType = pir_ufixpt_t( outputWL );
mulType = pir_ufixpt_t( outputWL * 2 );
ufix1Type = pir_ufixpt_t( 1, 0 );

mulType_temp = pir_ufixpt_t( outputWL * 2,  - outputFL * 2 );


resizedin = hN.addSignal( mulType_temp, 'resizedin' );
resizedin_temp = hN.addSignal( mulType, 'resizedin_temp' );
In1_p = hInSignals( 1 );

pirelab.getDTCComp( hN, In1_p, resizedin, rndMode, 'Saturate' );
pirelab.getDTCComp( hN, resizedin, resizedin_temp, rndMode, 'Saturate', 'SI' );


space = ( outputWL * 2 ) - ( k * 2 );
if ( space == 0 )
z = 0;
else 
if ( outputWL == 2 && k == 1 )
z = 1;
else 
z = nextpow2( space ) - 1;
end 
end 



for n = 1:k

ii = n + z;

currentRoot_SquareType = pir_ufixpt_t( 2 * ii );
currentRoot_Square = hN.addSignal( currentRoot_SquareType, sprintf( 'Root_Square%d', n - 1 ) );
currentRoot_Square_temp_0 = hN.addSignal( currentRoot_SquareType, sprintf( 'Root_Square%d_temp0', ii - 1 ) );
currentRoot_Square_temp_1 = hN.addSignal( currentRoot_SquareType, sprintf( 'Root_Square%d_temp1', ii - 1 ) );

currentRoot_Type = pir_ufixpt_t( ii );
currentRoot = hN.addSignal( currentRoot_Type, sprintf( 'Root_%d', n - 1 ) );


din_temp = hN.addSignal( currentRoot_SquareType, sprintf( 'din_temp_%d', n - 1 ) );
msbPos = ( k + z ) * 2 - 1;
lsbPos = msbPos - ( 2 * ii ) + 1;
cmp = hN.addSignal( ufix1Type, sprintf( 'cmp%d', n - 1 ) );
pirelab.getBitSliceComp( hN, resizedin_temp, din_temp, msbPos, lsbPos );
if ( n == 1 )

currentRoot_temp0 = hN.addSignal( currentRoot_Type, sprintf( 'root_%d_temp0', n - 1 ) );
currentRoot_temp1 = hN.addSignal( currentRoot_Type, sprintf( 'root_%d_temp1', n - 1 ) );

rootinitv0 = pirelab.getTypeInfoAsFi( currentRoot_Type, 'Floor', 'Wrap', 0 );
rootinitv1 = pirelab.getTypeInfoAsFi( currentRoot_Type, 'Floor', 'Wrap', 1 );
pirelab.getConstComp( hN, currentRoot_temp0, rootinitv0 );
pirelab.getConstComp( hN, currentRoot_temp1, rootinitv1 );

Root_SquareInitV1 = pirelab.getTypeInfoAsFi( currentRoot_SquareType, 'Floor', 'Wrap', 1 );
Root_SquareInitV0 = pirelab.getTypeInfoAsFi( currentRoot_SquareType, 'Floor', 'Wrap', 0 );
pirelab.getConstComp( hN, currentRoot_Square_temp_1, Root_SquareInitV1 );
pirelab.getConstComp( hN, currentRoot_Square_temp_0, Root_SquareInitV0 );
pirelab.getRelOpComp( hN, [ currentRoot_Square_temp_1, din_temp ], cmp, '<=', sprintf( 'cmp%d', n - 1 ) );
pirelab.getSwitchComp( hN, [ currentRoot_temp0, currentRoot_temp1 ], currentRoot, cmp );
pirelab.getSwitchComp( hN, [ currentRoot_Square_temp_0, currentRoot_Square_temp_1 ], currentRoot_Square, cmp );
else 

constantType = pir_ufixpt_t( 2 );
prevRoot_extendType = pir_ufixpt_t( ii + 1 );
constant_0 = pirelab.getTypeInfoAsFi( constantType, 'Floor', 'Wrap', 0 );
constant_1 = pirelab.getTypeInfoAsFi( constantType, 'Floor', 'Wrap', 1 );
constant_0_sig = hN.addSignal( constantType, sprintf( 'constant_0%d', n - 1 ) );
constant_1_sig = hN.addSignal( constantType, sprintf( 'constant_0%d', n - 1 ) );
prevRoot_extend = hN.addSignal( prevRoot_extendType, sprintf( 'prevRoot_extend%d', n - 1 ) );
prevRoot_Square_extend = hN.addSignal( currentRoot_SquareType, sprintf( 'prevRoot_Square_extend%d', n - 1 ) );
pirelab.getConstComp( hN, constant_0_sig, constant_0 );
pirelab.getConstComp( hN, constant_1_sig, constant_1 );
pirelab.getBitConcatComp( hN, [ prevRoot_Square, constant_0_sig ], currentRoot_Square_temp_0 );
pirelab.getBitConcatComp( hN, [ prevRoot_Square, constant_1_sig ], prevRoot_Square_extend );
pirelab.getBitConcatComp( hN, [ prevRoot, constant_0_sig ], prevRoot_extend );
pirelab.getAddComp( hN, [ prevRoot_Square_extend, prevRoot_extend ], currentRoot_Square_temp_1, rndMode, satMode );
pirelab.getRelOpComp( hN, [ currentRoot_Square_temp_1, din_temp ], cmp, '<=', sprintf( 'cmp%d', n - 1 ) );
pirelab.getSwitchComp( hN, [ currentRoot_Square_temp_0, currentRoot_Square_temp_1 ], currentRoot_Square, cmp );
pirelab.getBitConcatComp( hN, [ prevRoot, cmp ], currentRoot );
end 

currentRoot_p = hN.addSignal( currentRoot_Type, sprintf( 'currentRoot%d_p', n ) );
resizedin_p = hN.addSignal( mulType, sprintf( 'resizedin%d_p', n ) );
currentRoot_Square_p = hN.addSignal( currentRoot_SquareType, sprintf( 'currentRoot_Square%d_p', n ) );
if strcmpi( sqrtInfo.pipeline, 'on' )
pirelab.getIntDelayComp( hN, currentRoot, currentRoot_p, pipelinestageArray( n ), 'root_reg' );
pirelab.getIntDelayComp( hN, currentRoot_Square, currentRoot_Square_p, pipelinestageArray( n ), 'root_sq_p_reg' );
pirelab.getIntDelayComp( hN, resizedin_temp, resizedin_p, pipelinestageArray( n ), 'resizedin_reg' );
else 
currentRoot_p = currentRoot;
currentRoot_Square_p = currentRoot_Square;
resizedin_p = resizedin_temp;

end 
resizedin_temp = resizedin_p;
prevRoot = currentRoot_p;
prevRoot_Square = currentRoot_Square_p;

end 




if ( strcmpi( rndMode, 'Nearest' ) || strcmpi( rndMode, 'Ceiling' ) )
prevRoot_p = hN.addSignal( currentRoot_Type, sprintf( 'prevRoot_p_lsb' ) );
prevRoot_p_2 = hN.addSignal( currentRoot_Type, sprintf( 'prevRoot_p_2_lsb' ) );
if strcmpi( sqrtInfo.pipeline, 'on' )
pirelab.getIntDelayComp( hN, prevRoot, prevRoot_p, pipelinestageArray( 1 + k ), 'prevRoot_p_lsb' );
pirelab.getIntDelayComp( hN, prevRoot_p, prevRoot_p_2, pipelinestageArray( 2 + k ), 'prevRoot_p2_lsb' );
else 
prevRoot_p = prevRoot;
prevRoot_p_2 = prevRoot_p;
end 

output_ex = pirelab.getTypeInfoAsFi( intermType );
maxyv = pirelab.getTypeInfoAsFi( intermType, 'Floor', 'Wrap', realmax( output_ex ) );
maxy = hN.addSignal( intermType, 'maxy' );
pirelab.getConstComp( hN, maxy, maxyv );


lsbval = lsb( output_ex );
lsbyv = pirelab.getTypeInfoAsFi( intermType, 'Floor', 'Wrap', lsbval );
lsby = hN.addSignal( intermType, 'lsby' );
lsby_p = hN.addSignal( intermType, 'lsby_P' );
pirelab.getConstComp( hN, lsby, lsbyv );
if strcmpi( sqrtInfo.pipeline, 'on' )
pirelab.getIntDelayComp( hN, lsby, lsby_p, pipelinestageArray( 1 + k ), 'constant1_sig_p' );
else 
lsby_p = lsby;
end 



rootout = hN.addSignal( intermType, 'rootout' );
cmpmax = hN.addSignal( ufix1Type, 'cmpmax' );
cmpmax_p = hN.addSignal( ufix1Type, 'cmpmax_p' );

roComp = pirelab.getRelOpComp( hN, [ prevRoot, maxy ], cmpmax, '<', 'cmpmax' );
if strcmpi( sqrtInfo.pipeline, 'on' )
pirelab.getIntDelayComp( hN, cmpmax, cmpmax_p, sum( pipelinestageArray( k + 1:k + 2 ) ), 'cmpmax_p' );
else 
cmpmax_p = cmpmax;
end 
roComp.addComment( sprintf( 'Add a LSB when roundmode is %s', rndMode ) );

yytemp = prevRoot_Square;
rootpluslsb = hN.addSignal( intermType, 'rootpluslsb' );
rootpluslsb_p = hN.addSignal( intermType, 'rootpluslsb_p' );
pirelab.getAddComp( hN, [ lsby_p, prevRoot_p ], rootpluslsb, rndMode, satMode );
if strcmpi( sqrtInfo.pipeline, 'on' )
pirelab.getIntDelayComp( hN, rootpluslsb, rootpluslsb_p, pipelinestageArray( k + 2 ), 'rootpluslsb_p' );
else 
rootpluslsb_p = rootpluslsb;
end 
outsel = hN.addSignal( ufix1Type, 'outsel' );
outsel_p = hN.addSignal( ufix1Type, 'outsel_p' );
if strcmpi( rndMode, 'Ceiling' )

cmpinzero = hN.addSignal( ufix1Type, 'cmpinzero' );
cmptempyy = hN.addSignal( ufix1Type, 'cmptempyy' );
cmpinzero_p = hN.addSignal( ufix1Type, 'cmpinzero_p' );
cmptempyy_p = hN.addSignal( ufix1Type, 'cmptempyy_p' );
switch_control = hN.addSignal( ufix1Type, 'switch_control' );
pirelab.getCompareToValueComp( hN, resizedin_temp, cmpinzero, '~=', 0 );
if strcmpi( sqrtInfo.pipeline, 'on' )
pirelab.getIntDelayComp( hN, cmpinzero, cmpinzero_p, pipelinestageArray( 1 + k ), 'cmpinzero_p' );
else 
cmpinzero_p = cmpinzero;
end 
pirelab.getRelOpComp( hN, [ yytemp, resizedin_temp ], cmptempyy, '<', 'cmptempyy' );
if strcmpi( sqrtInfo.pipeline, 'on' )
pirelab.getIntDelayComp( hN, cmptempyy, cmptempyy_p, pipelinestageArray( 1 + k ), 'cmptempyy_p' );
else 
cmptempyy_p = cmptempyy;
end 
pirelab.getBitwiseOpComp( hN, [ cmpinzero_p, cmptempyy_p ], outsel, 'AND' );
if strcmpi( sqrtInfo.pipeline, 'on' )
pirelab.getIntDelayComp( hN, outsel, outsel_p, pipelinestageArray( 2 + k ), 'outsel_p' );
else 
outsel_p = outsel;
end 
pirelab.getLogicComp( hN, [ cmpmax_p, outsel_p ], switch_control, 'and' );
else 

constant1_sig = hN.addSignal( ufix1Type, 'constant1_sig' );
constant1_v = pirelab.getTypeInfoAsFi( ufix1Type, 'Floor', 'Wrap', 1 );
pirelab.getConstComp( hN, constant1_sig, constant1_v );
yypluslsb = hN.addSignal( mulType, 'yypluslsb' );
yypluslsb_p = hN.addSignal( mulType, 'yypluslsb_p' );
squaresum = hN.addSignal( mulType, sprintf( 'squaresum' ) );
squaresum_p = hN.addSignal( mulType, sprintf( 'squaresum_p' ) );
shift2 = hN.addSignal( mulType, sprintf( 'shift2' ) );
shift2_p = hN.addSignal( mulType, sprintf( 'shift2_p' ) );
rootdtc = hN.addSignal( mulType, sprintf( 'rootdtc' ) );
resizedin_temp_p = hN.addSignal( mulType, 'resizedin_temp_p' );
yytemp_p = hN.addSignal( currentRoot_SquareType, sprintf( 'yytemp_p' ) );
switch_control = hN.addSignal( ufix1Type, 'switch_control' );

pirelab.getAddComp( hN, [ prevRoot_Square, constant1_sig ], squaresum, rndMode, satMode );
if strcmpi( sqrtInfo.pipeline, 'on' )
pirelab.getIntDelayComp( hN, squaresum, squaresum_p, pipelinestageArray( 1 + k ), 'squaresum_p' );
else 
squaresum_p = squaresum;
end 
pirelab.getDTCComp( hN, prevRoot, rootdtc );
shiftLen = 1;
pirelab.getBitShiftComp( hN, rootdtc, shift2, 'sll', shiftLen );
if strcmpi( sqrtInfo.pipeline, 'on' )
pirelab.getIntDelayComp( hN, shift2, shift2_p, pipelinestageArray( 1 + k ), 'shift2_p' );
else 
shift2_p = shift2;
end 
pirelab.getAddComp( hN, [ squaresum_p, shift2_p ], yypluslsb, rndMode, satMode );
if strcmpi( sqrtInfo.pipeline, 'on' )
pirelab.getIntDelayComp( hN, yypluslsb, yypluslsb_p, pipelinestageArray( 2 + k ), 'yypluslsb_p' );
else 
yypluslsb_p = yypluslsb;
end 
sub1 = hN.addSignal( mulType, 'sub1' );
sub2 = hN.addSignal( mulType, 'sub2' );
if strcmpi( sqrtInfo.pipeline, 'on' )
pirelab.getIntDelayComp( hN, resizedin_temp, resizedin_temp_p, sum( pipelinestageArray( 1 + k:2 + k ) ), 'resizedin_temp_p' );
pirelab.getIntDelayComp( hN, yytemp, yytemp_p, sum( pipelinestageArray( 1 + k:2 + k ) ), 'yytemp_p' );
else 
resizedin_temp_p = resizedin_temp;
yytemp_p = yytemp;
end 
pirelab.getSubComp( hN, [ yypluslsb_p, resizedin_temp_p ], sub1, rndMode, satMode );
pirelab.getSubComp( hN, [ resizedin_temp_p, yytemp_p ], sub2, rndMode, satMode );
pirelab.getRelOpComp( hN, [ sub1, sub2 ], outsel, '<', 'outsel' );
pirelab.getLogicComp( hN, [ cmpmax_p, outsel ], switch_control, 'and' );
end 


pirelab.getSwitchComp( hN, [ prevRoot_p_2, rootpluslsb_p ], rootout, switch_control );
outdata_1 = hN.addSignal( outputType, 'outdata_1' );
outdata_temp = hN.addSignal( outputType, 'outdata_temp' );
pirelab.getDTCComp( hN, rootout, outdata_1, rndMode, 'Saturate', 'SI' );
pirelab.getDTCComp( hN, outdata_1, outdata_temp, rndMode, satMode, 'RWV' );
pirelab.getWireComp( hN, outdata_temp, hOutSignals, 'out' );
else 

prevRoot_p_2 = hN.addSignal( currentRoot_Type, sprintf( 'prevRoot_p_2' ) );
if strcmpi( sqrtInfo.pipeline, 'on' )
pirelab.getIntDelayComp( hN, prevRoot, prevRoot_p_2, sum( pipelinestageArray( 1 + k:2 + k ) ), 'prevRoot_p2' );
else 
prevRoot_p_2 = prevRoot;
end 
outdata_1 = hN.addSignal( outputType, 'outdata_1' );
outdata_temp = hN.addSignal( outputType, 'outdata_temp' );
pirelab.getDTCComp( hN, prevRoot_p_2, outdata_1, rndMode, 'Saturate', 'SI' );
pirelab.getDTCComp( hN, outdata_1, outdata_temp, rndMode, satMode, 'RWV' );
pirelab.getWireComp( hN, outdata_temp, hOutSignals, 'out' );

end 

end 

function pipelinestageArray = customPipelineStages( totalPipelineStages, latency, latencyStrategy )

pipelinestageArray = zeros( 1, totalPipelineStages );
if ( strcmpi( latencyStrategy, 'MIN' ) )
latency = floor( totalPipelineStages / 2 );
end 
if ( strcmpi( latencyStrategy, 'MAX' ) )
pipelinestageArray = ones( 1, totalPipelineStages );
elseif ( strcmpi( latencyStrategy, 'CUSTOM' ) || strcmpi( latencyStrategy, 'MIN' ) )




if ( latency ~= 0 )


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

function elabSqrtWithShiftVtPipelined( hN, hInSignals, hOutSignals, rndMode, satMode, k )



outputType = hOutSignals.Type;
outputWL = outputType.WordLength;
outputFL =  - outputType.FractionLength;


intermType = pir_ufixpt_t( outputWL,  - outputFL );
mulType = pir_ufixpt_t( outputWL * 2,  - outputFL * 2 );
ufix1Type = pir_ufixpt_t( 1, 0 );


rootiniv = pirelab.getTypeInfoAsFi( intermType );
rootini = hN.addSignal( intermType, 'rootini' );
pirelab.getConstComp( hN, rootini, rootiniv );


rootsqiniv = pirelab.getTypeInfoAsFi( mulType );
rootsqini = hN.addSignal( mulType, 'rootsqini' );
pirelab.getConstComp( hN, rootsqini, rootsqiniv );


MSByv = pirelab.getTypeInfoAsFi( intermType, 'Floor', 'Wrap', 2 ^ ( k - outputFL - 1 ) );
MSBy = hN.addSignal( intermType, 'MSBy' );
pirelab.getConstComp( hN, MSBy, MSByv );



root = cell( 1, k );
root_sq = cell( 1, k );
resizedin = cell( 1, k );

for ii = 1:1:k

root{ ii } = hN.addSignal( intermType, sprintf( 'root%d', ii - 1 ) );
root_sq{ ii } = hN.addSignal( mulType, sprintf( 'root_sq%d', ii - 1 ) );
resizedin{ ii } = hN.addSignal( mulType, 'resizedin' );
end 




pirelab.getDTCComp( hN, hInSignals, resizedin{ k }, rndMode, 'Saturate' );


for ii = k: - 1:1



baseksqrv = pirelab.getTypeInfoAsFi( mulType, 'Floor', 'Wrap', 2 ^ ( 2 * ( ii - outputFL - 1 ) ) );
baseksqr = hN.addSignal( mulType, sprintf( 'base%dsqr', ii - 1 ) );
pirelab.getConstComp( hN, baseksqr, baseksqrv );


roottmp = hN.addSignal( intermType, sprintf( 'roottmp%d', ii - 1 ) );
roottmp_sq = hN.addSignal( mulType, sprintf( 'roottmp_sq%d', ii - 1 ) );

if ( ii == k )
pirelab.getWireComp( hN, baseksqr, roottmp_sq );
pirelab.getWireComp( hN, MSBy, roottmp );
rootsq = rootsqini;
rootplus = rootini;
else 
rootsq = root_sq{ ii + 1 };
rootplus = root{ ii + 1 };

pirelab.getBitSetComp( hN, root{ ii + 1 }, roottmp, true, ii );


pirelab.getAddComp( hN, [ root_sq{ ii + 1 }, baseksqr ], squaresum, rndMode, satMode );
pirelab.getDTCComp( hN, root{ ii + 1 }, rootdtc );
shiftLen = ii - outputFL;
if shiftLen >= 0
pirelab.getBitShiftComp( hN, rootdtc, shift2, 'sll', shiftLen );
else 
pirelab.getBitShiftComp( hN, rootdtc, shift2, 'srl',  - shiftLen );
end 
pirelab.getAddComp( hN, [ squaresum, shift2 ], roottmp_sq, rndMode, satMode );
end 



squaresum = hN.addSignal( mulType, sprintf( 'squaresum%d', ii - 1 ) );
shift2 = hN.addSignal( mulType, sprintf( 'shift2%d', ii - 1 ) );
rootdtc = hN.addSignal( mulType, sprintf( 'rootdtc%d', ii - 1 ) );
rootTmp = hN.addSignal( intermType, sprintf( 'rootTmp%d', ii - 1 ) );
root_sqTmp = hN.addSignal( mulType, sprintf( 'root_sqTmp%d', ii - 1 ) );

cmp = hN.addSignal( ufix1Type, sprintf( 'cmp%d', ii - 1 ) );
pirelab.getRelOpComp( hN, [ roottmp_sq, resizedin{ ii } ], cmp, '<=', sprintf( 'cmp%d', ii - 1 ) );

if ii > 1
pirelab.getUnitDelayComp( hN, resizedin{ ii }, resizedin{ ii - 1 } );
end 
pirelab.getSwitchComp( hN, [ rootplus, roottmp ], rootTmp, cmp );
pirelab.getUnitDelayComp( hN, rootTmp, root{ ii } );
pirelab.getSwitchComp( hN, [ rootsq, roottmp_sq ], root_sqTmp, cmp );
pirelab.getUnitDelayComp( hN, root_sqTmp, root_sq{ ii } );
end 




if ( strcmpi( rndMode, 'Nearest' ) || strcmpi( rndMode, 'Ceiling' ) )

output_ex = pirelab.getTypeInfoAsFi( outputType );
maxyv = pirelab.getTypeInfoAsFi( intermType, 'Floor', 'Wrap', realmax( output_ex ) );
maxy = hN.addSignal( intermType, 'maxy' );
pirelab.getConstComp( hN, maxy, maxyv );


lsbval = lsb( output_ex );
lsbyv = pirelab.getTypeInfoAsFi( intermType, 'Floor', 'Wrap', lsbval );
lsby = hN.addSignal( intermType, 'lsby' );
pirelab.getConstComp( hN, lsby, lsbyv );


rootout = hN.addSignal( intermType, 'rootout' );
maxcmpout = hN.addSignal( intermType, 'maxcmpout' );
cmpmax = hN.addSignal( ufix1Type, 'cmpmax' );


roComp = pirelab.getRelOpComp( hN, [ root{ ii }, maxy ], cmpmax, '<', 'cmpmax' );
roComp.addComment( sprintf( 'Add a LSB when roundmode is %s', rndMode ) );

yytemp = root_sq{ ii };
rootpluslsb = hN.addSignal( intermType, 'rootpluslsb' );
pirelab.getAddComp( hN, [ lsby, root{ ii } ], rootpluslsb, rndMode, satMode );
outsel = hN.addSignal( ufix1Type, 'outsel' );

if strcmpi( rndMode, 'Ceiling' )

cmpinzero = hN.addSignal( ufix1Type, 'cmpinzero' );
cmptempyy = hN.addSignal( ufix1Type, 'cmptempyy' );
pirelab.getCompareToValueComp( hN, resizedin{ ii }, cmpinzero, '~=', 0 );
pirelab.getRelOpComp( hN, [ yytemp, resizedin{ ii } ], cmptempyy, '<', 'cmptempyy' );
pirelab.getBitwiseOpComp( hN, [ cmpinzero, cmptempyy ], outsel, 'AND' );
else 

yypluslsb = hN.addSignal( mulType, 'yypluslsb' );


pirelab.getAddComp( hN, [ root_sq{ ii }, baseksqr ], squaresum, rndMode, satMode );
pirelab.getDTCComp( hN, root{ ii }, rootdtc );
shiftLen =  - outputFL + 1;
if shiftLen >= 0
pirelab.getBitShiftComp( hN, rootdtc, shift2, 'sll', shiftLen );
else 
pirelab.getBitShiftComp( hN, rootdtc, shift2, 'srl',  - shiftLen );
end 
pirelab.getAddComp( hN, [ squaresum, shift2 ], yypluslsb, rndMode, satMode );

sub1 = hN.addSignal( mulType, 'sub1' );
sub2 = hN.addSignal( mulType, 'sub2' );
pirelab.getSubComp( hN, [ yypluslsb, resizedin{ ii } ], sub1, rndMode, satMode );
pirelab.getSubComp( hN, [ resizedin{ ii }, yytemp ], sub2, rndMode, satMode );
pirelab.getRelOpComp( hN, [ sub1, sub2 ], outsel, '<', 'outsel' );
end 
pirelab.getSwitchComp( hN, [ root{ ii }, rootpluslsb ], rootout, outsel );
pirelab.getSwitchComp( hN, [ root{ ii }, rootout ], maxcmpout, cmpmax );
pirelab.getDTCComp( hN, maxcmpout, hOutSignals, rndMode, satMode );
else 

pirelab.getDTCComp( hN, root{ ii }, hOutSignals, rndMode, satMode );
end 

end 






% Decoded using De-pcode utility v1.2 from file /tmp/tmpqrCO1F.p.
% Please follow local copyright laws when handling this file.

