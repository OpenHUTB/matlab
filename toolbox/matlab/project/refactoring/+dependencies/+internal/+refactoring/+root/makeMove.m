function root = makeMove( model, graph, oldPaths, destination,  ...
useRefactoringHandlers, moveAction )




R36
model( 1, 1 )mf.zero.Model;
graph( 1, 1 )dependencies.internal.graph.Graph;
oldPaths( 1, : )string{ mustBeNonzeroLengthText, mustBeNonempty };
destination( 1, 1 )string{ mustBeFolder };
useRefactoringHandlers( 1, 1 )logical;
moveAction( 1, 1 )dependencies.internal.refactoring.Action;
end 

import dependencies.internal.graph.Node;
import dependencies.internal.refactoring.graphtransform.baseTransform;
import dependencies.internal.refactoring.graphtransform.keepOnlyFolderRenameDependencies;
import dependencies.internal.refactoring.util.mapNodesToMovedFiles;
import dependencies.internal.refactoring.section.makeGraphSection;
import dependencies.internal.refactoring.Root;

[ ~, name, ext ] = fileparts( oldPaths );
newPaths = fullfile( destination, name + ext );

folders = isfolder( oldPaths );
oldFilePaths = oldPaths( ~folders );
newFilePaths = newPaths( ~folders );
oldFolderPaths = oldPaths( folders );
newFolderPaths = newPaths( folders );

breaksNamespace = any( [ i_parentFolderIsNamespace( oldFilePaths ), i_parentFolderIsNamespace( newFilePaths ) ] );
foldersThatBreakNamespace = breaksNamespace & folders;
oldFolderThatBreakNamespacePath = oldPaths( foldersThatBreakNamespace );
newFolderThatBreakNamespacePath = newPaths( foldersThatBreakNamespace );

oldFilesThatBreakNamespacePath = oldPaths( breaksNamespace & ~folders );

if useRefactoringHandlers
handlers = dependencies.internal.Registry.Instance.RefactoringHandlers;
handlers = handlers( ~[ handlers.RenameOnly ] );



else 

handlers = dependencies.internal.action.RefactoringHandler.empty;
end 

[ oldFolderFileNodes, movedFolderFiles ] = mapNodesToMovedFiles( oldFolderPaths, newFolderPaths, graph );
allOldFileNodes = [ oldFolderFileNodes, Node.createFileNode( oldFilePaths ) ];
allMovedFiles = [ movedFolderFiles, newFilePaths ];

oldFileNodesThatBreakNamespaceFromFolderMove = mapNodesToMovedFiles(  ...
oldFolderThatBreakNamespacePath, newFolderThatBreakNamespacePath, graph );
oldFileNodesThatBreakNamespaceFromFileMove = Node.createFileNode( oldFilesThatBreakNamespacePath );

nodesThatBreakDependencies = [ oldFileNodesThatBreakNamespaceFromFolderMove, oldFileNodesThatBreakNamespaceFromFileMove ];
if isempty( nodesThatBreakDependencies )
dependencyToKeep = dependencies.internal.graph.Dependency.empty( 1, 0 );
else 
dependencyToKeep = graph.getUpstreamDependencies( nodesThatBreakDependencies );
end 
if ~isempty( dependencyToKeep )
selfDependencies = [ dependencyToKeep.UpstreamNode ] == [ dependencyToKeep.DownstreamNode ];
dependencyToKeep = dependencyToKeep( ~selfDependencies );
end 

filteredGraph = keepOnlyFolderRenameDependencies( baseTransform( graph ) );
if isempty( dependencyToKeep )
graph = filteredGraph;
else 
graph = dependencies.internal.graph.Graph( [ dependencyToKeep, filteredGraph.Dependencies ] );
end 

transaction = model.beginTransaction;
section = makeGraphSection( model, graph, handlers, allOldFileNodes, allMovedFiles );

if isempty( section )
transaction.rollBack;
root = dependencies.internal.refactoring.Root.empty;
return ;
end 

title = string( message( "MATLAB:project:refactoring:MoveTitle" ) );

[ msg, details ] = i_getDescription( section.Children.Size );
resultMessages = i_getResultMessages(  );

updateActionName = string( message( "MATLAB:project:refactoring:ButtonMoveAndUpdate" ) );
skipActionName = string( message( "MATLAB:project:refactoring:ButtonMove" ) );
cancelActionName = string( message( "MATLAB:dependency:refactoring:ButtonCancel" ) );

root = Root( model, struct(  ...
"Type", dependencies.internal.refactoring.Type.GROUP,  ...
"Title", title,  ...
"Name", msg,  ...
"Description", details,  ...
"Success", resultMessages.success,  ...
"Incomplete", resultMessages.incomplete,  ...
"Error", resultMessages.error,  ...
"RefactorAction", moveAction,  ...
"EnabledByDefault", true,  ...
"UpdateActionName", updateActionName,  ...
"SkipActionName", skipActionName,  ...
"CancelActionName", cancelActionName ) );

root.Children.add( section );

transaction.commit(  );
end 

function logicalArray = i_parentFolderIsNamespace( oldPaths )
parents = fileparts( oldPaths );
[ ~, parentNames ] = fileparts( parents );
logicalArray = startsWith( parentNames, [ "+", "@" ] );
end 

function [ msg, details ] = i_getDescription( nFileUpdates )
args = {  };

if nFileUpdates == 1
filePart = "OneFile";
args{ end  + 1 } = "<b>1</b>";
else 
filePart = "SomeFiles";
args{ end  + 1 } = "<b>" + string( nFileUpdates ) + "</b>";
end 

baseResource = "MATLAB:project:refactoring:MoveIntro";
msgResource = baseResource + "Message" + filePart;
detailsResource = baseResource + "Details" + filePart;

msg = string( message( msgResource, args{ : } ) );
details = string( message( detailsResource ) );
end 

function resultMessages = i_getResultMessages(  )
import dependencies.internal.refactoring.MessageWithDetails;
baseResource = "MATLAB:project:refactoring:Move";

resultMessages = struct;
resultMessages.success = MessageWithDetails;
resultMessages.success.Message = string( message( baseResource + "MessageSuccess" ) );
resultMessages.incomplete = MessageWithDetails;
resultMessages.incomplete.Message = string( message( baseResource + "MessageIncomplete" ) );
resultMessages.incomplete.Details = string( message( baseResource + "DetailsIncomplete" ) );
resultMessages.error = MessageWithDetails;
resultMessages.error.Message = string( message( baseResource + "MessageError" ) );
resultMessages.error.Details = string( message( baseResource + "DetailsError" ) );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpJS74nz.p.
% Please follow local copyright laws when handling this file.

