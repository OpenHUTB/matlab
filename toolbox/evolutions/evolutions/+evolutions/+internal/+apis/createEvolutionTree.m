function evolutionTreeInfoIdentifier = createEvolutionTree( projectId, treeName )

arguments
    projectId( 1, : )char
    treeName( 1, : )char
end

projectInfo = evolutions.internal.getDataObject( projectId );
evolutionTreeInfo = evolutions.internal.createEvolutionTree( projectInfo, treeName );
evolutionTreeInfoIdentifier = evolutionTreeInfo.Id;

end



