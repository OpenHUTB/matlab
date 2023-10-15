function uniqueLabel = getUniqueParameterLabel( rootParameterSpace, labelPrefix )

arguments
    rootParameterSpace( 1, 1 )simulink.multisim.mm.design.CombinatorialParameterSpace
    labelPrefix( 1, 1 )string
end

existingLabels = getAllLabelsOfParameterSpace( rootParameterSpace );
uniqueLabel = string( matlab.lang.makeUniqueStrings( labelPrefix, [ existingLabels, labelPrefix ] ) );
end

function existingLabels = getAllLabelsOfParameterSpace( parameterSpace, existingLabels )
arguments
    parameterSpace( 1, 1 )simulink.multisim.mm.design.CombinatorialParameterSpace
    existingLabels( 1, : )string = string.empty
end

existingParameterSpaces = parameterSpace.ParameterSpaces.toArray(  );
for childParameterSpace = existingParameterSpaces
    existingLabels = [ existingLabels, childParameterSpace.Label ];
    if isa( childParameterSpace, "simulink.multisim.mm.design.CombinatorialParameterSpace" )
        existingLabels = getAllLabelsOfParameterSpace( childParameterSpace, existingLabels );
    end
end
end
