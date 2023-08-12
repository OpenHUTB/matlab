function SRFlipFlopComp = getSRFlipFlopComp( hN, hInSignals, hOutSignals, initialQ,  ...
compName, desc, slbh )







if nargin < 7
slbh =  - 1;
end 

if nargin < 6
desc = '';
end 

if nargin < 5
compName = 'SR_Flipflop';
end 

simulinkRate = hInSignals( 1 ).SimulinkRate;

if class( hOutSignals( 1 ).Type ) == "hdlcoder.tp_double"


s_input = hN.addSignal( hdlcoder.tp_boolean, "S_boolean" );
s_input.SimulinkRate = simulinkRate;
pirelab.getDTCComp( hN, hInSignals( 1 ), s_input );

r_input = hN.addSignal( hdlcoder.tp_boolean, "R_boolean" );
r_input.SimulinkRate = simulinkRate;
pirelab.getDTCComp( hN, hInSignals( 2 ), r_input );


q_output = hN.addSignal( hdlcoder.tp_boolean, "Q_boolean" );
q_output.SimulinkRate = simulinkRate;
hOutSignals( 1 ).SimulinkRate = simulinkRate;
pirelab.getDTCComp( hN, q_output, hOutSignals( 1 ) );

q_bar_output = hN.addSignal( hdlcoder.tp_boolean, "q_bar_boolean" );
q_bar_output.SimulinkRate = simulinkRate;
hOutSignals( 2 ).SimulinkRate = simulinkRate;
pirelab.getDTCComp( hN, q_bar_output, hOutSignals( 2 ) );

else 

s_input = hInSignals( 1 );
r_input = hInSignals( 2 );
q_output = hOutSignals( 1 );
q_bar_output = hOutSignals( 2 );
end 

q_prev = hN.addSignal( hdlcoder.tp_boolean, "Previous Q" );


bitConcatOutType = hN.getType( 'FixedPoint',  ...
'Signed', 0,  ...
'WordLength', 3,  ...
'FractionLength', 0 );
bitConcatOutSig = hN.addSignal( bitConcatOutType, "InpCombined" );
pirelab.getBitConcatComp( hN, [ s_input, r_input, q_prev ], bitConcatOutSig, [ compName, '_bit_concat_comp' ] );


directLUTOutType = hN.getType( 'FixedPoint',  ...
'Signed', 0,  ...
'WordLength', 3,  ...
'FractionLength', 0 );
directLUTOutSig = hN.addSignal( directLUTOutType, "OutCombined" );
table_data = [ 1, 2, 1, 1, 2, 2, 0, 0 ];
pirelab.getDirectLookupComp( hN, bitConcatOutSig, directLUTOutSig, table_data,  ...
[ compName, 'Direct_Lookup_Table' ],  - 1, 1, 'Element', 'Error', 'fixdt(0,2,0)', 1 );




pirelab.getBitExtractComp( hN, directLUTOutSig, q_output, 1, 1, 1, [ compName, '_extract_higher_order_bit' ] );
pirelab.getBitExtractComp( hN, directLUTOutSig, q_bar_output, 0, 0, 1, [ compName, '_extract_lower_order_bit' ] );


SRFlipFlopComp = pirelab.getUnitDelayComp( hN, q_output, q_prev, [ compName, '_memory' ], initialQ, 0, desc, slbh );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpxvM1jd.p.
% Please follow local copyright laws when handling this file.

