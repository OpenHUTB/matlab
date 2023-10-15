function variables = getVariablesFromModelParameters( simInput, exemptedModelParameters )
arguments
    simInput( 1, 1 )Simulink.SimulationInput
    exemptedModelParameters( 1, : )cell{ mustBeCellArrayOfScalarText } = { 'simulationmode', 'rapidacceleratoruptodatecheck' }
end
variables = string( {  } );

for i = 1:length( simInput.ModelParameters )
    processParameter =  ...
        matlab.internal.datatypes.isScalarText( simInput.ModelParameters( i ).Value ) &&  ...
        ~any( strcmpi( simInput.ModelParameters( i ).Name, exemptedModelParameters ) );

    if processParameter
        newVariables = Simulink.RapidAccelerator.internal.extractVariablesFromExpression(  ...
            simInput.ModelParameters( i ).Value ...
            );
        variables = string( [ variables, newVariables ] );
    end
end
end

function mustBeCellArrayOfScalarText( x )
isCellArrayOfScalarText =  ...
    @( x )iscell( x ) &&  ...
    all( cellfun( @( z )matlab.internal.datatypes.isScalarText( z ), x ) );

if ~isCellArrayOfScalarText( x )
    error( 'Input must be a cell array of scalar text' );
end
end

