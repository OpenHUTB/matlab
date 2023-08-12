function out = detectBuildFolder( sys, varargin )



narginchk( 1, 3 );
if nargin == 3
if ~strcmp( varargin{ 1 }, 'ModelReference' )
throw( MSLException( [  ], message( 'Simulink:utility:invalidInputArgs', varargin{ 1 } ) ) );
end 
if ~any( strcmp( varargin{ 2 }, { 'on', 'off' } ) )
throw( MSLException( [  ], message( 'Simulink:utility:ExpectedOnOffStringValue', 'on', 'off' ) ) );
end 
end 

sys = convertStringsToChars( sys );
if ~ischar( sys )
sys = getfullname( sys );
end 
[ model, remain ] = strtok( sys, ':/' );
isSubsystemBuild = ~isempty( remain );
if nargin == 3 && isSubsystemBuild
throw( MSLException( [  ], message( 'RTW:report:invalidSubsystemBuildArg', varargin{ 1 } ) ) );
end 
if nargin == 2
buildFolder = convertStringsToChars( varargin{ 1 } );
if ~exist( buildFolder, 'dir' )
throw( MSLException( [  ], message( 'RTW:report:buildFolderNotFound', buildFolder ) ) );
end 

buildFolder = cd( cd( buildFolder ) );
else 
dirs = RTW.getBuildDir( model );
if nargin == 1 && isSubsystemBuild
[ buildFolder, ~, ~ ] = rtw.report.ReportInfo.getSubsystemBuildFolder( sys );
out = buildFolder;
if ~iscell( buildFolder )
buildFolder = { buildFolder };
end 
for k = 1:length( buildFolder )
if ~exist( buildFolder{ k }, 'dir' )
if ~isempty( buildFolder{ k } )
throw( MSLException( [  ], message( 'RTW:report:relativeBuildFolderNotFound', buildFolder{ k }, dirs.CodeGenFolder ) ) );
else 
throw( MSLException( [  ], message( 'RTW:report:relativeSubsystemBuildFolderNotFound', sys, dirs.CodeGenFolder ) ) );
end 
end 
end 
return 
else 
buildFolder = dirs.BuildDirectory;
mdlRefDir = fullfile( dirs.CodeGenFolder, dirs.ModelRefRelativeBuildDir );
if nargin == 3 && varargin{ 2 } == "on"
if ~exist( fullfile( mdlRefDir, 'buildInfo.mat' ), 'file' )
if ~Simulink.report.ReportInfo.featureReportV2

throw( MSLException( [  ], message( 'RTW:report:relativeBuildFolderNotFound', dirs.ModelRefRelativeBuildDir, dirs.CodeGenFolder ) ) );
end 
end 
buildFolder = mdlRefDir;
elseif nargin == 1 && ~exist( buildFolder, 'dir' ) && exist( mdlRefDir, 'dir' ) && exist( fullfile( mdlRefDir, 'buildInfo.mat' ), 'file' )
buildFolder = mdlRefDir;
end 
end 
if ~exist( buildFolder, 'dir' )
if isempty( dirs )
[ workingFolder, relativeFolder ] = fileparts( buildFolder );
else 
workingFolder = dirs.CodeGenFolder;
if nargin == 3 && varargin{ 2 } == "on"
relativeFolder = dirs.ModelRefRelativeBuildDir;
else 
relativeFolder = dirs.RelativeBuildDir;
end 
end 
throw( MSLException( [  ], message( 'RTW:report:relativeBuildFolderNotFound', relativeFolder, workingFolder ) ) );
end 
end 
out = buildFolder;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpD1ZPp6.p.
% Please follow local copyright laws when handling this file.

