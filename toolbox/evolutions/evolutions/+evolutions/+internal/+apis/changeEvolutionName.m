function changeEvolutionName( treeId, evolutionId, name )




R36
treeId( 1, : )char
evolutionId( 1, : )char
name( 1, : )char
end 

treeInfo = evolutions.internal.getDataObject( treeId );
evolutionInfo = evolutions.internal.getDataObject( evolutionId );

evolutions.internal.changeEvolutionName( treeInfo, evolutionInfo, name );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpmpJYyD.p.
% Please follow local copyright laws when handling this file.

