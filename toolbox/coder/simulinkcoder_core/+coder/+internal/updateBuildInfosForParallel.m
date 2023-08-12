function updateBuildInfosForParallel( lBuildInfo, parallelBuildRecompile,  ...
lAnchorFolder, clientAnchorDir )












if ~parallelBuildRecompile
i_clientAnchorFolderUpdate( lBuildInfo, clientAnchorDir );
end 








i_sharedUtilsBuildInfosUpdate( lBuildInfo, lAnchorFolder, clientAnchorDir );


function i_sharedUtilsBuildInfosUpdate( lBuildInfo, lAnchorFolder, clientAnchorDir )





[ ~, lSharedLibPath, ~, sharedSrcLinkObjectUpdated ] =  ...
coder.internal.hasSharedLib( lBuildInfo );
if isempty( sharedSrcLinkObjectUpdated )
sharedSrcBuildInfoUpdated = [  ];
else 
sharedSrcBuildInfoUpdated =  ...
sharedSrcLinkObjectUpdated.BuildInfoHandle;
end 

if ~isempty( lSharedLibPath )
[ clientFolderObjectFileNames, clientSharedUtilLinkObjects ] =  ...
i_getClientSharedObjs( lAnchorFolder, clientAnchorDir, lSharedLibPath );



skipAllLocalSharedFiles = i_removeSourceFilesAlreadyInClientFolder ...
( sharedSrcBuildInfoUpdated, clientFolderObjectFileNames );
else 
clientSharedUtilLinkObjects = [  ];
skipAllLocalSharedFiles = false;
end 



if ~isempty( clientSharedUtilLinkObjects )




addLinkObjects( lBuildInfo, clientSharedUtilLinkObjects( : ) );



if skipAllLocalSharedFiles

removeLinkables( lBuildInfo, { sharedSrcLinkObjectUpdated.Name } );
end 
end 


function i_clientAnchorFolderUpdate( lBuildInfo, clientAnchorDir )







localStartDir = lBuildInfo.Settings.LocalAnchorDir;
lBuildInfo.Settings.LocalAnchorDir = clientAnchorDir;


lBuildInfo.Settings.LocalAnchorDir = localStartDir;


incPathsMdlRef = getIncludePaths( lBuildInfo, false, 'MDLREF' );
incPathsOther = getIncludePaths( lBuildInfo, false, {  }, 'MDLREF' );

incPathsMdlRef = strrep ...
( incPathsMdlRef, '$(START_DIR)', clientAnchorDir );




[ incPathsOther, clientShadowIncludeDirs ] = coder.internal.swapLocalForMasterAnchor ...
( incPathsOther, lBuildInfo.Settings.LocalAnchorDir, clientAnchorDir );





incPathsOther = [ incPathsOther, clientShadowIncludeDirs ];

lBuildInfo.Inc.Paths = [  ];
addIncludePaths( lBuildInfo, incPathsMdlRef, 'MDLREF' );
addIncludePaths( lBuildInfo, incPathsOther );



srcPathBuildDir = getSourcePaths( lBuildInfo, false, 'BuildDir' );
srcPathStartDir = getSourcePaths( lBuildInfo, false, 'StartDir' );

srcPathsOther = getSourcePaths( lBuildInfo, false, {  }, { 'BuildDir', 'StartDir' } );
srcPathsOther = coder.internal.swapLocalForMasterAnchor ...
( srcPathsOther, lBuildInfo.Settings.LocalAnchorDir, clientAnchorDir );

lBuildInfo.Src.Paths = [  ];
addSourcePaths( lBuildInfo, srcPathsOther );
addSourcePaths( lBuildInfo, srcPathBuildDir, 'BuildDir' );
addSourcePaths( lBuildInfo, srcPathStartDir, 'StartDir' );



numModelRefsUpdated = 0;
numModelRefs = length( lBuildInfo.ModelRefs );
while numModelRefsUpdated < numModelRefs
i_updateModelRefPaths( lBuildInfo, clientAnchorDir )
numModelRefsUpdated = numModelRefs;


numModelRefs = length( lBuildInfo.ModelRefs );
end 

i_updateSourceFilePaths( lBuildInfo, clientAnchorDir )

function i_updateModelRefPaths( lBuildInfo, clientAnchorDir )



lModelRefs = lBuildInfo.ModelRefs;
lLinkLibrariesPaths = get( lModelRefs, 'Path' );

if isempty( lLinkLibrariesPaths )

return ;
end 


lClientAnchorDirRegex = regexptranslate( 'escape', clientAnchorDir );
lLinkLibrariesPaths = fullfile( regexprep( lLinkLibrariesPaths, '^\$\(START_DIR\)', lClientAnchorDirRegex ) );


if ~iscell( lLinkLibrariesPaths )
lLinkLibrariesPaths = { lLinkLibrariesPaths };
end 
[ lBuildInfo.ModelRefs( : ).Path ] = deal( lLinkLibrariesPaths{ : } );

function i_updateSourceFilePaths( lBuildInfo, clientAnchorDir )


srcFiles = lBuildInfo.Src.Files;
srcFilePaths = { srcFiles.Path };

if isempty( srcFilePaths )

return ;
end 



srcFileNames = { srcFiles.FileName };
fullPaths = fullfile( srcFilePaths, srcFileNames );

transformedFullPaths = coder.internal.swapLocalForMasterAnchor( fullPaths, lBuildInfo.Settings.LocalAnchorDir, clientAnchorDir );
srcFilePaths = coder.make.internal.fileparts( transformedFullPaths, filesep );


lLocalAnchorDirRegex = regexptranslate( 'escape', lBuildInfo.Settings.LocalAnchorDir );
srcFilePaths = fullfile( regexprep( srcFilePaths, '^\$\(START_DIR\)', lLocalAnchorDirRegex ) );


[ lBuildInfo.Src.Files( : ).Path ] = deal( srcFilePaths{ : } );


function [ clientFolderObjectFileNames, clientSharedUtilLinkObjects ] =  ...
i_getClientSharedObjs( lAnchorFolder, lClientAnchorFolder, lSharedLibPath )

sharedUtilsBuildFolder = fullfile( lAnchorFolder, lSharedLibPath );




fileName = 'simTargetObjsInMasterFolder.txt';
fileName = fullfile( sharedUtilsBuildFolder, fileName );
if ~isempty( dir( fileName ) )

clientFolderObjectFileNames = fileread( fileName );
clientFolderObjectFileNames =  ...
regexp( clientFolderObjectFileNames, newline, 'split' );

for i = length( clientFolderObjectFileNames ): - 1:1
tmpLinkObj = RTW.BuildInfoLinkObj(  ...
clientFolderObjectFileNames{ i },  ...
fullfile( lClientAnchorFolder, lSharedLibPath ),  ...
RTW.BuildInfoLinkObj.DefaultLinkPriority,  ...
'SHARED_SRC_MASTER' );
tmpLinkObj.LinkOnly = true;
tmpLinkObj.ReferencedBuildInfo = coder.make.enum.ReferencedBuildInfo.None;
clientSharedUtilLinkObjects( i ) = tmpLinkObj;
end 

else 
clientFolderObjectFileNames = [  ];
clientSharedUtilLinkObjects = [  ];
end 







function noSourceFilesRemaining = i_removeSourceFilesAlreadyInClientFolder ...
( sharedSrcBuildInfo, clientFolderObjectFileNames )

if isempty( sharedSrcBuildInfo )



noSourceFilesRemaining = true;
return 
end 

if isempty( clientFolderObjectFileNames )

noSourceFilesRemaining = false;
return ;
end 

srcFiles = { sharedSrcBuildInfo.Src.Files.FileName };
srcFilesNoExt = regexprep( srcFiles, '\..*$', '' );

objFilesNoExt = regexprep( clientFolderObjectFileNames, '\..*$', '' );


[ ~, keepIdx ] = setdiff( srcFilesNoExt, objFilesNoExt, 'stable' );


sharedSrcBuildInfo.Src.Files = sharedSrcBuildInfo.Src.Files( keepIdx );

noSourceFilesRemaining = isempty( sharedSrcBuildInfo.Src.Files );




% Decoded using De-pcode utility v1.2 from file /tmp/tmpSKha9Z.p.
% Please follow local copyright laws when handling this file.

