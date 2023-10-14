function TimerPluginForDeployment( codeDescriptor, impFolder, buildInfo )

arguments
    codeDescriptor( 1, 1 )coder.codedescriptor.CodeDescriptor
    impFolder( 1, : )char
    buildInfo( 1, 1 )RTW.BuildInfo
end

assert( isfolder( impFolder ) );

pluginContext = coder.internal.rte.PluginContext.Deployment;
implementationFilename = coder.internal.rte.util.TimerFilenameForDeployment;
privateHeaderFilename = 'rte_private_timer.h';
tObj = coder.internal.rte.TimingServiceGenerator(  ...
    pluginContext, implementationFilename, privateHeaderFilename, impFolder );
tObj.generateRTEImplementation( codeDescriptor );

buildInfo.addIncludePaths( impFolder );
buildInfo.addSourceFiles( fullfile( impFolder, implementationFilename ) );
end

