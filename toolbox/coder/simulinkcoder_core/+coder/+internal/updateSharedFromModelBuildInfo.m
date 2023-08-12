function updateSharedFromModelBuildInfo( modelBuildInfo )





[ lHasSharedLib, ~, ~, sharedSrcLinkObject ] =  ...
coder.internal.hasSharedLib( modelBuildInfo );

if lHasSharedLib
sharedSrcBuildInfo = sharedSrcLinkObject.BuildInfoHandle;
isUpToDate = coder.internal.updateSharedSourceBuildInfo ...
( sharedSrcBuildInfo, modelBuildInfo );

if ~isUpToDate

sharedSrcLinkObject.BuildInfoDirty = true;
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpOjcwbg.p.
% Please follow local copyright laws when handling this file.

