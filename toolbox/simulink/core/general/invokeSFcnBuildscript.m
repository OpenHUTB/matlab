function invokeSFcnBuildscript( scenario, buildscriptPath, pathContainingCommonDir )

























sfunRelativePathCreator = '';
commonDirRelativePathCreator = '';
mexFolder = '';
archStr = computer( 'arch' );
archStr( ~isstrprop( archStr, 'alphanum' ) ) = '';
switch scenario
case 'BSDAuthor'
sfunRelativePathCreator = fullfile( '..', '..' );
commonDirRelativePathCreator = fullfile( '..', '..' );
mexFolder = fullfile( '..', 'mex' );
case 'BSDPublishedProject'
sfunRelativePathCreator = fullfile( '..', '..' );
commonDirRelativePathCreator = pathContainingCommonDir;

mexFolder = fullfile( '..', [ 'mex', archStr ] );
case 'StandAlone'
sfunRelativePathCreator = fullfile( '..', '..' );
commonDirRelativePathCreator = fullfile( '..', '..' );
mexFolder = fullfile( '..', [ 'mex', archStr ] );
end 

[ path, name, ~ ] = fileparts( buildscriptPath );
currDir = pwd;
cleanUp = onCleanup( @(  )cd( currDir ) );
if isfolder( path )
cd( path );
else 

end 

functionCall = sprintf( '%s(''%s'',''%s'',''%s'')', name, sfunRelativePathCreator, commonDirRelativePathCreator, mexFolder );
eval( functionCall );

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpNp1f30.p.
% Please follow local copyright laws when handling this file.

