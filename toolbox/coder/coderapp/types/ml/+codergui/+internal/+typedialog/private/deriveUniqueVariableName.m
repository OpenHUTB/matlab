function varName = deriveUniqueVariableName( nameSeed, takenVarNames, initCount )

arguments
    nameSeed char
    takenVarNames cell
    initCount double = 1
end

nameSeed = regexprep( strtrim( nameSeed ), '[\d]+$', '', 'once' );
clashables = takenVarNames( startsWith( takenVarNames, nameSeed ) );

counter = initCount;
varName = nameSeed;
while ismember( varName, clashables )
    varName = sprintf( '%s%d', nameSeed, counter );
    counter = counter + 1;
end
end


