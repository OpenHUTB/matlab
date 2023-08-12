classdef DiagramSelector < handle









































properties 





Scope string{ mustBeMember( Scope, [ "Current", "CurrentAndAbove", "CurrentAndBelow" ] ) } = "Current"



IncludeReferencedModels logical = true



IncludeMaskedSubsystems logical = true








IncludeVariantSubsystems string{ mustBeMember( IncludeVariantSubsystems, [ "All", "Active", "ActivePlusCode" ] ) } = "All";



IncludeSimulinkLibraryLinks logical = true



IncludeUserLibraryLinks logical = true



IncludeCommentedDiagrams logical = true




TraversalCallback = [  ]
end 

properties ( Access = private )
IncludeAllVariants logical;
IncludeActiveVariants logical;
end 

methods ( Static )
function unselectAll( models )



R36
models( 1, : )slreportgen.webview.internal.Model;
end 

for i = 1:numel( models )
model = models( i );
diagrams = model.Diagrams;
for j = 1:numel( diagrams )
diagram = diagrams( j );
diagram.Selected = false;
diagram.Visible = false;
end 
end 
end 

function out = getSelectedDiagrams( models )



R36
models( 1, : )slreportgen.webview.internal.Model;
end 

out = [  ];
for i = 1:numel( models )
model = models( i );
out = [ out, model.Diagrams( [ model.Diagrams.Selected ] ) ];%#ok
end 
end 

function out = getSelectedPaths( models )



R36
models( 1, : )slreportgen.webview.internal.Model;
end 

selected = slreportgen.webview.internal.DiagramSelector.getSelectedDiagrams( models );
n = numel( selected );
out = string.empty( 0, n );
for i = 1:n
out( i ) = selected( i ).path(  );
end 
end 
end 

methods 
function this = DiagramSelector(  )
end 

function select( this, diagram )



R36
this
diagram slreportgen.webview.internal.Diagram
end 

diagram.Selected = true;
diagram.Visible = true;
parent = diagram.Parent;
while ~isempty( parent )
parent.Visible = true;
parent = parent.Parent;
end 

switch this.Scope
case "Current"

case "CurrentAndAbove"
parent = diagram.Parent;
while ~isempty( parent )
parent.Selected = true;
parent.Visible = true;
parent = parent.Parent;
end 
case "CurrentAndBelow"
this.selectDescendants( diagram );
end 
end 

end 

methods ( Access = private )
function selectDescendants( this, diagram )

assert( diagram.Model.isBuiltWithLibrariesLoaded ...
 || ( ~this.IncludeUserLibraryLinks && ~this.IncludeSimulinkLibraryLinks ) );

this.IncludeAllVariants = strcmp( this.IncludeVariantSubsystems, "All" );
this.IncludeActiveVariants = strcmp( this.IncludeVariantSubsystems, "Active" );


stack = { diagram };
top = 1;
while ( top > 0 )
diagram = stack{ top };
top = top - 1;

if ( this.IncludeReferencedModels )
diagram.loadReferencedModels(  );
end 

children = diagram.Children;
nChildren = numel( children );
if ( top + nChildren ) > numel( stack )
stack{ top + nChildren } = [  ];
end 
for i = 1:nChildren
child = children( i );
if this.satisfyIncludeConstraints( child )
child.Selected = true;
child.Visible = true;
top = top + 1;
stack{ top } = child;
end 
end 
end 
end 

function tf = satisfyIncludeConstraints( this, diagram )
tf = this.satisfyIncludeMaskedSubsystemsConstraint( diagram ) ...
 && this.satisfyIncludeUserLibraryLinksConstraint( diagram ) ...
 && this.satisfyIncludeSimulinkLibraryLinksConstraint( diagram ) ...
 && this.satisfyIncludeReferencedModelsConstraint( diagram ) ...
 && this.satisfyIncludeVariantSubsystemsConstraint( diagram ) ...
 && this.satisfyIncludeCommentedDiagrams( diagram ) ...
 && this.satisfyTraversalCallback( diagram );
end 

function tf = satisfyTraversalCallback( this, diagram )
tf = isempty( this.TraversalCallback ) || feval( this.TraversalCallback, diagram.path(  ), diagram.handle(  ) );
end 

function tf = satisfyIncludeSimulinkLibraryLinksConstraint( this, diagram )
tf = this.IncludeSimulinkLibraryLinks || ~diagram.IsMathworksLink;
end 

function tf = satisfyIncludeUserLibraryLinksConstraint( this, diagram )
tf = this.IncludeUserLibraryLinks || ~diagram.IsUserLink;
end 

function tf = satisfyIncludeMaskedSubsystemsConstraint( this, diagram )
tf = this.IncludeMaskedSubsystems || ~diagram.IsMaskedSubsystem;
end 

function tf = satisfyIncludeReferencedModelsConstraint( this, diagram )
tf = this.IncludeReferencedModels || ~diagram.IsModelReference;
end 

function tf = satisfyIncludeCommentedDiagrams( this, diagram )
tf = this.IncludeCommentedDiagrams || ~diagram.IsCommented;
end 

function tf = satisfyIncludeVariantSubsystemsConstraint( this, diagram )
tf = true;
if ~this.IncludeAllVariants
parentDiagram = diagram.Parent;
if parentDiagram.IsVariantSubsystem
if this.IncludeActiveVariants
tf = ( parentDiagram.activeVariant(  ) == diagram );
else 
tf = ( parentDiagram.activeVariantPlusCode(  ) == diagram );
end 
end 
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmprTU998.p.
% Please follow local copyright laws when handling this file.

