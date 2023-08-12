
function relayComp = getRelayComp( hN, hC, hInSignals, hOutSignals, compName, onSwVal, offSwVal, onOpVal, offOpVal )




















if ( nargin < 9 )
offOpVal = false;
end 
if ( nargin < 8 )
onOpVal = true;
end 
if ( nargin < 7 )
offSwVal = 0.0;
end 
if ( nargin < 6 )
onSwVal = 1.0;
end 
if ( nargin < 5 )
compName = get_param( hC.SimulinkHandle, 'Name' );
end 

outType = hOutSignals.Type;


if ( ( onSwVal == offSwVal ) ...
 || ( isfloat( onSwVal ) && abs( onSwVal - offSwVal ) < eps( offSwVal ) ) )
hysteresis_mode = false;
else 
hysteresis_mode = true;
end 


onVal_sig = hN.addSignal( outType, [ compName, '_onOp_val' ] );
onVal_sig.SimulinkRate = hOutSignals.SimulinkRate;
pirelab.getConstComp( hN, onVal_sig, onOpVal );

offVal_sig = hN.addSignal( outType, [ compName, '_offOp_val' ] );
offVal_sig.SimulinkRate = hOutSignals.SimulinkRate;
pirelab.getConstComp( hN, offVal_sig, offOpVal );

if ( hysteresis_mode )



prev_sig = hN.addSignal( hOutSignals.Type, [ compName, '_FB_sig' ] );
prev_sig.SimulinkRate = hOutSignals.SimulinkRate;
delayCycles = 1;
pirelab.getIntDelayComp( hN, hOutSignals, prev_sig, delayCycles );



conn_sig = hN.addSignal( hOutSignals.Type, [ compName, '_conn_sig' ] );
conn_sig.SimulinkRate = hOutSignals.SimulinkRate;
pirelab.getSwitchComp( hN, [ onVal_sig, prev_sig ], conn_sig, hInSignals,  ...
[ compName, '_2to1MuxA' ], '>=', onSwVal );
relayComp = pirelab.getSwitchComp( hN, [ conn_sig, offVal_sig ], hOutSignals, hInSignals,  ...
[ compName, '_2to1MuxB' ], '>', offSwVal );

else 


relayComp = pirelab.getSwitchComp( hN, [ onVal_sig, offVal_sig ], hOutSignals, hInSignals,  ...
[ compName, '_2to1MUX' ], '>=', onSwVal );
end 

return 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpR8QKtt.p.
% Please follow local copyright laws when handling this file.

