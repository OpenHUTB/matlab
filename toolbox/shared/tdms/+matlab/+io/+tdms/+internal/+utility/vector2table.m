function propTable = vector2table( PropertyNames, PropertyValues )



R36
PropertyNames( 1, : )string
PropertyValues{ mustBeVector }
end 
if iscell( PropertyValues )
propTable = cell2table( PropertyValues, "VariableNames", PropertyNames );
else 
propTable = array2table( PropertyValues, "VariableNames", PropertyNames );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpghwtQp.p.
% Please follow local copyright laws when handling this file.

