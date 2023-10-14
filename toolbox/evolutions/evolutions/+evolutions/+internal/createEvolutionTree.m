function evolutionTreeInfo = createEvolutionTree( projectInfo, treeName )

arguments
    projectInfo;
    treeName( 1, : )char = evolutions.internal.utils.getValidDefaultName( projectInfo );
end

evolutionTreeInfo = projectInfo.EvolutionTreeManager ...
    .create( convertCharsToStrings( treeName ) );
evolutionTreeInfo.save;

evolutions.internal.session.EventHandler.publish( 'EtmChanged' );
end

