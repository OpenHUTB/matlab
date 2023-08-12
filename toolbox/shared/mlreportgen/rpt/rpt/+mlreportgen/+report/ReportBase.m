classdef ( Hidden )ReportBase < mlreportgen.report.ReportForm







properties 











OutputPath{ mustBeString( OutputPath ) } = [  ];












Type{ mustBeValidType( Type ) } = "PDF";
























PackageType








TemplatePath{ mustBeString( TemplatePath ) } = [  ];






























Locale = [  ];









Debug{ mustBeLogical } = false;

end 

properties ( SetAccess = protected )






























Layout{ mustBeInstanceOf(  ...
'mlreportgen.report.ReportLayout', Layout ) } = [  ]
end 

properties ( Hidden )





HTMLHeadExt = '';
TitleBarText = '';
end 

properties ( SetAccess = private )





Document = mlreportgen.dom.Document.empty;







Context = containers.Map.empty;
end 

properties ( SetAccess = private, Hidden )



TemplateSrcCache = [  ];
end 

properties ( Access = private )
IsDocumentOpen = false;
IsDocumentClosed = false;
end 

properties ( Access = protected )
TmpDir{ mustBeString( TmpDir ) } = [  ];
end 

methods 
function rpt = ReportBase( varargin )
rpt = rpt@mlreportgen.report.ReportForm(  );
rpt.Layout = mlreportgen.report.ReportLayout( rpt );
rpt.Context = containers.Map;

switch nargin
case 1
rpt.OutputPath = varargin{ 1 };
case 2
name = char( varargin{ 1 } );

propsMap = mlreportgen.report.ReportForm.getProps(  ...
metaclass( rpt ) );
if isKey( propsMap, name )
set( rpt, name, varargin{ 2 } );
else 
rpt.OutputPath = varargin{ 1 };
rpt.Type = varargin{ 2 };
end 
case 3
rpt.OutputPath = varargin{ 1 };
rpt.Type = varargin{ 2 };
rpt.TemplatePath = varargin{ 3 };
otherwise 
setInformalArg( rpt, varargin{ : } );
end 
rpt.TemplateSrcCache = containers.Map;
end 

function set.Type( rpt, type )
mustBeUnopenedToUpdate( rpt, "Type" );
rpt.Type = type;
end 

function set.PackageType( rpt, pkgType )
mustBeUnopenedToUpdate( rpt, "PackageType" );
rpt.PackageType = pkgType;
end 

function set.TemplatePath( rpt, templatePath )
mustBeUnopenedToUpdate( rpt, "TemplatePath" );
rpt.TemplatePath = templatePath;
end 

function tempPathName = getTempPath( rpt )









if ( isempty( rpt.TmpDir ) )
if rpt.Debug

if isempty( rpt.Document ) ||  ...
strcmp( rpt.Document.OpenStatus, 'unopened' )
open( rpt );
end 
rpt.TmpDir = string( tempname( fileparts( rpt.OutputPath ) ) );
else 
rpt.TmpDir = string( tempname(  ) );
end 
mkdir( char( rpt.TmpDir ) );
end 
tempPathName = rpt.TmpDir;
end 


function fileName = generateFileName( report, varagin )









fileName = string( tempname( char( getTempPath( report ) ) ) );
if nargin == 2

fileName = strcat( fileName, ".", varagin );
end 
end 

function fill( rpt, varargin )






if rpt.IsDocumentClosed
error( message( "mlreportgen:report:error:cannotReopenReport" ) );
end 
if ~rpt.IsDocumentOpen
open( rpt, varargin{ : } )
end 
fillForm( rpt, rpt.Document, rpt );
close( rpt );
end 

function open( rpt, varargin )











mustBeOpenable( rpt );

templatePath = rpt.TemplatePath;
if isempty( templatePath )
templatePath = getDefaultTemplatePath( rpt );
end 
outputPath = rpt.OutputPath;
type = rpt.Type;
if isempty( outputPath )
outputPath = "";
end 


outputPath = char( outputPath );
type = char( type );
templatePath = char( templatePath );





ctr = getImplCtr( rpt );

rpt.Document = ctr( outputPath, type, templatePath );




rpt.Document.HTMLHeadExt = rpt.HTMLHeadExt;
rpt.Document.TitleBarText = rpt.TitleBarText;


if ~isempty( rpt.PackageType )
rpt.Document.PackageType = rpt.PackageType;
end 


rpt.Document.Language = char( rpt.Locale );

result = openImpl( rpt, rpt.Document, varargin{ : } );
if ( result )
rpt.TemplatePath = rpt.Document.TemplatePath;
rpt.OutputPath = rpt.Document.OutputPath;
if ~isempty( rpt.Layout )
updateLayout( rpt.Layout );
end 
rpt.IsDocumentOpen = true;
end 
end 

function close( rpt )








mustBeCloseable( rpt );

if rpt.Debug
rpt.Document.RetainChildren = true;
rpt.Document.RetainFO = true;
end 
close( rpt.Document );
releaseResources( rpt );
rpt.IsDocumentClosed = true;

end 

function delete( rpt )
if ( ~rpt.IsDocumentClosed )
releaseResources( rpt );
end 
end 

function append( rpt, content )



































R36
rpt{ mustBeOpenableReport( rpt ) }
content{ mustBeValidContentForReport( rpt, content ) }
end 

if ~rpt.IsDocumentOpen
open( rpt );
end 


mlreportgen.report.internal.LockedForm.add(  ...
rpt.Document, rpt, content );

if isa( content, 'mlreportgen.dom.PDFPageLayout' )
if ~isempty( rpt.Layout )
updateLayout( rpt.Layout );
end 
end 
end 

function add( rpt, content )










append( rpt, content );
end 

function value = getContext( rpt, key )








value = [  ];
if rpt.Context.isKey( key )
value = rpt.Context( key );
end 
end 

function setContext( rpt, key, value )







rpt.Context( key ) = value;
end 

function removeContext( rpt, key )



if isKey( rpt.Context, key )
remove( rpt.Context, key );
end 
end 

function rptview( rpt )

if ~rpt.IsDocumentOpen
error( message( "mlreportgen:report:error:notOpenedReport" ) );
end 
if ~rpt.IsDocumentClosed
close( rpt );
end 
rptgen.rptview( rpt.Document );
end 

function is = ispdf( rpt )





is = strcmpi( rpt.Type, 'pdf' );
end 

function is = isdocx( rpt )





is = strcmpi( rpt.Type, 'docx' );
end 

function is = ishtml( rpt )





is = strcmpi( rpt.Type, 'html' );
end 

function is = ishtmlfile( rpt )





is = strcmpi( rpt.Type, 'html-file' );
end 

end 

methods 
function layout = getReportLayout( rpt )



























if ~rpt.IsDocumentOpen
open( rpt );
end 
plo = getContext( rpt, 'ReporterLayout' );
if ~isempty( plo )
layout = plo.Layout;
else 
c = rpt.Document.Children;
layouts = c( arrayfun( @( child )isa( child, 'mlreportgen.dom.PageLayout' ), c ) );
if ~isempty( layouts )
layout = layouts( end  );
else 
layout = rpt.Document.CurrentPageLayout;
end 
end 
end 


function [ width, height ] = getPageBodySize( rpt )


units = mlreportgen.utils.units;
pageLayout = getReportLayout( rpt );
pageSize = pageLayout.PageSize;
pageWidth = units.toInches( pageSize.Width );
pageHeight = units.toInches( pageSize.Height );

pageMargins = pageLayout.PageMargins;
pageMarginsTop = units.toInches( pageMargins.Top );
pageMarginsBottom = units.toInches( pageMargins.Bottom );
pageMarginsLeft = units.toInches( pageMargins.Left );
pageMarginsRight = units.toInches( pageMargins.Right );
pageMarginsHeader = units.toInches( pageMargins.Header );
pageMarginsFooter = units.toInches( pageMargins.Footer );
pageMarginsGutter = units.toInches( pageMargins.Gutter );

height = pageHeight - pageMarginsTop - pageMarginsBottom;

















if strcmpi( rpt.Type, "pdf" )
height = height - pageMarginsHeader - pageMarginsFooter;
end 

width = pageWidth ...
 - pageMarginsLeft ...
 - pageMarginsRight ...
 - pageMarginsGutter;
end 

end 

methods ( Hidden )
function templatePath = getDefaultTemplatePath( rpt )



templatePath = '';
if ismethod( rpt, 'getClassFolder' )
reportPath = rpt.getClassFolder(  );
templatePath =  ...
mlreportgen.report.ReportForm.getFormTemplatePath(  ...
reportPath, rpt.Type );
end 
end 

function supportingFolder = getSupportingFolder( rpt )






[ reportFolder, reportName ] = fileparts( rpt.OutputPath );

success = 1;
if isempty( reportFolder )
reportFolder = pwd;
end 

supportingFolder = fullfile( reportFolder, [ reportName, '_supportingfiles' ] );
if ~isfolder( supportingFolder )
success = mkdir( supportingFolder );
end 

if ~success
error( message( "mlreportgen:report:error:cannotCreateSupportingFolder" ) );
end 
end 
end 

methods ( Access = protected, Hidden )
function result = openImpl( rpt, impl, varargin )
if isempty( varargin )
key = '';
else 
key = varargin{ 1 };
end 
result = open( impl, key, rpt );
end 
end 

methods ( Access = protected )

function mustBeUnopenedToUpdate( rpt, propName )
if rpt.IsDocumentClosed || rpt.IsDocumentOpen
error( message( "mlreportgen:report:error:unableTotUpdatePropertyAfterOpen", propName ) );
end 
end 

function mustBeOpenable( rpt )



if rpt.IsDocumentClosed || rpt.IsDocumentOpen
error( message( "mlreportgen:report:error:cannotReopenReport" ) );
end 
end 

function mustBeCloseable( rpt )



if rpt.IsDocumentClosed
error( message( "mlreportgen:report:error:cannotRecloseReport" ) );
end 
if ~rpt.IsDocumentOpen
error( message( "mlreportgen:report:error:notOpenedReport" ) );
end 
end 

function processHole( rpt, form, ~ )

if strcmp( form.CurrentHoleId( 1 ), '#' )
if ~isempty( rpt.Layout ) && ~isa( form, 'mlreportgen.dom.PageHdrFtr' )
updateLayout( rpt.Layout );
end 
else 
fillHole( rpt, form, rpt );
end 
end 

function releaseResources( rpt )
removeFile = isempty( rpt.Debug ) || ~rpt.Debug;
if ( ~isempty( rpt.TmpDir ) && removeFile )
rmdir( char( rpt.TmpDir ), 's' );
rpt.TmpDir = [  ];
end 
end 
end 

methods ( Static )

function createTemplate( templatePath, type )



path = mlreportgen.report.Report.getClassFolder(  );
mlreportgen.report.ReportForm.createFormTemplate(  ...
templatePath, type, path );
end 

end 

methods ( Static, Hidden )

function folder = getFolderType( type )
folder = lower( type );
if strcmp( folder, 'html-file' )
folder = 'html';
end 
end 

end 

end 


function mustBeValidType( type )
mlreportgen.report.validators.mustBeString( type );
mustBeNonempty( type );

if ischar( type )
type = string( type );
end 
mustBeMember( lower( type ), [ "pdf", "docx", "html", "html-file" ] );
end 

function mustBeLogical( varargin )
mlreportgen.report.validators.mustBeLogical( varargin{ : } );
end 

function mustBeString( varargin )
mlreportgen.report.validators.mustBeString( varargin{ : } );
end 

function mustBeInstanceOf( varargin )
mlreportgen.report.validators.mustBeInstanceOf( varargin{ : } );
end 

function mustBeOpenableReport( rpt )
if rpt.IsDocumentClosed
error( message( "mlreportgen:report:error:cannotAddClosedReport" ) );
end 
end 

function mustBeValidContentForReport( rpt, content )
if isa( content, "mlreportgen.report.ReporterBase" )




validateReport( content, rpt );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpOWmuMI.p.
% Please follow local copyright laws when handling this file.

