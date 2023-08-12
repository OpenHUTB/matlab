function publishActorBehavior( modelName, options )


















R36
modelName
options.OutputFile( 1, : )char = ''
end 


actorPublisher = ssm.sl_agent_metadata.internal.ActorPublisher( modelName );


if ~isempty( options.OutputFile )
[ protoDir, protoName, ~ ] = fileparts( options.OutputFile );
actorPublisher.OutputFileBehavior = fullfile( protoDir, [ protoName, '.slprotodata' ] );
end 

actorPublisher.genBehaviorProto(  );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp49NAE6.p.
% Please follow local copyright laws when handling this file.

