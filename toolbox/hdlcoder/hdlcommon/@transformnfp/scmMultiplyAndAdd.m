function dotProductSignals = scmMultiplyAndAdd( hN, sharedRowSignals, sharedColumnSignals,  ...
selOut, numDelays, earlyElaborate, multiplyAddMap, nfpCustomLatency )






p = pir( hN.getCtxName );

nonzeroRowIdx = 1;

dotProductSignals = [  ];


numAdders = 0;
numMultipliers = 0;
numConstants = 0;

for ii = 1:numel( selOut )

if selOut( ii )

assert( nonzeroRowIdx <= ii );
rowSignal = sharedRowSignals( nonzeroRowIdx );
colSignal = sharedColumnSignals( nonzeroRowIdx );
nonzeroRowIdx = nonzeroRowIdx + 1;



nicOutSignal = hN.addSignal( getPirSignalLeafType( rowSignal.Type ), [ 'dot_product', num2str( ii ) ] );
nicOutSignal.SimulinkRate = rowSignal.SimulinkRate;



dotProductSize = num2str( getNumElementsInSignal( rowSignal ) );

multiplyAddMapKey = [ dotProductSize, num2str( nicOutSignal.SimulinkRate ) ];
if multiplyAddMap.isKey( multiplyAddMapKey )


hRefN = multiplyAddMap( multiplyAddMapKey );

createNICComp( hN, hRefN, rowSignal, colSignal, nicOutSignal, dotProductSize );
nicOutSignal.Type = hRefN.PirOutputSignals( 1 ).Type;
dotProductSignals = [ dotProductSignals, nicOutSignal ];%#ok<AGROW>
else 

newhN = p.addNetwork;
newName = [ 'dot_product_', dotProductSize ];
newhN.Name = newName;
newhN.FullPath = newName;
multiplyAddMap( multiplyAddMapKey ) = newhN;


newhN.addInputPort( 'in1' );
newhN.addInputPort( 'in2' );
newhN.addOutputPort( 'out1' );



mulInSignal1 = newhN.addSignal( rowSignal.Type, 'mul_in1' );
mulInSignal1.SimulinkRate = rowSignal.SimulinkRate;
mulInSignal1.addDriver( newhN, 0 );
mulInSignal2 = newhN.addSignal( colSignal.Type, 'mul_in2' );
mulInSignal2.SimulinkRate = colSignal.SimulinkRate;
mulInSignal2.addDriver( newhN, 1 );

mulOutSignal = newhN.addSignal( rowSignal.Type, 'mul_out1' );
mulOutSignal.SimulinkRate = rowSignal.SimulinkRate;




nfpOptions = scmGetNFPOptions( nfpCustomLatency );


if earlyElaborate

mulComp = pirelab.getMulComp( newhN, [ mulInSignal1, mulInSignal2 ], mulOutSignal );
else 

mulComp = newhN.addComponent2(  ...
'kind', 'target_mul_comp',  ...
'SimulinkHandle',  - 1,  ...
'name', 'multiplier',  ...
'InputSignals', [ mulInSignal1, mulInSignal2 ],  ...
'OutputSignals', mulOutSignal );
end 

mulComp.setNFPLatency( nfpOptions.LatencyStrategy );
mulComp.setNFPCustomLatency( nfpOptions.CustomLatency );
mulComp.setNFPDenormals( nfpOptions.HandleDenormals );
mulComp.setNFPMantMul( nfpOptions.MantissaMultiplyStrategy );


if mulOutSignal.Type.isArrayType


sumOutSignal = newhN.addSignal( getPirSignalLeafType( mulOutSignal.Type ), 'sum_out1' );
sumOutSignal.SimulinkRate = mulOutSignal.SimulinkRate;


numMultipliers = numMultipliers + mulOutSignal.Type.Dimensions;
numAdders = numAdders + ( mulOutSignal.Type.Dimensions - 1 );


sumComp = transformnfp.scmGetSumOfElements( newhN, mulOutSignal, sumOutSignal, nfpOptions, earlyElaborate );

if ~earlyElaborate

[ numElements, ~ ] = pirelab.getVectorTypeInfo( mulOutSignal );

numStagesOfTreeArch = ceil( log2( numElements ) );


if nfpOptions.LatencyStrategy == 4
currentDelay = nfpOptions.CustomLatency * 1 +  ...
nfpOptions.CustomLatency * numStagesOfTreeArch;
else 
currentDelay = targetcodegen.targetCodeGenerationUtils.resolveLatencyForComp( mulComp ) * 1 +  ...
targetcodegen.targetCodeGenerationUtils.resolveLatencyForComp( sumComp ) * numStagesOfTreeArch;
end 

deltaDelay = numDelays - currentDelay;
delayOutSignal = addPipelineDelay( newhN, sumOutSignal, deltaDelay );

delayOutSignal.addReceiver( newhN, 0 );
nicOutSignal.Type = delayOutSignal.Type;
else 
sumOutSignal.addReceiver( newhN, 0 );
nicOutSignal.Type = sumOutSignal.Type;
end 
else 

numMultipliers = numMultipliers + 1;

if ~earlyElaborate

currentDelay = targetcodegen.targetCodeGenerationUtils.resolveLatencyForComp( mulComp ) * 1;

deltaDelay = numDelays - currentDelay;
delayOutSignal = addPipelineDelay( newhN, mulOutSignal, deltaDelay );

delayOutSignal.addReceiver( newhN, 0 );
nicOutSignal.Type = delayOutSignal.Type;
else 
mulOutSignal.addReceiver( newhN, 0 );
nicOutSignal.Type = mulOutSignal.Type;
end 
end 

createNICComp( hN, newhN, rowSignal, colSignal, nicOutSignal, dotProductSize );
dotProductSignals = [ dotProductSignals, nicOutSignal ];%#ok<AGROW>
end 
else 

numConstants = numConstants + 1;

constOutSignal = hN.addSignal( getPirSignalLeafType( sharedRowSignals( 1 ).Type ), 'const0' );
constOutSignal.SimulinkRate = sharedRowSignals( 1 ).SimulinkRate;
pirelab.getConstComp( hN, constOutSignal, 0 );

dotProductSignals = [ dotProductSignals, constOutSignal ];%#ok<AGROW>
end 
end 
end 


function delayOutSignal = addPipelineDelay( hN, inSignal, numDelays )
delayOutSignal = hN.addSignal( inSignal.Type, 'delayoutput' );
delayOutSignal.SimulinkRate = inSignal.SimulinkRate;
pirelab.getIntDelayComp( hN, inSignal, delayOutSignal, numDelays );
end 


function numElements = getNumElementsInSignal( signal )
if ~signal.Type.isArrayType
numElements = 1;
else 
numElements = signal.Type.Dimensions;
end 
end 


function createNICComp( hN, hRefN, inSig1, inSig2, outSig, dotProductSize )
nicComp = hN.addComponent( 'ntwk_instance_comp', hRefN );
nicName = [ 'dot_product_', dotProductSize ];
nicComp.Name = nicName;
pirelab.connectNtwkInstComp( nicComp, [ inSig1, inSig2 ], outSig );
end 

function nfpOptions = scmGetNFPOptions( nfpCustomLatency )


nfpOptions = struct;


globalLatencyStrategy = lower( targetcodegen.targetCodeGenerationUtils.getConfigurationObject.LibrarySettings.LatencyStrategy );
switch globalLatencyStrategy
case 'max'
nfpOptions.LatencyStrategy = 1;
case 'min'
nfpOptions.LatencyStrategy = 2;
case 'zero'
nfpOptions.LatencyStrategy = 3;
otherwise 

nfpOptions.LatencyStrategy = 0;
end 


if nfpCustomLatency >= 0
nfpOptions.LatencyStrategy = 4;
nfpOptions.CustomLatency = nfpCustomLatency;
else 
nfpOptions.CustomLatency = abs( nfpCustomLatency );
end 


globalHandleDenormals = targetcodegen.targetCodeGenerationUtils.getConfigurationObject.LibrarySettings.HandleDenormals;
if strcmpi( globalHandleDenormals, 'off' )
nfpOptions.HandleDenormals = 2;
elseif strcmpi( globalHandleDenormals, 'on' )
nfpOptions.HandleDenormals = 1;
else 

nfpOptions.HandleDenormals = 0;
end 


globalMantissaMultiplyStrategy = lower( targetcodegen.targetCodeGenerationUtils.getConfigurationObject.LibrarySettings.MantissaMultiplyStrategy );
switch globalMantissaMultiplyStrategy
case 'auto'

nfpOptions.MantissaMultiplyStrategy = 1;
case 'fullmultiplier'
nfpOptions.MantissaMultiplyStrategy = 1;
case 'partmultiplierpartaddshift'
nfpOptions.MantissaMultiplyStrategy = 2;
case 'nomultiplierfulladdshift'
nfpOptions.MantissaMultiplyStrategy = 3;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpysUi1E.p.
% Please follow local copyright laws when handling this file.

