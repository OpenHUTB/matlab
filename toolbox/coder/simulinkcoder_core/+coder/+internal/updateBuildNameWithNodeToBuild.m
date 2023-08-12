function buildName = updateBuildNameWithNodeToBuild( buildName )







[ hasMultipleNodes, nodeToBuild ] =  ...
Simulink.DistributedTarget.DistributedTargetUtils.hasMultipleSoftwareNodes( buildName );
if hasMultipleNodes
buildName = [ buildName, '_', nodeToBuild ];
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp5WZbbm.p.
% Please follow local copyright laws when handling this file.

