function [ packageList, packageInfo ] = find_valid_packages( mode )







excludeBuiltin = false;
findOldPkgs = false;


switch nargin
case 0

case 1

switch mode
case 'ExcludeBuiltin'

excludeBuiltin = true;

case 'FindOldUserPkgs'

excludeBuiltin = true;

findOldPkgs = true;
case 'FindNewUserPkgs'

excludeBuiltin = true;
otherwise 
DAStudio.error( 'Simulink:dialog:InvalidInpArgWithoutDot' );
end 
otherwise 
DAStudio.error( 'Simulink:dialog:InvalidInpArgWithoutDot' );
end 

packageList = {  };
packageInfo = struct;
dirToSkip = matlabroot;
workDir = [ matlabroot, filesep, 'work' ];


pathCache = [ path, pathsep ];
if isempty( strfind( pathCache, [ cd, pathsep ] ) )

pathCache = [ pathCache, cd, pathsep ];
end 
separatorIdx = find( pathCache == pathsep );


startIdx = 0;
for endIdx = separatorIdx
thisDir = pathCache( startIdx + 1:endIdx - 1 );


if ( ( excludeBuiltin ) &&  ...
( strncmp( thisDir, dirToSkip, length( dirToSkip ) ) ) &&  ...
( ~strncmp( thisDir, workDir, length( workDir ) ) ) )
startIdx = endIdx;
continue ;
end 


if findOldPkgs
packageDirs = dir( [ thisDir, filesep, '@*' ] );
else 
packageDirs = dir( [ thisDir, filesep, '+*' ] );
end 

for pDirName = { packageDirs.name };
pkgDir = [ thisDir, filesep, pDirName{ 1 } ];
pkgName = pDirName{ 1 }( 2:end  );

if isvarname( pkgName )

if ismember( pkgName, packageList )
packageInfo.( pkgName ).DirectoryNames{ end  + 1 } = pkgDir;
else 
packageList{ end  + 1, 1 } = pkgName;%#ok
packageInfo.( pkgName ).DirectoryNames = { pkgDir };
end 
end 
end 
startIdx = endIdx;
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpYH7fSM.p.
% Please follow local copyright laws when handling this file.

