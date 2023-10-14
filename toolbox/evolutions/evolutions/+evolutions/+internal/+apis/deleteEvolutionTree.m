function deleteEvolutionTree( projectId, treeId )

arguments
    projectId( 1, : )char
    treeId( 1, : )char
end

projectInfo = evolutions.internal.getDataObject( projectId );
treeInfo = evolutions.internal.getDataObject( treeId );

evolutions.internal.deleteEvolutionTree( projectInfo, treeInfo );
end




