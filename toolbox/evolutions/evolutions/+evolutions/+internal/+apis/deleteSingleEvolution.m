function [ success, evolutionsDeleted ] = deleteSingleEvolution( treeId, evolutionId )

arguments
    treeId( 1, : )char
    evolutionId( 1, : )char
end

treeInfo = evolutions.internal.getDataObject( treeId );
evolutionInfo = evolutions.internal.getDataObject( evolutionId );

[ success, evolutionsDeleted ] = evolutions.internal.deleteSingleEvolution( treeInfo, evolutionInfo );
end


