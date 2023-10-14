function root = makeNamespaceRename( model, graph, oldPath, newPath, renameAction )

arguments
    model( 1, 1 )mf.zero.Model;
    graph( 1, 1 )dependencies.internal.graph.Graph;
    oldPath( 1, 1 )string{ mustBeFolder };
    newPath( 1, 1 )string{ mustBeNonzeroLengthText };
    renameAction( 1, 1 )dependencies.internal.refactoring.Action;
end

import dependencies.internal.refactoring.graphtransform.baseTransform;
import dependencies.internal.refactoring.section.makeGraphSection;
import dependencies.internal.refactoring.util.mapNodesToMovedFiles;
import dependencies.internal.refactoring.Root;

handlers = dependencies.internal.action.RefactoringHandler.empty;
[ oldNodes, newPaths ] = mapNodesToMovedFiles( oldPath, newPath, graph );
graph = baseTransform( graph );

transaction = model.beginTransaction;
section = makeGraphSection( model, graph, handlers, oldNodes, newPaths );
if isempty( section )
    transaction.rollBack;
    root = dependencies.internal.refactoring.Root.empty;
    return ;
end

title = string( message( "MATLAB:dependency:refactoring:NamespaceRenameRefactoringTitle" ) );
[ msg, details ] = i_getDescription( section.Children.Size );
resultMessages = i_getResultMessages(  );

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

function [ msg, details ] = i_getDescription( numberOfFiles )
if numberOfFiles == 1
    suffix = "Single";
else
    suffix = "Multi";
end
boldCount = "<b>" + string( numberOfFiles ) + "</b>";
baseResource = "MATLAB:dependency:refactoring:NamespaceRenameRefactoring";
msgResource = baseResource + "Message" + suffix;
detailsResource = baseResource + "Details" + suffix;
msg = string( message( msgResource, boldCount ) );
details = string( message( detailsResource ) );
end

function resultMessages = i_getResultMessages(  )
import dependencies.internal.refactoring.MessageWithDetails;
baseResource = "MATLAB:dependency:refactoring:NamespaceRenameRefactoring";
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

