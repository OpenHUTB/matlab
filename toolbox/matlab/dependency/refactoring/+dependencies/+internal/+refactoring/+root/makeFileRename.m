function root = makeFileRename( model, graph, oldNode, newName,  ...
useRefactoringHandlers, renameAction )




R36
model( 1, 1 )mf.zero.Model;
graph( 1, 1 )dependencies.internal.graph.Graph;
oldNode( 1, 1 )dependencies.internal.graph.Node{ i_mustBeFileNode };
newName( 1, 1 )string;
useRefactoringHandlers( 1, 1 )logical;
renameAction( 1, 1 )dependencies.internal.refactoring.Action;
end 

import dependencies.internal.refactoring.graphtransform.addSelfDependencies;
import dependencies.internal.refactoring.graphtransform.baseTransform;
import dependencies.internal.refactoring.section.makeGraphSection;
import dependencies.internal.refactoring.Root;

[ oldPath, oldName, oldExt ] = fileparts( oldNode.Location{ 1 } );
[ newPath, newName, newExt ] = fileparts( newName );
if "" == newPath
newPath = oldPath;
end 

if "" == newExt
newExt = oldExt;
end 

newFullPath = fullfile( newPath, newName + newExt );

if useRefactoringHandlers
handlers = dependencies.internal.Registry.Instance.RefactoringHandlers;
else 

handlers = dependencies.internal.action.RefactoringHandler.empty;
end 

graph = addSelfDependencies( baseTransform( graph ), oldNode );

transaction = model.beginTransaction;
section = makeGraphSection( model, graph, handlers, oldNode, newFullPath );
if isempty( section )
transaction.rollBack;
root = dependencies.internal.refactoring.Root.empty;
return ;
end 

title = string( message( "MATLAB:dependency:refactoring:RenameRefactoringTitle" ) );
oldNameWithExtension = string( oldName ) + oldExt;
[ msg, details ] = i_getRenameDescription( section.Children.Size, oldNameWithExtension );
resultMessages = i_getRenameResultMessages(  );

updateActionName = string( message( "MATLAB:dependency:refactoring:ButtonRenameAndUpdate" ) );
skipActionName = string( message( "MATLAB:dependency:refactoring:ButtonRename" ) );
cancelActionName = string( message( "MATLAB:dependency:refactoring:ButtonCancel" ) );

root = Root( model, struct(  ...
"Type", dependencies.internal.refactoring.Type.GROUP,  ...
"Title", title,  ...
"Name", msg,  ...
"Description", details,  ...
"Success", resultMessages.success,  ...
"Incomplete", resultMessages.incomplete,  ...
"Error", resultMessages.error,  ...
"RefactorAction", renameAction,  ...
"EnabledByDefault", true,  ...
"UpdateActionName", updateActionName,  ...
"SkipActionName", skipActionName,  ...
"CancelActionName", cancelActionName ) );
root.Children.add( section );

transaction.commit(  );
end 

function i_mustBeFileNode( oldNode )
if ~oldNode.isFile(  )
error( message( "MATLAB:dependency:refactoring:RenameArgumentMustBeFile" ) );
end 
end 

function [ msg, details ] = i_getRenameDescription( numFiles, name )
if numFiles == 1
msgResource = "MATLAB:dependency:refactoring:RenameRefactoringMessageSingle";
detailsResource = "MATLAB:dependency:refactoring:RenameRefactoringDetailsSingle";
else 
msgResource = "MATLAB:dependency:refactoring:RenameRefactoringMessageMulti";
detailsResource = "MATLAB:dependency:refactoring:RenameRefactoringDetailsMulti";
end 
msg = string( message( msgResource, "<b>" + string( numFiles ) + "</b>", name ) );
details = string( message( detailsResource ) );
end 

function resultMessages = i_getRenameResultMessages(  )
import dependencies.internal.refactoring.MessageWithDetails;
baseResource = "MATLAB:dependency:refactoring:RenameRefactoring";
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

% Decoded using De-pcode utility v1.2 from file /tmp/tmpodlaG2.p.
% Please follow local copyright laws when handling this file.

