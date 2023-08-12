function changeEvolutionTreeName( treeId, name )




R36
treeId( 1, : )char
name( 1, : )char
end 

treeInfo = evolutions.internal.getDataObject( treeId );

evolutions.internal.changeEvolutionTreeName( treeInfo, evolutionInfo, name );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpBheu14.p.
% Please follow local copyright laws when handling this file.

