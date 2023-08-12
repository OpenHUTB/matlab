function buildInfo = getBuildInfo( obj )




buildDir = obj.getBuildDir(  );
if ~isempty( obj.getTaggedFiles( 'In-the-Loop:SIL' ) )
isInTheLoop = true;
inTheLoopMode = 'SIL';
elseif ~isempty( obj.getTaggedFiles( 'In-the-Loop:PIL' ) )
isInTheLoop = true;
inTheLoopMode = 'PIL';
else 
isInTheLoop = false;
end 
if isInTheLoop

inTheLoopSubDir = rtw.connectivity.Utils.getXILSubDir( inTheLoopMode, obj.ModelName );

builderInfo = fullfile( buildDir, inTheLoopSubDir, 'builderInfo.mat' );
if exist( builderInfo, 'file' )
builderInfo = load( builderInfo );
buildInfo = builderInfo.codeMetricsAppBuildInfo;
else 
DAStudio.error( 'RTW:report:MissingInTheLoopBuildInfo', inTheLoopMode, builderInfo );
end 
else 
if isValidSlObject( slroot, obj.ModelName )

buildInfoFile = coder.internal.rte.SDPTypes.getBuildInfoFile( obj.ModelName, buildDir );
else 
buildInfoFile = fullfile( buildDir, 'buildInfo.mat' );
end 
load( buildInfoFile, 'buildInfo' );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmphNF0nx.p.
% Please follow local copyright laws when handling this file.

