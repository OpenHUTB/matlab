function simInput = removeSimOnlyParams( simInput )
R36
simInput( 1, 1 )Simulink.SimulationInput
end 

import Simulink.Simulation.internal.simOnlyParams;

modelParamNames = string( { simInput.ModelParameters.Name } );
caseInsensitiveStableSetdiff = @( setA, setB )setdiff( lower( setA ), lower( setB ), "stable" );
[ ~, nonSimOnlyParamsIdx ] = caseInsensitiveStableSetdiff( modelParamNames, simOnlyParams(  ) );
simInput.ModelParameters = simInput.ModelParameters( nonSimOnlyParamsIdx );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpPwWk10.p.
% Please follow local copyright laws when handling this file.

