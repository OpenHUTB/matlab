function satComp = getSaturateComp( hN, hInSignals, hOutSignals, lowerLimit, upperLimit, rndMeth, name )



if ( nargin < 7 )
name = 'saturate';
end 

if ( nargin < 6 )
rndMeth = 'Floor';
end 

if length( hOutSignals ) < 2
if ( targetmapping.mode( hOutSignals ) )

satComp = targetmapping.getSaturateComp( hN, hInSignals, hOutSignals, lowerLimit, upperLimit, name );
else 

satComp = pircore.getSaturateComp( hN, hInSignals, hOutSignals, lowerLimit, upperLimit, rndMeth, name );
end 
else 



satComp = pircore.getSaturateComp( hN, hInSignals, hOutSignals( 1 ), lowerLimit, upperLimit, rndMeth, name );
getSaturationStates( hN, hInSignals, hOutSignals( 2 ), lowerLimit, upperLimit, name );
end 

end 


function getSaturationStates( hN, hInSignals, hOutSignals, lowerLimit, upperLimit, name )
















upSig = hN.addSignal( hOutSignals( 1 ).Type, [ name, '_saturate_up' ] );
lowSig = hN.addSignal( hOutSignals( 1 ).Type, [ name, '_saturate_low' ] );

upLimitSig = hN.addSignal( hInSignals( 1 ).Type, [ name, '_upperLimit' ] );
lowLimitSig = hN.addSignal( hInSignals( 1 ).Type, [ name, '_lowerLimit' ] );


sigRate = hInSignals( 1 ).SimulinkRate;
upLimitSig.SimulinkRate = sigRate;
lowLimitSig.SimulinkRate = sigRate;

pirelab.getConstComp( hN, upLimitSig, double( upperLimit ), [ name, '_upperLimit' ] );
pirelab.getConstComp( hN, lowLimitSig, double( lowerLimit ), [ name, '_lowerLimit' ] );

pirelab.getRelOpComp( hN, [ hInSignals( 1 ), upLimitSig ], upSig, '>=', true, [ name, '_above_upper' ] );
pirelab.getRelOpComp( hN, [ hInSignals( 1 ), lowLimitSig ], lowSig, '<=', true, [ name, '_below_lower' ] );

if upperLimit == lowerLimit

finalSig = hN.addSignal( hOutSignals( 1 ).Type, [ name, '_saturate_equal' ] );



pirelab.getAddComp( hN, [ upSig, lowSig ], finalSig, [  ], [  ], [ name, '_sat_mode' ], [  ], '+-' );

pirelab.getSwitchComp( hN, [ finalSig, upSig ], hOutSignals( 1 ), finalSig, [ name, '_mux' ], '~=', 0 );
else 


pirelab.getAddComp( hN, [ upSig, lowSig ], hOutSignals( 1 ), [  ], [  ], [ name, '_sat_mode' ], [  ], '+-' );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpFZL8eZ.p.
% Please follow local copyright laws when handling this file.

