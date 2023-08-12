function [ success, output ] = createEvolution( currentTreeInfo, evolutionName )




R36
currentTreeInfo;
evolutionName( 1, : )char = evolutions.internal.utils.getValidDefaultName( currentTreeInfo );
end 


evolutions.internal.syncActiveWithProject( currentTreeInfo );


output = struct( 'message', '' );
success = false;%#ok<NASGU>

bfiToAfi = containers.Map;
bfis = evolutions.internal.utils.getBaseToArtifactsKeyValues ...
( currentTreeInfo.EvolutionManager.WorkingEvolution );




files = { bfis.File };
findNonExistentFile = cellfun( @( x )~isfile( x ), files );
files( findNonExistentFile ) = [  ];

if ~isequal( numel( files ), numel( bfis ) )
output = MException( 'evolutions:manage:ProjectStateError', getString( message ...
( 'evolutions:manage:ProjectStateError' ) ) );
success = false;
return ;
end 

for idx = 1:numel( bfis )
bfi = bfis( idx );
afi = evolutions.internal.artifactserver.createArtifacts( currentTreeInfo, bfi );
bfiToAfi( bfi.Id ) = afi;
end 

evolutions.internal.tree.utils.createEvolution( currentTreeInfo, evolutionName, bfiToAfi );
currentTreeInfo.save;

success = true;


evolutions.internal.session.EventHandler.publish( 'EvolutionCreated',  ...
evolutions.internal.ui.GenericEventData( currentTreeInfo ) );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpZvLMbt.p.
% Please follow local copyright laws when handling this file.

