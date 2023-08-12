function deleteEvolutionTree( projectId, treeId )




R36
projectId( 1, : )char
treeId( 1, : )char
end 

projectInfo = evolutions.internal.getDataObject( projectId );
treeInfo = evolutions.internal.getDataObject( treeId );

evolutions.internal.deleteEvolutionTree( projectInfo, treeInfo );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpdW7HQZ.p.
% Please follow local copyright laws when handling this file.

