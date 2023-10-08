function changeEvolutionTreeName( treeId, name )


R36
treeId( 1, : )char
name( 1, : )char
end 

treeInfo = evolutions.internal.getDataObject( treeId );

evolutions.internal.changeEvolutionTreeName( treeInfo, evolutionInfo, name );

end 


