function updateCodeDescriptor( buildDir, pdb, taskInfoFileName, nameValuePairs )

arguments
    buildDir
    pdb
    taskInfoFileName
    nameValuePairs.TargetAddressGranularity = 1
end
targetAddressGranularity = nameValuePairs.TargetAddressGranularity;

try
    featOn = coder.internal.connectivity.featureOn( 'XcpTargetConnection' );
catch
    featOn = false;
end
if ~featOn
    return ;
end

[ taskInfo, numTasks, isDeploymentDiagram ] = coder.internal.xcp.getExtModeTaskInfo(  ...
    buildDir, taskInfoFileName );

updater = coder.internal.xcp.CodeDescriptorUpdater(  ...
    buildDir,  ...
    pdb,  ...
    taskInfo,  ...
    numTasks,  ...
    isDeploymentDiagram,  ...
    targetAddressGranularity );

updater.updateAll(  );
end


