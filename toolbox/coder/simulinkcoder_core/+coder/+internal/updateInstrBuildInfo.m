function updateInstrBuildInfo( lBuildInfoInstr, lInstrObjFolder )






instrFolder = [ filesep, lInstrObjFolder ];
[ lHasSharedLib, ~, ~, sharedSrcLinkObject ] = coder.internal.hasSharedLib( lBuildInfoInstr );
if ~lHasSharedLib || isempty( sharedSrcLinkObject ) || isempty( sharedSrcLinkObject.BuildInfoHandle )
return ;
end 
lSharedBuildInfo = sharedSrcLinkObject.BuildInfoHandle;
for i = 1:length( lSharedBuildInfo.Src.Files )
p = lSharedBuildInfo.Src.Files( i ).Path;
if endsWith( p, instrFolder )
lSharedBuildInfo.Src.Files( i ).Path = fileparts( p );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpJ7SCO4.p.
% Please follow local copyright laws when handling this file.

