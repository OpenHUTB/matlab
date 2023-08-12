function uniqueLabel = getUniqueParameterLabel( rootParameterSpace, labelPrefix )




R36
rootParameterSpace( 1, 1 )simulink.multisim.mm.design.CombinatorialParameterSpace
labelPrefix( 1, 1 )string
end 

existingLabels = getAllLabelsOfParameterSpace( rootParameterSpace );
uniqueLabel = string( matlab.lang.makeUniqueStrings( labelPrefix, [ existingLabels, labelPrefix ] ) );
end 

function existingLabels = getAllLabelsOfParameterSpace( parameterSpace, existingLabels )
R36
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
% Decoded using De-pcode utility v1.2 from file /tmp/tmp44cV5i.p.
% Please follow local copyright laws when handling this file.

