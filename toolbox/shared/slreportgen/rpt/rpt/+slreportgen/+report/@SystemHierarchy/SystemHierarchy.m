classdef SystemHierarchy < slreportgen.report.Reporter


















































































properties ( Dependent )



Source;
end 

properties 






MaxAncestorLevel{ mlreportgen.utils.validators.mustBeZeroOrPositiveNumber, mustBeNonempty } = inf;







MaxDescendantLevel{ mlreportgen.utils.validators.mustBeZeroOrPositiveNumber, mustBeNonempty } = inf;






IncludePeers{ mlreportgen.report.validators.mustBeLogical } = true;









EmphasizeSource{ mlreportgen.report.validators.mustBeLogical } = true;








ListFormatter;















SourceTextFormatter;










IncludeMaskedSubsystems{ mlreportgen.report.validators.mustBeLogical } = false;





IncludeReferencedModels{ mlreportgen.report.validators.mustBeLogical } = true;









IncludeSimulinkLibraryLinks{ mlreportgen.report.validators.mustBeLogical } = true;









IncludeUserLibraryLinks{ mlreportgen.report.validators.mustBeLogical } = true;











IncludeVariants{ mustBeMember( IncludeVariants,  ...
{ 'All', 'Active', 'ActivePlusCode' } ) } = "Active";
end 

properties ( Access = private, Hidden )

SourceValue = [  ];


SourceHandle = [  ];


HID = [  ];
end 

methods 
function this = SystemHierarchy( varargin )

if ( nargin == 1 )
varObj = varargin{ 1 };
varargin = { "Source", varObj };
end 

this = this@slreportgen.report.Reporter( varargin{ : } );


p = inputParser(  );




p.KeepUnmatched = true;



p.PartialMatching = false;




addParameter( p, "TemplateName", "SystemHierarchy" );

ul = mlreportgen.dom.UnorderedList(  );
ul.StyleName = "SystemHierarchyList";
addParameter( p, "ListFormatter", ul );

text = mlreportgen.dom.Text(  );
text.Bold = true;
text.Italic = true;
addParameter( p, "SourceTextFormatter", text );


parse( p, varargin{ : } );


results = p.Results;
this.TemplateName = results.TemplateName;
this.ListFormatter = results.ListFormatter;
this.SourceTextFormatter = results.SourceTextFormatter;
end 

function value = get.Source( this )
value = this.SourceValue;
end 

function set.Source( this, value )
this.SourceValue = [  ];
this.SourceHandle = [  ];
this.HID = [  ];

if slreportgen.utils.hasDiagram( value )
dhid = slreportgen.utils.HierarchyService.getDiagramHID( value );
this.HID = dhid;
this.SourceValue = value;
this.SourceHandle = slreportgen.utils.getSlSfHandle( dhid );
else 
error( message( "slreportgen:report:error:invalidSystemHierarchySource" ) );
end 
end 

function set.SourceTextFormatter( this, value )
mustBeNonempty( value );
mlreportgen.report.validators.mustBeInstanceOf(  ...
'mlreportgen.dom.Text',  ...
value );
this.SourceTextFormatter = value;
end 

function set.ListFormatter( this, value )
mustBeNonempty( value );
mlreportgen.report.validators.mustBeInstanceOfMultiClass( {  ...
'mlreportgen.dom.UnorderedList',  ...
'mlreportgen.dom.OrderedList' ...
 }, value );

if ~isempty( value.Children )
error( message( "slreportgen:report:error:nonemptyListFormatter" ) );
end 
this.ListFormatter = value;
end 

function impl = getImpl( this, rpt )
R36
this( 1, 1 )
rpt( 1, 1 ){ validateReport( this, rpt ) }
end 

if isempty( this.Source )
error( message( "slreportgen:report:error:noSourceObjectSpecified", class( this ) ) );

elseif ~isempty( this.ListFormatter.Children )
error( message( "slreportgen:report:error:nonemptyListFormatter" ) );

else 




modelH = slreportgen.utils.getModelHandle( this.SourceHandle );
compileModel( rpt, modelH );
impl = getImpl@slreportgen.report.Reporter( this, rpt );
end 
end 
end 

methods ( Access = { ?mlreportgen.report.ReportForm, ?slreportgen.report.SystemHierarchy } )
function content = getContent( this, ~ )

ancestorSystems = {  };



ancestorSystems = findAncestors( this,  ...
this.SourceHandle,  ...
this.MaxAncestorLevel + 1,  ...
ancestorSystems );





ancestorSystems = ancestorSystems( 1:end  - 1 );

if ~isempty( ancestorSystems )


ancestorList = clone( this.ListFormatter );




lastAncestorListItem = createAncestorsList( this,  ...
ancestorSystems,  ...
ancestorList );
end 


peersAndDescendantsList = clone( this.ListFormatter );
createPeersList( this, peersAndDescendantsList );





if ~isempty( ancestorSystems )
append( lastAncestorListItem, peersAndDescendantsList );
content = ancestorList;
else 
content = peersAndDescendantsList;
end 
end 
end 

methods ( Access = private )


function ancestorSystems = findAncestors( this, source, maxAncestorsLevel, ancestorSystems )

if ( maxAncestorsLevel > 0 )
hs = slreportgen.utils.HierarchyService;
dhid = hs.getDiagramHID( source );
phid = hs.getParentDiagramHID( dhid );
parent = slreportgen.utils.getSlSfHandle( phid );

if ~isempty( parent )
ancestorSystems = findAncestors( this,  ...
parent,  ...
maxAncestorsLevel - 1,  ...
ancestorSystems );
end 



obj = slreportgen.utils.getSlSfObject( source );
sourceName = mlreportgen.utils.normalizeString( obj.Name );
link = makeLinkToSlSfDiagram( source, sourceName );
link.StyleName = "SystemHierarchyListItem";
para = mlreportgen.dom.Paragraph(  );
para.WhiteSpace = "preserve";
displayIconPath = getDisplayIcon( source );
append( para, mlreportgen.dom.Image( displayIconPath ) );
append( para, mlreportgen.dom.Text( " " ) );
append( para, link );




ancestorSystems{ end  + 1 } = para;
end 
end 


function lastAncestorListItem = createAncestorsList( this, ancestorSystems, ancestorList )
tempList = [  ];
len = numel( ancestorSystems );
for i = 1:len
append( ancestorList, ancestorSystems{ i } );



if ( i == len )
lastAncestorListItem = ancestorList;
end 
if ~isempty( tempList )
append( tempList, ancestorList );
end 



if ( i ~= len )
newList = clone( this.ListFormatter );
tempList = ancestorList;
ancestorList = newList;
end 
end 
end 





function createPeersList( this, peersAndDescendantslist )

hs = slreportgen.utils.HierarchyService;
phid = hs.getParentDiagramHID( this.HID );
parent = slreportgen.utils.getSlSfHandle( phid );
if this.IncludePeers && ~isempty( parent )


results = findImpl( this, parent );


self = slreportgen.finder.DiagramResult( this.SourceHandle );
results = mergeFinderResults( results, self );
n = numel( results );


for ind = 2:n
peersSystemResult = results( ind );



if ( peersSystemResult.Object == this.SourceHandle )
createDescendantsList( this,  ...
this.SourceHandle,  ...
this.MaxDescendantLevel + 1,  ...
peersAndDescendantslist );
else 
link = makeLinkToSlSfDiagram(  ...
results( ind ),  ...
mlreportgen.utils.normalizeString( peersSystemResult.Name ) );
link.StyleName = "SystemHierarchyListItem";
para = mlreportgen.dom.Paragraph(  );
para.WhiteSpace = "preserve";
displayIconPath = getDisplayIcon( peersSystemResult.Object );
append( para, mlreportgen.dom.Image( displayIconPath ) );
append( para, mlreportgen.dom.Text( " " ) );
append( para, link );
append( peersAndDescendantslist, para );
end 
end 
else 


createDescendantsList( this,  ...
this.SourceHandle,  ...
this.MaxDescendantLevel + 1,  ...
peersAndDescendantslist );
end 
end 


function createDescendantsList( this, source, MaxDescendantLevel, peersAndDescendantslist )
if ( MaxDescendantLevel > 0 )


results = findImpl( this, source );
ind = 1;

if ( ( results( ind ).Object == this.SourceHandle ) && this.EmphasizeSource )
blkName = clone( this.SourceTextFormatter );
blkName.Content = blkName.Content + mlreportgen.utils.normalizeString( results( ind ).Name );
else 
blkName = mlreportgen.utils.normalizeString( results( ind ).Name );
end 

link = makeLinkToSlSfDiagram( results( ind ), blkName );
link.StyleName = "SystemHierarchyListItem";
para = mlreportgen.dom.Paragraph(  );
para.WhiteSpace = "preserve";

displayIconPath = getDisplayIcon( source );

append( para, mlreportgen.dom.Image( displayIconPath ) );

append( para, mlreportgen.dom.Text( " " ) );
append( para, link );
append( peersAndDescendantslist, para );
new_list = clone( this.ListFormatter );



for ind = 2:numel( results )
childSysResult = results( ind );
if ( MaxDescendantLevel - 1 > 0 )
if isa( childSysResult, "slreportgen.finder.DiagramResult" )
createDescendantsList( this,  ...
childSysResult.getDiagramHID,  ...
MaxDescendantLevel - 1,  ...
new_list );
else 
createDescendantsList( this,  ...
childSysResult,  ...
MaxDescendantLevel - 1,  ...
new_list );
end 
end 
end 



if ( ~isempty( new_list.Children ) )
append( peersAndDescendantslist, new_list );
end 
end 
end 

function results = findImpl( this, source )





blockResults = [  ];
diagramFinder = slreportgen.finder.DiagramFinder(  ...
"Container", source,  ...
"SearchDepth", 1,  ...
"IncludeMaskedSubsystems", this.IncludeMaskedSubsystems,  ...
"IncludeReferencedModels", false,  ...
"IncludeSimulinkLibraryLinks", this.IncludeSimulinkLibraryLinks,  ...
"IncludeUserLibraryLinks", this.IncludeUserLibraryLinks,  ...
"IncludeVariants", this.IncludeVariants );
diagramResults = find( diagramFinder );

if ( this.IncludeReferencedModels )
blockFinder = slreportgen.finder.BlockFinder(  ...
"Container", source,  ...
"IncludeVariants", this.IncludeVariants,  ...
"BlockTypes", "ModelReference" );
blockResults = find( blockFinder );
end 
results = mergeFinderResults( diagramResults, blockResults );
end 
end 

methods ( Access = protected, Hidden )

result = openImpl( reporter, impl, varargin )
end 

methods ( Static )
function path = getClassFolder(  )


path = fileparts( mfilename( "fullpath" ) );
end 

function template = createTemplate( templatePath, type )








path = slreportgen.report.SystemHierarchy.getClassFolder(  );
template = mlreportgen.report.ReportForm.createFormTemplate(  ...
templatePath, type, path );
end 

function classFile = customizeReporter( toClasspath )









classFile = mlreportgen.report.ReportForm.customizeClass(  ...
toClasspath, "slreportgen.report.SystemHierarchy" );
end 

end 
end 


function results = mergeFinderResults( diagramResults, otherResults )
if ~isempty( otherResults )


childDiagramResults = diagramResults( 2:end  );


names = [ childDiagramResults.Name, otherResults.Name ];
results = [ childDiagramResults, otherResults ];

[ ~, idx ] = unique( names );
results = [ diagramResults( 1 ), results( idx ) ];
else 
results = diagramResults;
end 
end 


function displayIconPath = getDisplayIcon( source )
tf = false;
if isValidSlObject( slroot, source )
sourceType = get_param( source, "Type" );
tf = strcmp( sourceType, 'block_diagram' );
end 


if ( tf ) || isa( source, 'Stateflow.Chart' )
displayIconPath = slreportgen.utils.getDisplayIcon( source );
else 
ehid = slreportgen.utils.HierarchyService.getElementHID( source );
displayIconPath = slreportgen.utils.getDisplayIcon( ehid );
end 
end 


function link = makeLinkToSlSfDiagram( slsfDiagram, linkText )
hs = slreportgen.utils.HierarchyService;
resultObject = slsfDiagram;


dhid = hs.getDiagramHID( slsfDiagram );
if ~hs.isTopLevel( dhid )



ehid = hs.getElementHID( slsfDiagram );
resultObject = slreportgen.utils.getSlSfHandle( ehid );
end 
link = mlreportgen.dom.InternalLink(  ...
slreportgen.utils.getObjectID( resultObject ),  ...
linkText );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpyhogVm.p.
% Please follow local copyright laws when handling this file.

