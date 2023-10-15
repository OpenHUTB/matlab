function simInput = removeSimOnlyParams( simInput )
arguments
    simInput( 1, 1 )Simulink.SimulationInput
end

import Simulink.Simulation.internal.simOnlyParams;

modelParamNames = string( { simInput.ModelParameters.Name } );
caseInsensitiveStableSetdiff = @( setA, setB )setdiff( lower( setA ), lower( setB ), "stable" );
[ ~, nonSimOnlyParamsIdx ] = caseInsensitiveStableSetdiff( modelParamNames, simOnlyParams(  ) );
simInput.ModelParameters = simInput.ModelParameters( nonSimOnlyParamsIdx );
end
