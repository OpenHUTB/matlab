function publishActorBehavior( modelName, options )

arguments
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

