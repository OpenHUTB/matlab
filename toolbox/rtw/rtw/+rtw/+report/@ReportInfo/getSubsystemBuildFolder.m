function [ out, tmpMdlName, sys ] = getSubsystemBuildFolder( sys )
narginchk( 1, 1 );
out = '';
tmpMdlName = '';
[ modelName, remain ] = strtok( sys, ':/' );
dirs = RTW.getBuildDir( modelName );
slprjFolder = fullfile( dirs.CodeGenFolder, dirs.ModelRefRelativeBuildDir );

if strcmp( remain, ':*' )
sys = '*';
end 
sinfo = rtw.report.ReportInfo.getSInfo( slprjFolder, sys );
if length( sinfo ) > 1
out = { sinfo.buildDir };
tmpMdlName = { sinfo.TmpMdlName };
if isfield( sinfo( 1 ), 'BlockSID' )
sys = { sinfo.BlockSID };
end 
elseif ~isempty( sinfo )
buildInfoFile = fullfile( sinfo.buildDir, 'buildInfo.mat' );
if exist( buildInfoFile, 'file' )
out = sinfo.buildDir;
tmpMdlName = sinfo.TmpMdlName;
if isfield( sinfo, 'BlockSID' )
sys = sinfo.BlockSID;
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp0xtp8m.p.
% Please follow local copyright laws when handling this file.

