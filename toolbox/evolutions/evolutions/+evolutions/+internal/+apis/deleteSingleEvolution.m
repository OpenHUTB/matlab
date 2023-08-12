function [ success, evolutionsDeleted ] = deleteSingleEvolution( treeId, evolutionId )




R36
treeId( 1, : )char
evolutionId( 1, : )char
end 

treeInfo = evolutions.internal.getDataObject( treeId );
evolutionInfo = evolutions.internal.getDataObject( evolutionId );

[ success, evolutionsDeleted ] = evolutions.internal.deleteSingleEvolution( treeInfo, evolutionInfo );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpy3az43.p.
% Please follow local copyright laws when handling this file.

