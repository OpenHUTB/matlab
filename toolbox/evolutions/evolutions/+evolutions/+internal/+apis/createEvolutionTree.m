function evolutionTreeInfoIdentifier = createEvolutionTree( projectId, treeName )




R36
projectId( 1, : )char
treeName( 1, : )char
end 

projectInfo = evolutions.internal.getDataObject( projectId );
evolutionTreeInfo = evolutions.internal.createEvolutionTree( projectInfo, treeName );
evolutionTreeInfoIdentifier = evolutionTreeInfo.Id;

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp9o0Rhp.p.
% Please follow local copyright laws when handling this file.

