function publishActor( modelName, options )






















R36
modelName
options.PackageType = 'ActorNormal'
options.SetupScript = ''
options.CleanupScript = ''
options.OutputFile( 1, : )char = ''
options.DataFiles = ""
end 


[ ~, modelName, ~ ] = fileparts( modelName );
actorPublisher = ssm.sl_agent_metadata.internal.ActorPublisher( modelName );


if isempty( options.OutputFile )
actorPublisher.OutputFileBehavior = fullfile( pwd, [ modelName, '.slprotodata' ] );
actorPublisher.OutputFilePackage = fullfile( pwd, [ modelName, '.zip' ] );
else 
[ pkgDir, pkgName, ~ ] = fileparts( options.OutputFile );
actorPublisher.OutputFileBehavior = fullfile( pkgDir, [ pkgName, '.slprotodata' ] );
actorPublisher.OutputFilePackage = fullfile( pkgDir, [ pkgName, '.zip' ] );
end 


actorPublisher.PackageType = options.PackageType;
actorPublisher.SetupScript = options.SetupScript;
actorPublisher.CleanupScript = options.CleanupScript;
actorPublisher.DataFiles = options.DataFiles;

actorPublisher.genBehaviorProto(  );
actorPublisher.genMetadata(  );

actorPublisher.getDependencies(  );

actorPublisher.generateArtifacts(  );

actorPublisher.createPackage(  );

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpn34KmJ.p.
% Please follow local copyright laws when handling this file.

