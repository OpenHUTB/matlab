classdef FunctionReference < slreportgen.report.Reporter












































































properties ( SetAccess = { ?slreportgen.finder.FunctionReferenceResult, ?mlreportgen.report.ReportForm } )





Object;
end 

properties 







ShowReferencesTable( 1, 1 )logical = true;








ShowFunctionType( 1, 1 )logical = true;










ShowFunctionFile( 1, 1 )logical = true;















FunctionFileDisplayPolicy = "code";






Title{ mlreportgen.report.validators.mustBeInline } = string.empty(  );













TableReporter










MATLABCodeReporter













ParagraphFormatter
end 

methods ( Access = { ?slreportgen.finder.FunctionReferenceResult } )
function this = FunctionReference( varargin )
if nargin == 1
result = varargin{ 1 };
varargin = { "Object", result };
end 

this = this@slreportgen.report.Reporter( varargin{ : } );


p = inputParser;




p.KeepUnmatched = true;




addParameter( p, "TemplateName", "FunctionReference" );

baseTable = mlreportgen.report.BaseTable(  );
baseTable.TableStyleName = "FunctionReferenceTable";
addParameter( p, "TableReporter", baseTable );

para = mlreportgen.dom.Paragraph(  );
para.StyleName = "FunctionReferenceParagraph";
addParameter( p, "ParagraphFormatter", para );

mlCode = mlreportgen.report.MATLABCode(  );
addParameter( p, "MATLABCodeReporter", mlCode );


parse( p, varargin{ : } );


result = p.Results;
this.TemplateName = result.TemplateName;
this.TableReporter = result.TableReporter;
this.MATLABCodeReporter = result.MATLABCodeReporter;
this.ParagraphFormatter = result.ParagraphFormatter;
end 
end 

methods 
function set.FunctionFileDisplayPolicy( this, value )
normVal = lower( value );
mustBeMember( normVal, [ "code", "text" ] );

this.FunctionFileDisplayPolicy = value;
end 

function set.ParagraphFormatter( this, value )


mustBeA( value, "mlreportgen.dom.Paragraph" );


mustBeScalarOrEmpty( value );

this.ParagraphFormatter = value;
end 

function set.MATLABCodeReporter( this, value )


mustBeA( value, "mlreportgen.report.MATLABCode" );


mustBeScalarOrEmpty( value );

this.MATLABCodeReporter = value;
end 

function set.TableReporter( this, value )


mustBeA( value, "mlreportgen.report.BaseTable" );


mustBeScalarOrEmpty( value );

this.TableReporter = value;
end 

function impl = getImpl( this, rpt )
R36
this( 1, 1 )
rpt( 1, 1 ){ validateReport( this, rpt ) }
end 

if isempty( this.LinkTarget )
this.LinkTarget = slreportgen.report.FunctionReference.getLinkTargetID(  ...
this.Object.Object, this.Object.FilePath );
end 



impl = getImpl@slreportgen.report.Reporter( this, rpt );
end 
end 

methods ( Access = { ?mlreportgen.report.ReportForm, ?slreportgen.report.FunctionReference } )

function content = getTableContent( this, rpt )

content = [  ];
if this.ShowReferencesTable
obj = this.Object;



[ users, ~, usersIdx ] = unique( obj.CallingBlocks );


nUsers = numel( users );
tableData = cell( nUsers, 3 );
for idx = 1:nUsers
currUser = users( idx );

tableData{ idx, 1 } = mlreportgen.dom.InternalLink(  ...
slreportgen.utils.getObjectID( currUser ),  ...
currUser );


blkParams = obj.BlockParameters( usersIdx == idx );
callStrs = obj.CallingExpressions( usersIdx == idx );
if numel( callStrs ) > 1



paramList = mlreportgen.dom.UnorderedList( blkParams );
paramList.StyleName = "FunctionReferenceList";
tableData{ idx, 2 } = paramList;
valList = mlreportgen.dom.UnorderedList( callStrs );
valList.StyleName = "FunctionReferenceList";
tableData{ idx, 3 } = valList;
else 
tableData{ idx, 2 } = blkParams;
tableData{ idx, 3 } = callStrs;
end 
end 


if ~isempty( tableData )
tableHeaders = { getString( message( "slreportgen:report:FunctionReference:block" ) ),  ...
getString( message( "slreportgen:report:FunctionReference:parameter" ) ),  ...
getString( message( "slreportgen:report:FunctionReference:value" ) ) };
ft = mlreportgen.dom.FormalTable( tableHeaders, tableData );

content = copy( this.TableReporter );
content.Content = ft;




titleReporter = getTitleReporter( content );
titleReporter.TemplateSrc = this;
if isChapterNumberHierarchical( this, rpt )
titleReporter.TemplateName = "FcnReferenceHierNumberedTitle";
else 
titleReporter.TemplateName = "FcnReferenceNumberedTitle";
end 
content.Title = titleReporter;

titleContent = this.Title;
if isempty( titleContent ) || titleContent == ""
titleContent = obj.Object + " " +  ...
getString( message( "slreportgen:report:FunctionReference:references" ) );
end 
appendTitle( content, titleContent );
end 
end 
end 

function content = getFunctionTypeContent( this, ~ )
content = [  ];
if this.ShowFunctionType

content = clone( this.ParagraphFormatter );
labelText = mlreportgen.dom.Text(  ...
getString( message( "slreportgen:report:FunctionReference:functionType" ) ) + ": " );
labelText.StyleName = "FunctionReferenceLabel";
labelText.WhiteSpace = "preserve";
append( content, labelText );
append( content, this.Object.FunctionType );
end 
end 

function content = getFunctionFileContent( this, ~ )
content = [  ];
obj = this.Object;
filePath = obj.FilePath;
if this.ShowFunctionFile && ~isempty( filePath )

if endsWith( filePath, ".p", IgnoreCase = true )


dotPPattern = "." + ( "p" | "P" ) + textBoundary;
mFile = extractBefore( filePath, dotPPattern ) + ".m";
if isfile( mFile )
filePath = mFile;
end 
end 

if strcmpi( this.FunctionFileDisplayPolicy, "code" ) && endsWith( filePath, "." + ( "m" | "mlx" ), IgnoreCase = true )



codeLabel = mlreportgen.dom.Text( obj.Object ...
 + " " + getString( message( "slreportgen:report:FunctionReference:code" ) ) );
codeLabel.StyleName = "FunctionReferenceLabel";
codeLabelPara = clone( this.ParagraphFormatter );
append( codeLabelPara, codeLabel );
codeRptr = copy( this.MATLABCodeReporter );
codeRptr.FileName = filePath;
content = { codeLabelPara, codeRptr };
else 

content = clone( this.ParagraphFormatter );
labelText = mlreportgen.dom.Text(  ...
getString( message( "slreportgen:report:FunctionReference:functionFilePath" ) ) + ": " );
labelText.StyleName = "FunctionReferenceLabel";
append( content, labelText );
append( content, obj.FilePath );
end 
end 
end 
end 

methods ( Access = protected, Hidden )

result = openImpl( reporter, impl, varargin )

end 

methods ( Static, Hidden )
function id = getLinkTargetID( name, path )




linkText = "function-reference-" + name + "-" + path;
id = mlreportgen.utils.normalizeLinkID( linkText );
end 
end 

methods ( Hidden )
function templatePath = getDefaultTemplatePath( ~, rpt )
path = slreportgen.report.FunctionReference.getClassFolder(  );
templatePath =  ...
mlreportgen.report.ReportForm.getFormTemplatePath(  ...
path, rpt.Type );
end 

end 

methods ( Static )
function path = getClassFolder(  )



[ path ] = fileparts( mfilename( 'fullpath' ) );
end 

function template = createTemplate( templatePath, type )







path = slreportgen.report.FunctionReference.getClassFolder(  );
template = mlreportgen.report.ReportForm.createFormTemplate(  ...
templatePath, type, path );
end 

function classfile = customizeReporter( toClasspath )









classfile = mlreportgen.report.ReportForm.customizeClass( toClasspath,  ...
"slreportgen.report.FunctionReference" );
end 

end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpTklKbm.p.
% Please follow local copyright laws when handling this file.

