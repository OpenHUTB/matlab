function pathInfo = createReport( NameValueArgs )






R36
NameValueArgs.Type = 'ppt';
NameValueArgs.Title = 'MSA report';
NameValueArgs.FileName = 'MSAReport';
NameValueArgs.OutputDir = pwd;
NameValueArgs.Images;
NameValueArgs.Description = {  };
end 
import mlreportgen.ppt.*;
import mlreportgen.dom.*
import mlreportgen.report.*



fileName = NameValueArgs.FileName;





images = NameValueArgs.Images;
for i = 1:length( NameValueArgs.Images )
exportgraphics( images{ i }, fullfile( NameValueArgs.OutputDir, [ 'tempImage', num2str( i ), '.png' ] ) );
end 

haveRptGen = ~isempty( ver( 'rptgen' ) );
if ( haveRptGen && contains( NameValueArgs.Type, { 'ppt', 'doc' } ) )
if ( strcmp( NameValueArgs.Type, 'ppt' ) )
pathInfo = fullfile( NameValueArgs.OutputDir, [ fileName, '.pptx' ] );
slidesFile = fullfile( NameValueArgs.OutputDir, [ fileName, '.pptx' ] );
slides = Presentation( slidesFile );
open( slides );
presentationTitleSlide = add( slides, 'Title Slide' );
replace( presentationTitleSlide, 'Title', NameValueArgs.Title );
for i = 1:length( NameValueArgs.Images )
plot1 = Picture( fullfile( NameValueArgs.OutputDir, [ 'tempImage', num2str( i ), '.png' ] ) );
pictureSlide = add( slides, 'Title and Content' );
replace( pictureSlide, 'Title', NameValueArgs.Description{ i } );
contents = find( pictureSlide, 'Content' );
replace( contents( 1 ), plot1 );
end 
close( slides );
end 

if ( strcmp( NameValueArgs.Type, 'doc' ) )
pathInfo = fullfile( NameValueArgs.OutputDir, [ fileName, '.docx' ] );
rpt = Report( fullfile( NameValueArgs.OutputDir, fileName ), "docx" );
open( rpt );
pageLayoutObj = DOCXPageLayout;
pageLayoutObj.PageSize.Orientation = "portrait";
add( rpt, pageLayoutObj );
tp = TitlePage(  );
tp.Title = NameValueArgs.Title;
add( rpt, tp );
for i = 1:length( NameValueArgs.Images )
chapter = Chapter( 'Title', NameValueArgs.Description{ i }, 'Numbered', false );
fig = Image( fullfile( NameValueArgs.OutputDir, [ 'tempImage', num2str( i ), '.png' ] ) );
fig.Style = [ fig.Style, { ScaleToFit } ];
add( chapter, fig );
add( rpt, chapter );
end 
close( rpt );
end 


for i = 1:length( NameValueArgs.Images )
delete( fullfile( NameValueArgs.OutputDir, [ 'tempImage', num2str( i ), '.png' ] ) );
end 
else 
fileName = [ fileName, '.m' ];
fid = fopen( fileName, 'a' );


for i = 1:length( NameValueArgs.Images )
image = fullfile( NameValueArgs.OutputDir, [ 'tempImage', num2str( i ), '.png' ] );
if ( ~isempty( NameValueArgs.Description ) )
if ( i == 1 )
fprintf( fid, '%%%% %s\n%%\n%% <<%s>>\n%%\n%% %s\n', NameValueArgs.Title,  ...
image, NameValueArgs.Description{ i } );
else 
fprintf( fid, '%%%%\n%%\n%% <<%s>>\n%%\n%% %s\n',  ...
image, NameValueArgs.Description{ i } );
end 
else 
if ( i == 1 )
fprintf( fid, '%%%% %s\n%%\n%%\n%% <<%s>>\n%%\n',  ...
NameValueArgs.Title, image );
else 
fprintf( fid, '%%%%\n%%\n%% <<%s>>\n%%\n', image );
end 
end 
end 
fclose( fid );



publish( fileName, 'format', NameValueArgs.Type, 'outputDir', NameValueArgs.OutputDir, 'showCode', false, 'evalCode', false );
delete( fileName );

if ( ~strcmp( NameValueArgs.Type, 'html' ) )
for i = 1:length( NameValueArgs.Images )
image = fullfile( NameValueArgs.OutputDir, [ 'tempImage', num2str( i ), '.png' ] );
delete( image );
end 
end 
fileNameSplit = split( fileName, '.' );
pathInfo = fullfile( NameValueArgs.OutputDir, [ fileNameSplit{ 1 }, '.', NameValueArgs.Type ] );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpyOn69G.p.
% Please follow local copyright laws when handling this file.

