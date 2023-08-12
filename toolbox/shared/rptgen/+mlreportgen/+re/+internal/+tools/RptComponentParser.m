classdef ( Hidden )RptComponentParser < handle





properties ( Constant )
ELEMENT_REGISTRY string = "registry";
ELEMENT_CATEGORY string = "category";
ELEMENT_COMPONENT string = "component";
ELEMENT_COMPONENTV1 string = "component_v1";

PUBLIC_ID string = "//MathWorks//Report Generator Component Registry v2.0//EN";
SYSTEM_ID string = "http://www.mathworks.com/namespace/rptgen/v2/rptcomps.xsd";

ATT_CLASS string = "class";
end 

properties ( Access = private )
XMLParser
XMLWriter
end 

methods ( Static )
function out = instance(  )
persistent INSTANCE
if isempty( INSTANCE )
INSTANCE = mlreportgen.re.internal.tools.RptComponentParser(  );
end 
out = INSTANCE;
end 

function compList = getComponentList( fileURN )

R36
fileURN string
end 

this = mlreportgen.re.internal.tools.RptComponentParser.instance(  );
d = this.parse( fileURN );

cList = d.getElementsByTagName( this.ELEMENT_REGISTRY ).item( 0 );
allComps = cList.getElementsByTagName( this.ELEMENT_COMPONENT );
n = allComps.getLength(  );
compList = string.empty( 0, n );
for i = 1:n
compList( i ) = allComps.item( i - 1 ).getAttribute( this.ATT_CLASS );
end 
end 

function appendComponent( in, className, displayName, categoryName, v1Names, categoryHelpFile )

R36
in
className string
displayName string
categoryName string
v1Names string
categoryHelpFile string
end 

this = mlreportgen.re.internal.tools.RptComponentParser.instance(  );

if isa( in, "matlab.io.xml.dom.Document" )
this.appendComponentImpl( in, className, displayName, categoryName, v1Names, categoryHelpFile )
else 
try 
registry = this.parse( in );
catch 
registry = this.createRegistry(  );
end 
this.appendComponentImpl( registry, className, displayName, categoryName, v1Names, categoryHelpFile );
this.write( registry, in );
end 
end 
end 

methods ( Access = private )
function this = RptComponentParser(  )
this.XMLParser = matlab.io.xml.dom.Parser(  );
this.XMLParser.Configuration.Validate = false;
this.XMLWriter = matlab.io.xml.dom.DOMWriter(  );
this.XMLWriter.Configuration.FormatPrettyPrint = true;
end 

function componentEl = appendComponentImpl( this, registry, className, displayName, categoryName, v1Names, categoryHelpFile )

R36
this
registry matlab.io.xml.dom.Document
className string
displayName string
categoryName string
v1Names string
categoryHelpFile string = string.empty(  );
end 






this.removeComponentElement( registry, className );

categoryEl = this.getCategoryElement( registry, categoryName );
if ( ~isempty( categoryHelpFile ) && ( categoryHelpFile.strlength(  ) > 0 ) )
categoryEl.setAttribute( "HelpHtmlFile", categoryHelpFile );
end 

componentEl = this.createComponentElement( registry, className, displayName, v1Names );
categoryEl.appendChild( componentEl );
end 

function d = parse( this, fileURN )
R36
this
fileURN string
end 
d = this.XMLParser.parseFile( fileURN );
end 

function write( this, registry, fileURN )
R36
this
registry matlab.io.xml.dom.Document
fileURN string
end 
this.XMLWriter.writeToFile( registry, fileURN );
end 

function cEl = createComponentElement( this, registry, className, displayName, v1Names )




R36
this
registry matlab.io.xml.dom.Document
className string
displayName string
v1Names string
end 

cEl = registry.createElement( this.ELEMENT_COMPONENT );
cEl.setAttribute( this.ATT_CLASS, className );
cEl.setAttribute( "name", displayName );

for v1Name = v1Names
cV1 = registry.createElement( this.ELEMENT_COMPONENTV1 );
cV1.setAttribute( this.ATT_CLASS, v1Name );
cEl.appendChild( cV1 );
end 
end 

function compEl = removeComponentElement( this, registry, className )





R36
this
registry matlab.io.xml.dom.Document
className string
end 

if ( isempty( className ) || ( className.strlength(  ) == 0 ) )
compEl = matlab.io.xml.dom.Element.empty(  );
return ;
end 

allComps = registry.getElementsByTagName( this.ELEMENT_COMPONENT );
n = allComps.getLength(  );
for i = 1:n
compEl = allComps.item( i - 1 );
if strcmpi( className, compEl.getAttribute( this.ATT_CLASS ) )
compEl.getParentNode(  ).removeChild( compEl );
return 
end 
end 

compEl = matlab.io.xml.dom.Element.empty(  );
end 

function categoryElement = getCategoryElement( this, registry, catName )







R36
this
registry matlab.io.xml.dom.Document
catName string
end 

allCategories = registry.getElementsByTagName( this.ELEMENT_CATEGORY );
n = allCategories.getLength(  );
for i = 1:n
categoryElement = allCategories.item( i - 1 );
if strcmpi( catName, categoryElement.getAttribute( "name" ) )
return ;
end 
end 

categoryElement = registry.createElement( this.ELEMENT_CATEGORY );
categoryElement.setAttribute( "name", catName );
registry.getDocumentElement(  ).appendChild( categoryElement );
end 

function registry = createRegistry( this )


registry = matlab.io.xml.dom.Document(  );
docEl = registry.createElement( this.ELEMENT_REGISTRY );
registry.appendChild( docEl );

docEl.appendChild( registry.createComment(  ...
sprintf( "\nMathWorks Report Generator Component Registry v2.0\n" ) ) );
registry.insertBefore(  ...
registry.createComment( sprintf( "\nThis file is used by the Report Generator to determine which components to \ndisplay in the Report Explorer.  Please exercise caution when editing this \nfile.  If the XML syntax is corrupted, none of the components defined in \nthis file will be available in the Report Explorer.  The 'name' and \n'category' information in this file are duplicated in the component's \nGETNAME and GETTYPE methods.\n" ) ),  ...
docEl );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpD96XRT.p.
% Please follow local copyright laws when handling this file.

