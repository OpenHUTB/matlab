function preppedHTML = prepHTMLFile( htmlFile, preppedHTMLFile, options )

































R36
htmlFile string
preppedHTMLFile string = string.empty(  );
options.Tidy logical = true;
options.EncodeHTMLEntity logical = true;
end 


htmlFilePath = string( mlreportgen.utils.internal.canonicalPath( htmlFile ) );
if ~isfile( htmlFilePath )
error( message( "mlreportgen:utils:html2dom:missingHTMLFile", htmlFilePath ) );
end 
[ htmlFileFolder, htmlFileName, htmlFileExt ] = fileparts( htmlFilePath );


if ( options.EncodeHTMLEntity || options.Tidy )
fid = fopen( htmlFilePath, "r", "n", "utf-8" );
content = fread( fid, inf, "*char" );
fclose( fid );

if options.EncodeHTMLEntity






content = encodeHTMLEntityString( content );
end 

if options.Tidy
content = mlreportgen.utils.tidy( content, "OutputType", "html" );
end 

inputFile = sprintf( "%s-pass1%s", htmlFileName, htmlFileExt );
fid = fopen( fullfile( htmlFileFolder, inputFile ), "w", "n" );
fprintf( fid, "%s", content );
fclose( fid );
else 
inputFile = htmlFileName + htmlFileExt;
end 


connector.ensureServiceOn(  );
contentUrlPath = connector.addStaticContentOnPath( "HTML2DOM", htmlFileFolder );


url = connector.getUrl( sprintf( "%s/%s", contentUrlPath, inputFile ) );


browser = matlab.internal.webwindow( url );
cleanup = onCleanup( @(  )delete( browser ) );
idler = mlreportgen.utils.internal.Idler;
browser.PageLoadFinishedCallback = @( a, b )pageLoadCallback( a, b, idler );


success = idler.startIdling( 120 );
if ~success
error( message( "mlreportgen:utils:html2dom:browserFailure",  ...
inputFile ) );
end 





js = getHTMLDOMWriterScript(  );
preppedHTML = executeJS( browser, js );
preppedHTML = string( jsondecode( preppedHTML ) );


if ~isempty( preppedHTMLFile )
outputFile = mlreportgen.utils.internal.canonicalPath( preppedHTMLFile );
outputDir = fileparts( outputFile );
if ~isfolder( outputDir )
mkdir( outputDir )
end 

fid = fopen( outputFile, "w", "n", "utf-8" );
fprintf( fid, "%s", preppedHTML );
fclose( fid );
preppedHTML = outputFile;
end 
end 

function script = getHTMLDOMWriterScript(  )
thisMFilePath = mfilename( "fullpath" );
dir = fileparts( thisMFilePath );
jsScript = fullfile( dir, "htmlDOMWriter.js" );
script = fileread( jsScript );
end 

function pageLoadCallback( ~, ~, idler )
idler.stopIdling(  );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpn5CzlI.p.
% Please follow local copyright laws when handling this file.

