function propTable = vector2table( PropertyNames, PropertyValues )

arguments
    PropertyNames( 1, : )string
    PropertyValues{ mustBeVector }
end
if iscell( PropertyValues )
    propTable = cell2table( PropertyValues, "VariableNames", PropertyNames );
else
    propTable = array2table( PropertyValues, "VariableNames", PropertyNames );
end
end
