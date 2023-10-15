function validateMLname( Name, Description )

arguments
    Name
    Description( 1, : )char = 'name'
end


if ~isvarname( Name )
    validateattributes( Name, { 'char' }, { 'row' }, '', Description );

    error( message( 'antenna:antennaerrors:ValidateMLNameNotAVarName', Description, Name ) );
end
end
