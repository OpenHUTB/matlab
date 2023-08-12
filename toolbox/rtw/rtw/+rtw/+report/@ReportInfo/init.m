function init( obj, buildDir, gensettings )


obj.TargetLang = get_param( obj.ModelName, 'TargetLang' );
init@Simulink.report.ReportInfo( obj );
obj.BuildDirectory = buildDir;
rtwDirs = RTW.getBuildDir( obj.ModelName );
obj.ModelRefRelativeBuildDir = rtwDirs.ModelRefRelativeBuildDir;
obj.ModelReferenceTargetType = gensettings.ModelReferenceTargetType;

if ~exist( obj.GenUtilsPath, 'dir' )
obj.GenUtilsPath = fullfile( rtwDirs.CodeGenFolder, rtwDirs.SharedUtilsTgtDir );
end 

folders = Simulink.filegen.internal.FolderConfiguration( gensettings.model );
obj.CodeGenFolder = folders.CodeGeneration.Root;

obj.CodeFormat = gensettings.CodeFormat;

obj.Summary.CodeGenFolder = obj.CodeGenFolder;

bInfoMat = coder.internal.infoMATFileMgr( 'getMatFileName', 'binfo', obj.ModelName, gensettings.ModelReferenceTargetType );
obj.Summary.BInfoMat = rtwprivate( 'rtwGetRelativePath', bInfoMat, obj.getReportDir );
if ~isempty( obj.InsertedBlocks )
obj.InsertedBlocks.BuildDirectory = obj.BuildDirectory;
end 
if isempty( obj.SourceSubsystem )
obj.Summary.SubsystemPathAndName = '';
else 
hMdl = get_param( obj.ModelName, 'handle' );
ssHdl = rtwprivate( 'getSourceSubsystemHandle', hMdl );
obj.Summary.SubsystemPathAndName = getfullname( ssHdl );
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpJUi5xr.p.
% Please follow local copyright laws when handling this file.

