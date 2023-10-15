function [ varNameTop, varNameNested ] = variableNameParts( variableName )

arguments
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

