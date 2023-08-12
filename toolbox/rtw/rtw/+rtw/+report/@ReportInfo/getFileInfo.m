function out = getFileInfo( obj, name )



if isempty( obj.FileInfo )
out = obj.FileInfo;
return 
end 
if nargin < 2
out = obj.FileInfo;
else 
idx = find( strcmp( { obj.FileInfo.FileName }, name ) );
if isempty( idx )
out = [  ];
else 
out = obj.FileInfo( idx( 1 ) );
end 
end 
if ~exist( obj.GenUtilsPath, 'dir' )
buildDirs = RTW.getbuildDir( obj.ModelName );
obj.GenUtilsPath = fullfile( buildDirs.CodeGenFolder, buildDirs.SharedUtilsTgtDir );
end 

mlroot = '$(MATLAB_ROOT)';
for k = 1:length( out )

if isempty( out( k ).Path ) || strcmp( out( k ).Path, '$(BuildDir)' )
out( k ).Path = obj.BuildDirectory;
elseif strcmp( out( k ).Path, '$(SharedUtilsDir)' )
out( k ).Path = obj.GenUtilsPath;
if strcmp( out( k ).Group, 'utility' )
out( k ).Group = 'sharedutility';
end 
elseif strncmp( out( k ).Path, mlroot, length( mlroot ) )
out( k ).Path = fullfile( matlabroot, out( k ).Path( length( mlroot ) + 1:end  ) );
elseif ~isempty( strfind( out( k ).Path, '$(BuildDir)' ) )
out( k ).Path = strrep( out( k ).Path, '$(BuildDir)', obj.BuildDirectory );
elseif ~isempty( obj.StartDir ) && ~isempty( strfind( out( k ).Path, '$(StartDir)' ) )
out( k ).Path = strrep( out( k ).Path, '$(StartDir)', obj.StartDir );
else 


tmpPath = fullfile( obj.BuildDirectory, out( k ).Path );
if exist( tmpPath, 'dir' )
out( k ).Path = tmpPath;
end 
end 



if ~exist( fullfile( out( k ).Path, out( k ).FileName ), 'file' ) && strcmp( out( k ).Group, 'utility' )
if exist( fullfile( obj.GenUtilsPath, out( k ).FileName ), 'file' )
out( k ).Group = 'sharedutility';
out( k ).Path = obj.GenUtilsPath;
end 
end 
end 


obj.CachedFileInfo = out;
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpaFnLSW.p.
% Please follow local copyright laws when handling this file.

