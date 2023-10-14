function changeEvolutionName( treeId, evolutionId, name )


arguments
    treeId( 1, : )char
    evolutionId( 1, : )char
    name( 1, : )char
end

treeInfo = evolutions.internal.getDataObject( treeId );
evolutionInfo = evolutions.internal.getDataObject( evolutionId );

evolutions.internal.changeEvolutionName( treeInfo, evolutionInfo, name );
end


