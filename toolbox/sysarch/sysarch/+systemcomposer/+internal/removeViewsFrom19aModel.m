function removeViewsFrom19aModel( modelName, newModelFileName )







[ origFilePath, modelName, ~ ] = fileparts( modelName );

modelFile = which( modelName );
if ( isempty( modelFile ) )
error( 'The model with the provided name could not be found on the MATLAB path' );
end 


if ( bdIsLoaded( modelName ) )
error( 'Please close your model before running this script' );
end 


tmpModelName = [ 'tmp_tmw_', modelName ];


tmpZipFile = fullfile( pwd, [ tmpModelName, '.zip' ] );
copyfile( modelFile, tmpZipFile );


tmpModelDir = fullfile( pwd, tmpModelName );
unzip( tmpZipFile, tmpModelDir );


archViewXMLFile = fullfile( tmpModelDir, 'simulink', 'systemcomposer', 'archViews.xml' );
archViewTreeXMLFile = fullfile( tmpModelDir, 'simulink', 'systemcomposer', 'archViewsTree.xml' );
if ( exist( archViewXMLFile, 'file' ) )
delete( archViewXMLFile );
end 
if ( exist( archViewTreeXMLFile, 'file' ) )
delete( archViewTreeXMLFile );
end 


archXMLFile = fullfile( tmpModelDir, 'simulink', 'systemcomposer', 'architecture.xml' );
if ( ~exist( archXMLFile, 'file' ) )


delete( tmpZipFile );
rmdir( tmpModelDir, 's' );
return ;
end 

p = matlab.io.xml.dom.Parser;
rootNode = p.parseFile( archXMLFile );


archViewProxies = rootNode.getElementsByTagName( 'p_ViewArchitectureProxies' );
numProxies = archViewProxies.getLength;
archViewProxiesList = [  ];
for i = 0:numProxies - 1
archViewProxy = archViewProxies.item( i );
archViewProxiesList = [ archViewProxiesList, archViewProxy ];%#ok<AGROW>
end 

proxyUUID = [  ];
for i = 1:numel( archViewProxiesList )
archViewProxy = archViewProxiesList( i );
if ( isempty( proxyUUID ) )
proxy = archViewProxy.getElementsByTagName( 'Proxy' );
proxyUUID = proxy.item( 0 ).getAttribute( 'uuid' );
end 
parent = archViewProxy.getParentNode;
parent.removeChild( archViewProxy );
end 


activeViewProxy = rootNode.getElementsByTagName( 'p_ActiveViewProxy' );
if ( activeViewProxy.getLength > 0 )
parent = activeViewProxy.item( 0 ).getParentNode;
parent.removeChild( activeViewProxy.item( 0 ) );
end 


proxies = rootNode.getElementsByTagName( 'Proxies' );
numProxies = proxies.getLength;
for i = 0:numProxies - 1
proxy = proxies.item( i );
if ( strcmp( proxy.getAttribute( 'uuid' ), proxyUUID ) )

parent = proxy.getParentNode;
parent.removeChild( proxy );
break ;
end 
end 


archViewResolver = rootNode.getElementsByTagName( 'systemcomposer.services.proxy.ArchViewsModelResolver' );
if ( archViewResolver.getLength > 0 )
parent = archViewResolver.item( 0 ).getParentNode;
parent.removeChild( archViewResolver.item( 0 ) );
end 

delete( archXMLFile );
fileWriter = matlab.io.xml.dom.FileWriter( archXMLFile );
domWriter = matlab.io.xml.dom.DOMWriter;
varsToClear = { 'fileWriter', 'domWriter' };
domWriter.write( rootNode, fileWriter );


clear( varsToClear{ : } );


newZipFile = fullfile( pwd, [ 'noviews_', tmpModelName, '.zip' ] );
curDir = pwd;
cd( tmpModelDir );
files = dir( '.' );
filesToZip = cell( numel( files ), 1 );
for i = 1:numel( files )
if ( ~strcmp( files( i ).name, '..' ) && ~strcmp( files( i ).name, '.' ) )
filesToZip{ i } = fullfile( files( i ).folder, files( i ).name );
end 
end 
filesToZip = filesToZip( ~cellfun( 'isempty', filesToZip ) );
zip( newZipFile, filesToZip );
cd( curDir );


if nargin < 2
newModelFile = fullfile( origFilePath, [ modelName, '_noViews', '.slx' ] );
else 
[ path, newModelName, ~ ] = fileparts( newModelFileName );
newModelFile = fullfile( path, [ newModelName, '.slx' ] );
end 
movefile( newZipFile, newModelFile );


delete( tmpZipFile );
rmdir( tmpModelDir, 's' );


end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpXdgHj6.p.
% Please follow local copyright laws when handling this file.

