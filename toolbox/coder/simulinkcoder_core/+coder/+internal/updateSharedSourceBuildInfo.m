function buildInfoSharedIsUpToDate = updateSharedSourceBuildInfo( sharedSrcBuildInfo, donorBuildInfo )








if isempty( sharedSrcBuildInfo )
buildInfoSharedIsUpToDate = true;
return 
end 

buildInfoSharedIsUpToDate = true;





excludeGroups = { 'MDLREF', 'RelativeIncPaths', 'BuildDir' };
[ allIncPaths, allIncPathGroups ] = getIncludePaths ...
( donorBuildInfo, false, {  }, excludeGroups );
existingIncPaths = getIncludePaths( sharedSrcBuildInfo, false );
[ ~, newIncludePathsIdx ] = setdiff( allIncPaths, existingIncPaths, 'stable' );
if ~isempty( newIncludePathsIdx )
addIncludePaths( sharedSrcBuildInfo,  ...
allIncPaths( newIncludePathsIdx ),  ...
allIncPathGroups( newIncludePathsIdx ) );
buildInfoSharedIsUpToDate = false;
end 


recipientBuildInfoIsUpToDate = coder.internal.mergeBuildInfoContent( donorBuildInfo, sharedSrcBuildInfo );

buildInfoSharedIsUpToDate = buildInfoSharedIsUpToDate && recipientBuildInfoIsUpToDate;

% Decoded using De-pcode utility v1.2 from file /tmp/tmpBlVsf2.p.
% Please follow local copyright laws when handling this file.

