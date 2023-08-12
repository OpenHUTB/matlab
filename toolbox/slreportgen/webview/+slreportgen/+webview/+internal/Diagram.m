classdef Diagram < handle































































properties ( SetAccess = private )


Name = string.empty(  )
end 

properties ( Dependent )


FullName
end 

properties ( SetAccess = private )



SID = string.empty(  )














ESID = string.empty(  )

















RSID = string.empty(  )



Model = slreportgen.webview.internal.Model.empty(  )



Part = slreportgen.webview.internal.Part.empty(  )




Parent = slreportgen.webview.internal.Diagram.empty(  )



Children = slreportgen.webview.internal.Diagram.empty(  )
end 

properties ( SetAccess = private )

ClassName = string.empty(  )




DisplayLabel = string.empty(  )




DisplayIcon = string.empty(  )


IsModelReference = false;


IsSubsystemReference = false;


IsVariantSubsystem = false;


IsMaskedSubsystem = false;


IsUserLink = false;


IsMathworksLink = false;


IsCommented = false;
end 

properties ( Hidden, SetAccess = private )
ReferencedModels = {  }
ReferencedSubsystems = {  }
end 

properties ( Transient )

Selected logical = true


Visible logical = true;


ExportData slreportgen.webview.internal.DiagramExportData
end 

properties ( Transient, Access = private )
HID = GLUE2.HierarchyId.empty(  )
Handle

EHID = GLUE2.HierarchyId.empty(  )
EHandle

SlProxyObject = slreportgen.webview.SlProxyObject.empty(  )

FullNameCacheValue = string.empty(  )

NormalizedNameCacheValue = string.empty(  )
PathCacheValue = string.empty(  )
end 

properties ( Access = private )
ActiveVariant = slreportgen.webview.internal.Diagram.empty(  )
ActiveVariantPlusCode = slreportgen.webview.internal.Diagram.empty(  )
end 

methods 
function out = get.FullName( this )
if isempty( this.FullNameCacheValue )
this.FullNameCacheValue = this.fullname(  );
end 
out = this.FullNameCacheValue;
end 

function out = path( this )






if isempty( this.PathCacheValue )
if isempty( this.Parent )
this.PathCacheValue = this.Name;
else 
this.PathCacheValue = slreportgen.utils.pathJoin( this.Parent.path(  ), this.normalizedName(  ) );
end 
end 
out = this.PathCacheValue;
end 

function out = hid( this, options )










R36
this
options.Validate logical = true
end 

if ~options.Validate
out = this.HID;
return 
end 

if slreportgen.utils.HierarchyService.isValid( this.HID )
out = this.HID;
return ;
else 
this.HID = GLUE2.HierarchyId.empty(  );
end 

if ~isempty( this.SlProxyObject )


this.HID = slreportgen.utils.HierarchyService.getDiagramHID( this.path(  ) );

else 



this.initPartBackings(  );
end 

out = this.HID;
end 

function out = handle( this )



if isempty( this.Handle ) || ~ishandle( this.Handle )
this.Handle = slreportgen.utils.getSlSfHandle( this.hid(  ) );
end 
out = this.Handle;
end 

function out = slproxyobject( this )




if isempty( this.SlProxyObject )
this.SlProxyObject = slreportgen.webview.SlProxyObject( this.handle(  ) );
end 
out = this.SlProxyObject;
end 

function out = ehid( this )



if isempty( this.EHID ) && ~isempty( this.Parent )
this.EHID = slreportgen.utils.HierarchyService.getElementHID( this.hid(  ) );
end 
out = this.EHID;
end 

function out = ehandle( this )



if ~isempty( this.Parent ) && isempty( this.EHandle )
this.EHandle = slreportgen.utils.getSlSfHandle( this.ehid(  ) );
end 
out = this.EHandle;
end 

function out = elements( this )



out = this.Model.getElementList( this );
end 

function out = descendants( this )



out = slreportgen.webview.internal.Diagram.empty( 0, this.Model.DiagramCount );
it = slreportgen.webview.internal.DiagramIterator( this );
it.next(  );
count = 0;
while it.hasNext(  )
count = count + 1;
out( count ) = it.next(  );
end 
out( count + 1:end  ) = [  ];
end 

function tf = hasChildren( this )



tf = ~isempty( this.Children );
end 

function out = query( this, varargin )














out = slreportgen.webview.internal.query(  ...
slreportgen.webview.internal.DiagramIterator( this ), varargin{ : } );
end 

function referencedDiagrams = loadReferencedModels( this, options )









R36
this
options.Force logical = false
end 

if ~isempty( this.ReferencedModels )
n = numel( this.ReferencedModels );
referencedDiagrams = slreportgen.webview.internal.Diagram.empty( 0, n );
for i = 1:n
referencedDiagrams( i ) = slreportgen.webview.internal.ReferenceDiagramInterface.loadReferencedModel(  ...
this, this.ReferencedModels{ i }, "Force", options.Force );
end 
this.sortChildren(  );
this.ReferencedModels = {  };
else 
referencedDiagrams = slreportgen.webview.internal.Diagram.empty(  );
end 
end 

function referencedDiagrams = loadReferencedSubsystems( this, options )










R36
this
options.Force logical = false
end 

if ~isempty( this.ReferencedSubsystems )
n = numel( this.ReferencedSubsystems );
referencedDiagrams = slreportgen.webview.internal.Diagram.empty( 0, n );
for i = 1:n
referencedDiagrams( i ) = slreportgen.webview.internal.ReferenceDiagramInterface.loadReferencedSubsystem(  ...
this, this.ReferencedSubsystems{ i }, "Force", options.Force );
end 
this.sortChildren(  );
this.ReferencedSubsystems = {  };
else 
referencedDiagrams = slreportgen.webview.internal.Diagram.empty(  );
end 
end 

function out = activeVariant( this )




out = this.ActiveVariant;
end 

function out = activeVariantPlusCode( this )





out = this.ActiveVariantPlusCode;
end 

function out = normalizedName( this )



if isempty( this.NormalizedNameCacheValue )
this.NormalizedNameCacheValue = regexprep( this.Name, "\s", " " );
end 
out = this.NormalizedNameCacheValue;
end 
end 

methods ( Access = ?slreportgen.webview.internal.ModelBuilder )
function sortChildren( this )
[ ~, idx ] = sort( [ this.Children.Name ] );
this.Children = this.Children( idx );
end 
end 

methods ( Access = ?slreportgen.webview.internal.DiagramBuilder )
function this = Diagram( model )



this.Model = model;
model.addDiagram( this );
end 
end 

methods ( Access = ?slreportgen.webview.internal.Part )
function setPart( this, part )
this.Part = part;
end 
end 

methods ( Access = ?slreportgen.webview.internal.Element )
function loadElementHandles( this )
this.Model.loadElementHandles( this );
end 
end 

methods ( Access = ?slreportgen.webview.internal.ReferenceDiagramInterface )
function addReferencedModel( this, referenceModel )
this.ReferencedModels{ end  + 1 } = referenceModel;
end 

function addReferencedSubsystem( this, referenceSubsystem )
this.ReferencedSubsystems{ end  + 1 } = referenceSubsystem;
end 

function setModel( this, value )
this.Model = value;
end 
end 

methods ( Access = {  ...
?slreportgen.webview.internal.DiagramBuilder,  ...
?slreportgen.webview.internal.ReferenceDiagramInterface } )
function setParent( this, parent )
assert( isempty( this.Parent ) )
if ~isempty( parent )
this.Parent = parent;
parent.Children( end  + 1 ) = this;
end 
end 

function setName( this, value )
this.Name = string( value );
this.NormalizedNameCacheValue = string.empty(  );
this.PathCacheValue = string.empty(  );
end 

function setClassName( this, value )
this.ClassName = string( value );
end 

function setDisplayIcon( this, icon )
this.DisplayIcon = string( icon );
end 

function setDisplayLabel( this, label )
this.DisplayLabel = string( label );
end 

function setESID( this, esid )
this.ESID = string( esid );
end 

function setSID( this, sid )
this.SID = string( sid );
end 

function setRSID( this, rsid )
this.RSID = string( rsid );
end 

function setHID( this, hid )
this.HID = hid;
end 

function setEHID( this, ehid )
this.EHID = ehid;
end 

function setHandle( this, hnd )
this.Handle = hnd;
end 

function setSlProxyObject( this, slpobj )
this.SlProxyObject = slpobj;
end 

function setEHandle( this, ehnd )
this.EHandle = ehnd;
end 

function setIsModelReference( this, tf )
this.IsModelReference = tf;
end 

function setIsSubsystemReference( this, tf )
this.IsSubsystemReference = tf;
end 

function setIsMaskedSubsystem( this, tf )
this.IsMaskedSubsystem = tf;
end 

function setIsVariantSubsystem( this, tf )
this.IsVariantSubsystem = tf;
end 

function setActiveVariant( this, diagram )
this.ActiveVariant = diagram;
end 

function setActiveVariantPlusCode( this, diagram )
this.ActiveVariantPlusCode = diagram;
end 

function setIsUserLink( this, tf )
this.IsUserLink = tf;
end 

function setIsMathworksLink( this, tf )
this.IsMathworksLink = tf;
end 

function setIsCommented( this, tf )
this.IsCommented = tf;
end 
end 

methods ( Access = private )
function out = fullname( this )
if isempty( this.Parent )
out = this.Name;
else 
out = slreportgen.utils.pathJoin( this.Parent.FullName, this.Name );
end 
end 

function initPartBackings( this )
hs = slreportgen.utils.HierarchyService;
partHID = this.loadPartHID(  );

this.loadPartLibraries(  );

diagrams = this.Part.Diagrams;
nDiagrams = numel( diagrams );
assigned = false( 1, nDiagrams );

stack = { partHID };
top = 1;
while ( top > 0 )
dhid = stack{ top };
top = top - 1;


slpobj = slreportgen.webview.SlProxyObject( dhid );
for i = 1:nDiagrams
if ~assigned( i )
diagram = diagrams( i );
if isempty( diagram.SlProxyObject )
if strcmp( diagram.SID, slpobj.SID )
diagram.HID = dhid;
diagram.Handle = slreportgen.utils.getSlSfHandle( dhid );
diagram.SlProxyObject = slpobj;
assigned( i ) = true;
break ;
end 
else 
assigned( i ) = true;
end 
end 
end 


cehids = hs.getChildren( dhid );
ncehids = numel( cehids );
if ( top + ncehids ) > numel( stack )
stack{ top + ncehids } = [  ];
end 

for i = 1:ncehids
cehid = cehids( i );
cehnd = slreportgen.utils.getSlSfHandle( cehid );
if slreportgen.utils.isModelReferenceBlock( cehnd, Resolve = false ) ...
 || slreportgen.utils.isSubsystemReferenceBlock( cehnd, Resolve = false )
continue ;
end 
cdhid = hs.getChildren( cehid );
top = top + 1;
stack{ top } = cdhid( 1 );
end 
end 
end 

function loadPartLibraries( this )
diagrams = this.Part.Diagrams;
for i = 1:numel( diagrams )
diagram = diagrams( i );
if ( diagram.Selected && ( diagram.IsUserLink || diagram.IsMathworksLink ) )
slreportgen.utils.loadAllSystems( this.Part.RootDiagram.RSID );
break ;
end 
end 
end 

function partHID = loadPartHID( this )
hs = slreportgen.utils.HierarchyService;
part = this.Part;
try 
partHID = hs.getDiagramHID( part.RootDiagram.FullName );
catch 

parent = this;
while ~isempty( parent )
if ( parent.IsModelReference || parent.IsSubsystemReference || isempty( parent.Parent ) )
load_system( parent.RSID );
end 
parent = parent.Parent;
end 
partHID = hs.getDiagramHID( part.RootDiagram.FullName );
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp5cJR0V.p.
% Please follow local copyright laws when handling this file.

