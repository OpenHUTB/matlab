function satComp = getSaturateDynamicComp( hN, hInSignals, hOutSignals, rndMode, satMode, compName )



if ( nargin < 6 )
compName = 'saturateDynamic';
end 

if length( hOutSignals ) < 2
if ( targetmapping.mode( hOutSignals ) )

satComp = targetmapping.getSaturationDynamicComp( hN, hInSignals, hOutSignals, compName );
else 
satComp = pircore.getSaturateDynamicComp( hN, hInSignals, hOutSignals, rndMode, satMode, compName );
end 
else 
satComp = pircore.getSaturateDynamicComp( hN, hInSignals, hOutSignals, rndMode, satMode, compName );
end 

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpblswbU.p.
% Please follow local copyright laws when handling this file.

