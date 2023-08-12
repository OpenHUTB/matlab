function hNewC = scmGetSumOfElements( hN, hInSignals, hOutSignals, nfpOptions, earlyElaborate )




if length( hInSignals ) == 1
demuxComp = pirelab.getDemuxCompOnInput( hN, hInSignals );
demuxOutSignal = demuxComp.PirOutputSignals;
else 
demuxOutSignal = hInSignals;
end 


dimLen = length( demuxOutSignal );
numStages = ceil( log2( dimLen ) );

structSignalsIn = demuxOutSignal;

for ii = 1:numStages
inputLen = length( structSignalsIn );
stageLen = ceil( inputLen / 2 );

tInType = structSignalsIn( 1 ).Type.getLeafType;
tOutType = tInType;
structSignalsOut = getOneStageOutputSignal( hN, tOutType, stageLen, ii );

tComp = elabTreeStage( hN, structSignalsIn, structSignalsOut, nfpOptions, earlyElaborate );


if stageLen == 1
hNewC = tComp;
end 


structSignalsIn = structSignalsOut;

end 
pirelab.getWireComp( hN, structSignalsOut, hOutSignals );
end 

function tSignalsOut = getOneStageOutputSignal( hN, tOutType, stageLen, stageNum )
tSignalsOut = hdlhandles( stageLen, 1 );
for ii = 1:stageLen
toutName = sprintf( 'sum_stage%d_%d', stageNum, ii );
tSignalsOut( ii ) = hN.addSignal( tOutType, toutName );
end 
end 

function treeComp = elabTreeStage( hN, structSignalsIn, structSignalsOut, nfpOptions, earlyElaborate )

hInSignals = structSignalsIn;
hOutSignals = structSignalsOut;

inputLen = length( hInSignals );
inputLenOdd = ( mod( inputLen, 2 ) == 1 );


numOps = floor( inputLen / 2 );


for ii = 1:numOps
opInSignals = hInSignals( ii * 2 - 1:ii * 2 );
opOutSignals = hOutSignals( ii );
if earlyElaborate
treeComp = pirelab.getAddComp( hN, opInSignals, opOutSignals, 'floor', 'wrap', 'adder' );
else 

treeComp = hN.addComponent2(  ...
'kind', 'target_add_comp',  ...
'SimulinkHandle',  - 1,  ...
'name', 'adder',  ...
'InputSignals', opInSignals,  ...
'OutputSignals', opOutSignals );
end 
treeComp.setNFPLatency( nfpOptions.LatencyStrategy );
treeComp.setNFPCustomLatency( nfpOptions.CustomLatency );
end 


if inputLenOdd
if ~earlyElaborate


if nfpOptions.LatencyStrategy == 4
treeLatency = nfpOptions.CustomLatency;
else 
treeLatency = targetcodegen.targetCodeGenerationUtils.resolveLatencyForComp( treeComp );
end 
hDelayC = pirelab.getIntDelayComp( hN, hInSignals( end  ), hOutSignals( end  ), treeLatency );%#ok<NASGU>
else 
pirelab.getWireComp( hN, hInSignals( end  ), hOutSignals( end  ) );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp0P76w8.p.
% Please follow local copyright laws when handling this file.

