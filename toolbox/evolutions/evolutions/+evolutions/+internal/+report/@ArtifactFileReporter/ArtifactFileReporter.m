classdef ArtifactFileReporter < evolutions.internal.report.DesignEvolutionReporter















properties 
Object{ mustBeInstanceOf( 'evolutions.model.ArtifactFileInfo', Object ) } = [  ];
ParentObj{ mustBeInstanceOf( 'evolutions.model.EvolutionTreeInfo', ParentObj ) } = [  ];
ReportTempDir = '';

IncludeArtifactFileNameHeading{ mustBeLogical } = true;
IncludeArtifactFileWebView{ mustBeLogical } = true;
IncludeArtifactFileBackToEvolutionHyperlinks{ mustBeLogical } = true;
IncludeArtifactFileBackToEvolutionTreeHyperlink{ mustBeLogical } = true;
end 



methods ( Access = protected, Hidden )

result = openImpl( report, impl, varargin )
end 


methods 
function h = ArtifactFileReporter( nameValueArgs )

R36
nameValueArgs.Object = [  ];
nameValueArgs.ParentObj = [  ];
nameValueArgs.ReportTempDir = tempdir;

nameValueArgs.TemplateName = "ArtifactFileReporter";

nameValueArgs.IncludeArtifactFileNameHeading = true;
nameValueArgs.IncludeArtifactFileWebView = true;
nameValueArgs.IncludeArtifactFileBackToEvolutionHyperlinks = true;
nameValueArgs.IncludeArtifactFileBackToEvolutionTreeHyperlink = true;

end 

nameValuePairs = namedargs2cell( nameValueArgs );
h = h@evolutions.internal.report.DesignEvolutionReporter( nameValuePairs{ : } );

h.Object = nameValueArgs.Object;
h.ParentObj = nameValueArgs.ParentObj;
h.ReportTempDir = nameValueArgs.ReportTempDir;
h.TemplateName = nameValueArgs.TemplateName;

end 


function content = getArtifactFileNameHeading( h, ~ )
content = [  ];
if h.IncludeArtifactFileNameHeading

testObj = h.Object;
artifactFileInfos.artifactFilePath = testObj.File;
[ ~, afiName, afiExtn ] = fileparts( artifactFileInfos.artifactFilePath );
artifactFileInfos.artifactFileId = testObj.Id;

heading = mlreportgen.dom.Heading4( sprintf( '%s%s%s', '...\', afiName, afiExtn ) );
append( heading, mlreportgen.dom.LinkTarget( artifactFileInfos.artifactFileId ) );
heading.StyleName = 'StyleName_ArtifactFileNameHeading';
content = heading;
end 
end 


function content = getArtifactFileWebView( h, ~ )
content = [  ];
if h.IncludeArtifactFileWebView

testObj = h.Object;
artifactFileInfos.artifactFileWebviewFile = testObj.WebView;
[ ~, htmlFileName, htmlFileExt ] = fileparts( artifactFileInfos.artifactFileWebviewFile );

[ webViewTempDir, preppedWebViewTempDir ] = createTempDirForHTMLfiles( h );


copyfile( artifactFileInfos.artifactFileWebviewFile, webViewTempDir, 'f' );


artifactFileWebViewLink = mlreportgen.dom.Paragraph(  ...
mlreportgen.dom.ExternalLink( fullfile( '.', 'ExternalLinks', 'WebViews', sprintf( '%s%s', htmlFileName, htmlFileExt ) ),  ...
'Open HTML outside this document' ) );
artifactFileWebViewLink.StyleName = 'StyleName_ArtifactFileWebViewHyperlink';
content = [ content, { artifactFileWebViewLink } ];



preppedHTMLFile = mlreportgen.utils.html2dom.prepHTMLFile(  ...
artifactFileInfos.artifactFileWebviewFile,  ...
fullfile( preppedWebViewTempDir, sprintf( '%s%s%s', 'Prepped', htmlFileName, htmlFileExt ) ) );
htmlObj = mlreportgen.dom.HTMLFile( preppedHTMLFile );
htmlObj.StyleName = 'StyleName_ArtifactFileWebViewContainerDiv';
content = [ content, { htmlObj } ];



resizeImageInHTML( h, htmlObj );



newLine = mlreportgen.dom.Paragraph( '' );
content = [ content, { newLine } ];
end 
end 

function [ webViewTempDir, preppedWebViewTempDir ] = createTempDirForHTMLfiles( h )

webViewTempDir = fullfile( h.ReportTempDir, 'ExternalLinks', 'WebViews' );
preppedWebViewTempDir = fullfile( h.ReportTempDir, 'PreppedWebViews' );
if ( ~isfolder( webViewTempDir ) )
mkdir( webViewTempDir );
end 
if ( ~isfolder( preppedWebViewTempDir ) )
mkdir( preppedWebViewTempDir );
end 
end 

function resizeImageInHTML( ~, htmlObj )


bodyWidth = 7;


if isa( htmlObj.Children.Children, 'mlreportgen.dom.Paragraph' )
if isa( htmlObj.Children.Children( 1, 1 ).Children, 'mlreportgen.dom.LinkTarget' )
if isa( htmlObj.Children.Children( 1, 2 ).Children, 'mlreportgen.dom.Image' )
aspectRatio = str2double( regexp( htmlObj.Children.Children( 1, 2 ).Children.Height, '\d*', 'match' ) ) /  ...
str2double( regexp( htmlObj.Children.Children( 1, 2 ).Children.Width, '\d*', 'match' ) );
htmlObj.Children.Children( 1, 2 ).Children.Width = sprintf( '%f%s', bodyWidth * 96, 'px' );
htmlObj.Children.Children( 1, 2 ).Children.Height = sprintf( '%f%s', bodyWidth * 96 * aspectRatio, 'px' );
end 
end 
end 
end 


function content = getArtifactFileBackToEvolutionHyperlinks( h, ~ )
content = [  ];
if h.IncludeArtifactFileBackToEvolutionHyperlinks


if ~isempty( h.ParentObj )


artifactFileInfos = contentArtifactFileBackToEvolution( h );


artifactFileBackToEvolutionHyperlinks = mlreportgen.dom.Table(  );
for j = 1:numel( artifactFileInfos.artifactEvoSources )
fileTableRow = mlreportgen.dom.TableRow(  );
fileTableEntry = mlreportgen.dom.TableEntry(  );
append( fileTableEntry, mlreportgen.dom.InternalLink( artifactFileInfos.artifactEvoSourcesIDs{ j },  ...
sprintf( '%s%s', 'Back to Evolution: ', artifactFileInfos.artifactEvoSources{ j } ) ) );
append( fileTableRow, fileTableEntry );
append( artifactFileBackToEvolutionHyperlinks, fileTableRow );
end 
artifactFileBackToEvolutionHyperlinks.StyleName = 'StyleName_ArtifactFileBackToEvolutionHyperlinks';
content = [ content, { artifactFileBackToEvolutionHyperlinks } ];

end 
end 

end 

function artifactFileInfos = contentArtifactFileBackToEvolution( h )
testObj = h.Object;


evolutionInfoObjs = h.ParentObj.EvolutionManager.Infos;
for evolutionIdx = 1:numel( h.ParentObj.EvolutionManager.Infos )
evolutionInfos.evolutionNames{ evolutionIdx } = evolutionInfoObjs( evolutionIdx ).getName;
evolutionInfos.evolutionIds{ evolutionIdx } = evolutionInfoObjs( evolutionIdx ).Id;
[ ~, evolutionInfos.evolutionArtifacts{ evolutionIdx } ] = evolutions.internal.utils ...
.getBaseToArtifactsKeyValues( evolutionInfoObjs( evolutionIdx ) );
for afiIdx = 1:numel( evolutionInfos.evolutionArtifacts{ evolutionIdx } )
evolutionInfos.evolutionArtifactsId{ evolutionIdx }{ afiIdx } = evolutionInfos.evolutionArtifacts{ evolutionIdx }( afiIdx ).Id;
end 
end 

artifactFileInfos.artifactFileId = testObj.Id;
count = 1;



for evolutionIdx = 1:numel( evolutionInfos.evolutionNames )

if ~isempty( evolutionInfos.evolutionArtifactsId{ evolutionIdx }{ 1 } )
for NoOfAFis = 1:numel( evolutionInfos.evolutionArtifacts{ evolutionIdx } )


if artifactFileInfos.artifactFileId == evolutionInfos.evolutionArtifactsId{ evolutionIdx }{ NoOfAFis }
artifactFileInfos.artifactEvoSources{ count } = evolutionInfos.evolutionNames{ evolutionIdx };
artifactFileInfos.artifactEvoSourcesIDs{ count } = evolutionInfos.evolutionIds{ evolutionIdx };
count = count + 1;
end 
end 
end 
end 
end 



function content = getArtifactFileBackToEvolutionTreeHyperlink( h, ~ )
content = [  ];
if h.IncludeArtifactFileBackToEvolutionTreeHyperlink

backToEvoTreeInfoLink = mlreportgen.dom.Paragraph( mlreportgen.dom.InternalLink( h.ParentObj.Id,  ...
sprintf( '%s%s', 'Back to Evolution Tree: ', h.ParentObj.getName ) ) );
backToEvoTreeInfoLink.StyleName = 'StyleName_ArtifactFileBackToEvolutionTreeHyperlink';

content = [ content, { backToEvoTreeInfoLink } ];
end 
end 


end 


methods ( Static )
function path = getClassFolder(  )
[ path ] = fileparts( mfilename( 'fullpath' ) );
end 

function createTemplate( templatePath, type )
path = ArtifactFileReporter.getClassFolder(  );
mlreportgen.report.ReportForm.createFormTemplate(  ...
templatePath, type, path );
end 

function customizeReporter( toClasspath )
mlreportgen.report.ReportForm.customizeClass(  ...
toClasspath, "ArtifactFileReporter" );
end 

end 
end 



function mustBeLogical( varargin )
mlreportgen.report.validators.mustBeLogical( varargin{ : } );
end 

function mustBeInstanceOf( varargin )
mlreportgen.report.validators.mustBeInstanceOf( varargin{ : } );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpfe8aBH.p.
% Please follow local copyright laws when handling this file.

