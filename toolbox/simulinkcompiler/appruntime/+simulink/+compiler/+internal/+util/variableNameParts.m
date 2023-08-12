function [ varNameTop, varNameNested ] = variableNameParts( variableName )




R36
variableName( 1, : ){ mustBeNonEmptyCharOrString }
end 

parts = split( variableName, '.' );

if numel( parts ) > 1
varNameNested = parts( 2:end  );
else 
varNameNested = {  };
end 

varNameTop = parts{ 1 };
end 

function isValid = mustBeNonEmptyCharOrString( argToValidate )
isValid = ~isempty( argToValidate ) && ( ischar( argToValidate ) ||  ...
isstring( argToValidate ) );

if ~isValid
error( message( "simulinkcompiler:genapp:MustBeCharOrString", argToValidate ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpGjVCVY.p.
% Please follow local copyright laws when handling this file.

