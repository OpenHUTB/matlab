function evolutionTreeInfo = createEvolutionTree( projectInfo, treeName )




R36
projectInfo;
treeName( 1, : )char = evolutions.internal.utils.getValidDefaultName( projectInfo );
end 

evolutionTreeInfo = projectInfo.EvolutionTreeManager ...
.create( convertCharsToStrings( treeName ) );
evolutionTreeInfo.save;

evolutions.internal.session.EventHandler.publish( 'EtmChanged' );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpF3hwVB.p.
% Please follow local copyright laws when handling this file.

