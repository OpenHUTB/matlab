function section = makeGraphSection( model, graph, handlers, before, after )




R36
model( 1, 1 )mf.zero.Model;
graph( 1, 1 )dependencies.internal.graph.Graph;
handlers( 1, : )dependencies.internal.action.RefactoringHandler;
before( 1, : )dependencies.internal.graph.Node;
after( 1, : )string{ i_mustBeEqualSize( before, after ) };
end 

transaction = model.beginTransaction(  );

import dependencies.internal.refactoring.Section;

deps = graph.getUpstreamDependencies( before );

children = i_makeNodeRefactorings( model, deps, handlers, before, after );
if isempty( children )
section = Section.empty;
return ;
end 

section = Section( model, struct(  ...
"HasDependencies", true,  ...
"Type", dependencies.internal.refactoring.Type.GROUP ) );
for child = children
section.Children.add( child );
end 

transaction.commit(  );
end 

function nodeRefactoring = i_makeNodeRefactorings( model, allDeps, handlers, before, after )
import dependencies.internal.refactoring.problems.RefactoringProblemManager;

nodeRefactoring = dependencies.internal.refactoring.Refactoring.empty( 1, 0 );

if isempty( allDeps )
return ;
end 

upNodes = unique( [ allDeps.UpstreamNode ] );

afterNodes = arrayfun( @i_updateLocationInNode, before, after );

problemManager = RefactoringProblemManager( upNodes );

for n = 1:length( upNodes )
upNode = upNodes( n );
[ modified, idx ] = ismember( upNode, before );
problems = problemManager.getProblemsForNode( upNode );

[ deps, updatedDownNodes ] = i_findDepsForUpNode( allDeps, upNode, before, afterNodes );
fallbackNode = upNode;
fallbackDeps = deps;
if modified
proposedNewLocation = after( idx );
if ismissing( proposedNewLocation )
continue ;
end 
upNode = afterNodes( idx( modified ) );
deps = i_updateUpNode( deps, upNode );
end 
nodeRefactoring( end  + 1 ) = i_makeNodeRefactoring(  ...
model, handlers, upNode, deps, updatedDownNodes,  ...
fallbackNode, fallbackDeps, problems );%#ok<AGROW>
end 

nodeRefactoring = i_sortByName( nodeRefactoring );
end 

function afterNode = i_updateLocationInNode( node, newLocation )
if ismissing( newLocation )
afterNode = node;
else 
location = string( node.Location );
location( 1 ) = newLocation;
afterNode = dependencies.internal.graph.Node(  ...
location, node.Type.ID, node.Resolved );
end 
end 

function [ deps, updatedDownNodes ] = i_findDepsForUpNode( allDeps, upNode, before, afterNodes )
deps = allDeps( upNode == [ allDeps.UpstreamNode ] );
updatedDownNodes = dependencies.internal.graph.Node.empty( 1, 0 );
for n = 1:length( deps )
idx = find( deps( n ).DownstreamNode == before, 1 );
updatedDownNodes( n ) = afterNodes( idx );
end 
end 

function deps = i_updateUpNode( deps, updatedUpNode )
import dependencies.internal.graph.Component;
for n = 1:length( deps )
oldDep = deps( n );
deps( n ) = dependencies.internal.graph.Dependency(  ...
Component.replaceNode( updatedUpNode, oldDep.UpstreamComponent ),  ...
oldDep.DownstreamComponent,  ...
oldDep.Type, oldDep.Relationship );
end 
end 

function nodeRefactoring = i_makeNodeRefactoring(  ...
model, handlers, upNode, deps, updatedDownNodes,  ...
fallbackNode, fallbackDeps, problems )

depRefactorings = dependencies.internal.refactoring.Refactoring.empty( 1, 0 );
hasProblems = ~isempty( problems );
for n = 1:length( deps )
depRefactorings( n ) = i_makeDependencyRefactoring(  ...
model, handlers, deps( n ), updatedDownNodes( n ), fallbackDeps( n ), hasProblems );
end 

[ name, description, modifiedFiles ] = i_makeNodeProperties( fallbackNode );
import dependencies.internal.refactoring.Action;
openAction = Action.createForMatlab( @(  )i_openNode( upNode, fallbackNode ) );

opener = dependencies.internal.refactoring.util.StatefulNodeOpener( upNode );

refactorAction = Action.createForMatlab( @(  )opener.edit(  ) );
cleanUpAction = Action.createForMatlab( @(  )opener.saveAndClose(  ) );

import dependencies.internal.refactoring.Refactoring;
nodeRefactoring = Refactoring( model, struct(  ...
"Type", dependencies.internal.refactoring.Type.GROUP,  ...
"Name", name,  ...
"Description", description,  ...
"ModifiedFiles", modifiedFiles,  ...
"Problems", problems,  ...
"RefactorAction", refactorAction,  ...
"CleanUpAction", cleanUpAction,  ...
"OpenAction", openAction ) );
for child = i_sortByName( depRefactorings )
nodeRefactoring.Children.add( child );
end 
end 

function [ name, description, modifiedFiles ] = i_makeNodeProperties( node )
name = string( node.Name );

if ismember( node.Type.ID, [ "File", "TestHarness" ] )
path = string( node.Path );
description = path;
modifiedFiles = path;
else 
description = name;
modifiedFiles = strings( 1, 0 );
end 
end 

function dependencyRefactoring = i_makeDependencyRefactoring(  ...
model, handlers, dep, updatedDownNode, fallbackDep, hasProblems )
[ name, description ] = i_makeDependencyProperties( dep );
handler = i_findHandler( handlers, dep.Type.ID );
import dependencies.internal.refactoring.Action;
openAction = Action.createForMatlab( @(  )i_openUpstreamComponent( dep, fallbackDep ) );
refactoringFields = struct(  ...
"Name", name,  ...
"Description", description,  ...
"DependencyType", dep.Type.Name,  ...
"UserCanEnable", false,  ...
"OpenAction", openAction );

if hasProblems || isempty( handler )
refactoringFields.Type = dependencies.internal.refactoring.Type.INFORMATION;
else 
refactoringFields.Type = dependencies.internal.refactoring.Type.UPDATE;
refactoringFields.RefactorAction = Action.createForMatlab(  ...
@(  )handler.refactor( dep, updatedDownNode.Location{ 1 } ) );
end 

import dependencies.internal.refactoring.Refactoring;
dependencyRefactoring = Refactoring( model, refactoringFields );
end 

function [ name, description ] = i_makeDependencyProperties( dependency )
comp = dependency.UpstreamComponent;
if dependencies.internal.graph.Component.createRoot( dependency.UpstreamNode ) == comp
[ name, description ] = i_makeNodeProperties( dependency.UpstreamNode );
else 
name = comp.Name;
description = comp.Path;
end 
end 

function handler = i_findHandler( handlers, type )
R36
handlers( 1, : )dependencies.internal.action.RefactoringHandler;
type( 1, 1 )string;
end 

for handler = handlers
if ismember( type, handler.Types )
return ;
end 
end 

handler = dependencies.internal.action.RefactoringHandler.empty( 1, 0 );
end 

function i_openNode( node, fallbackNode )
try 
dependencies.internal.action.open( node )
catch ME
if fallbackNode == node
rethrow( ME );
else 
dependencies.internal.action.open( fallbackNode );
end 
end 
end 

function i_openUpstreamComponent( dep, fallbackDep )
try 
dependencies.internal.action.openUpstream( dep );
catch ME
if fallbackDep == dep
rethrow( ME );
else 
dependencies.internal.action.openUpstream( fallbackDep );
end 
end 
end 

function sortedRefactorings = i_sortByName( refactorings )
if isempty( refactorings )
sortedRefactorings = dependencies.internal.refactoring.Refactoring.empty( 1, 0 );
else 
[ ~, sortedIdx ] = sort( string( { refactorings.Name } ) );
sortedRefactorings = refactorings( sortedIdx );
end 
end 

function i_mustBeEqualSize( before, after )
if ~isequal( size( before ), size( after ) )
error( message( "MATLAB:dependency:refactoring:GraphArgumentMustHaveSameSize" ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpWzN3NR.p.
% Please follow local copyright laws when handling this file.

