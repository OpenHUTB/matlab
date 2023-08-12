function hC = getNonRestoreDivideComp( hN, hInSignals, hOutSignals, divideInfo )





d1InType = hInSignals( 1 ).Type;
d2InType = hInSignals( 2 ).Type;
if d1InType.isArrayType
Nsignals = d1InType.getDimensions;



out_ports = { 'quotient_out' };
out_types = hOutSignals( 1 ).Type;
for itr = 2:length( hOutSignals )
out_ports{ itr } = [ 'quotient_out', int2str( itr ) ];
out_types( itr ) = hOutSignals( itr ).Type;
end 

hCoreNet = pirelab.createNewNetwork(  ...
'Network', hN,  ...
'Name', 'divide_nw',  ...
'InportNames', { 'dividend_in', 'divisor_in' },  ...
'InportTypes', [ d1InType, d2InType ],  ...
'InportRates', [ hInSignals( 1 ).SimulinkRate, hInSignals( 2 ).SimulinkRate ],  ...
'OutportNames', out_ports,  ...
'OutportTypes', out_types );

for itr = 1:length( hOutSignals )
hCoreNet( 1 ).PirOutputSignals( itr ).SimulinkRate = hOutSignals( itr ).SimulinkRate;
end 


hC = pirelab.instantiateNetwork( hN, hCoreNet, hInSignals,  ...
hOutSignals, [ 'divide', '_', int2str( Nsignals ) ] );



hCoreNet_InSignals = hCoreNet.PirInputSignals;
hCoreNet_OutSignals = hCoreNet.PirOutputSignals;
arrIn1Splitter = hCoreNet_InSignals( 1 ).split.PirOutputSignals;
if ~d2InType.isArrayType


arrIn2Splitter = repmat( hCoreNet_InSignals( 2 ), 1, Nsignals );
else 
arrIn2Splitter = hCoreNet_InSignals( 2 ).split.PirOutputSignals;
end 
for itr = length( hOutSignals ): - 1:1
outSplitter( itr ) = pirelab.getMuxOnOutput( hCoreNet, hCoreNet_OutSignals( itr ) );
end 
arr_DivideOutSignals = cell( length( hOutSignals ), 1 );
for itr = length( hOutSignals ): - 1:1
arr_DivideOutSignals{ itr } = outSplitter( itr ).PirInputSignals;
end 


for itr = 1:Nsignals
arr_out_signals = [  ];
for itr2 = length( hOutSignals ): - 1:1
outsig = arr_DivideOutSignals{ itr2 }( itr );
outsig.SimulinkRate = arrIn1Splitter( itr ).SimulinkRate;
arr_out_signals = [ outsig, arr_out_signals( : ) ];
end 
elaborate_scalar( hCoreNet, [ arrIn1Splitter( itr ), arrIn2Splitter( itr ) ], arr_out_signals, divideInfo );
end 
else 

hC = elaborate_scalar( hN, hInSignals, hOutSignals, divideInfo );
end 
end 
function hC = elaborate_scalar( hN, hInSignals, hOutSignals, divideInfo )

hNonRestoreNet = pirelab.getNonRestoreDivideNetwork( hN, hInSignals, hOutSignals, divideInfo );

hC = pirelab.instantiateNetwork( hN, hNonRestoreNet, hInSignals, hOutSignals, 'divide' );
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpclkyxC.p.
% Please follow local copyright laws when handling this file.

