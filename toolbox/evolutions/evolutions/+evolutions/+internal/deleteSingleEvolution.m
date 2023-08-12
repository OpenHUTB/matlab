function [ success, evolutionsDeleted ] = deleteSingleEvolution( currentTreeInfo, evolutionInfo )




R36
currentTreeInfo( 1, : )evolutions.model.EvolutionTreeInfo;
evolutionInfo( 1, : )evolutions.model.EvolutionInfo;
end 


[ ~, artifactIds ] = evolutions.internal.utils.getBaseToArtifactsKeyValues( evolutionInfo );


evolutionsDeleted = { evolutionInfo.getName };
evolutions.internal.tree.utils.deleteSingleEvolution( currentTreeInfo, evolutionInfo );

currentTreeInfo.save;


evolutions.internal.artifactserver.deleteArtifacts( currentTreeInfo, artifactIds );

success = true;

evolutions.internal.session.EventHandler.publish( 'TreeChanged',  ...
evolutions.internal.ui.GenericEventData( currentTreeInfo ) );



% Decoded using De-pcode utility v1.2 from file /tmp/tmpZHEnRy.p.
% Please follow local copyright laws when handling this file.

