function updateCodeDescriptor( buildDir, pdb, taskInfoFileName, nameValuePairs )






R36
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

% Decoded using De-pcode utility v1.2 from file /tmp/tmpGzyE2I.p.
% Please follow local copyright laws when handling this file.

