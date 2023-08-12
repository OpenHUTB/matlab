function [ variable, index ] = variableFromVariableSet( variableName, variableSet )




R36
variableName( 1, : ){ mustBeNonEmptyCharOrString }
variableSet( :, : )Simulink.Simulation.Variable
end 

variable = [  ];

variableNames = { variableSet.Name };
index = strcmp( variableName, variableNames );

if ~any( index )
index = [  ];
return 
end 

index = find( index == 1 );

assert( isequal( numel( index ), 1 ), 'Simulink:Compiler:VariableNameNotUniqueInSet',  ...
message( 'simulinkcompiler:genapp:VariableNameNotUnique', variableName ).getString );

variable = variableSet( index );
end 

function isValid = mustBeNonEmptyCharOrString( argToValidate )
isValid = ~isempty( argToValidate ) && ( ischar( argToValidate ) ||  ...
isstring( argToValidate ) );

if ~isValid
error( message( "simulinkcompiler:genapp:MustBeCharOrString", argToValidate ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpFpqx0Q.p.
% Please follow local copyright laws when handling this file.

