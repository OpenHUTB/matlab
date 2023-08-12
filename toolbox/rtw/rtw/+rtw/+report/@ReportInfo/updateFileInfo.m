function out = updateFileInfo( obj )





dirFiles = coder.internal.slcoderReport( 'getFilesInBuildFolder', obj.BuildDirectory );

categories = obj.getCodeFileCategoryDisplayNames(  );



modelCodegenMgr = [  ];
if isValidSlObject( slroot, obj.ModelName )
modelCodegenMgr = coder.internal.ModelCodegenMgr.getInstance( obj.ModelName );
end 
if ~isempty( modelCodegenMgr )
buildInfo = modelCodegenMgr.BuildInfo;
else 
load( fullfile( obj.BuildDirectory, 'buildInfo.mat' ), 'buildInfo' );
end 




stat_src = getSourceFiles( buildInfo, 1, 1, 'BlockModules' );
stat_inc = getIncludeFiles( buildInfo, 1, 1, 'BlockModules' );
stat_fullNameList = [ stat_src, stat_inc ];
coder.internal.slcoderReport( 'insertSfcnFile', obj, buildInfo );
coder.internal.slcoderReport( 'insertCustomFile', obj, obj.FileInfo, obj.CustomFile, buildInfo );
if ~obj.AddSource
obj.trimFileSet(  );
end 
[ srcFiles_cat, sortedFileInfoList ] = obj.sortGroup( stat_fullNameList, categories{ 1 }, dirFiles );
obj.CachedSortedFileInfo = { sortedFileInfoList, srcFiles_cat, categories{ 1 }, categories{ 2 } };
out = sortedFileInfoList;
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpVoEm34.p.
% Please follow local copyright laws when handling this file.

