function root = makeFolderRename( model, graph, oldPath, newPath,  ...
    useRefactoringHandlers, renameAction )




arguments
    model( 1, 1 )mf.zero.Model;
    graph( 1, 1 )dependencies.internal.graph.Graph;
    oldPath( 1, 1 )string{ mustBeNonzeroLengthText };
    newPath( 1, 1 )string{ mustBeNonzeroLengthText };
    useRefactoringHandlers( 1, 1 )logical;
    renameAction( 1, 1 )dependencies.internal.refactoring.Action;
end

import dependencies.internal.refactoring.graphtransform.baseTransform;
import dependencies.internal.refactoring.graphtransform.keepOnlyFolderRenameDependencies;
import dependencies.internal.refactoring.util.mapNodesToMovedFiles;
import dependencies.internal.refactoring.section.makeGraphSection;
import dependencies.internal.refactoring.Root;

if useRefactoringHandlers
    handlers = dependencies.internal.Registry.Instance.RefactoringHandlers;
else

    handlers = dependencies.internal.action.RefactoringHandler.empty;
end

[ oldNodes, newPaths ] = mapNodesToMovedFiles( oldPath, newPath, graph );

graph = keepOnlyFolderRenameDependencies( baseTransform( graph ) );

transaction = model.beginTransaction;
section = makeGraphSection( model, graph, handlers, oldNodes, newPaths );
if isempty( section )
    transaction.rollBack;
    root = dependencies.internal.refactoring.Root.empty;
    return ;
end

title = string( message( "MATLAB:dependency:refactoring:FolderRenameRefactoringTitle" ) );
[ ~, oldName ] = fileparts( oldPath );
[ msg, details ] = i_getRenameDescription( section.Children.Size, oldName );
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

function [ msg, details ] = i_getRenameDescription( numFiles, name )
if numFiles == 1
    msgResource = "MATLAB:dependency:refactoring:FolderRenameRefactoringMessageSingle";
    detailsResource = "MATLAB:dependency:refactoring:RenameRefactoringDetailsSingle";
else
    msgResource = "MATLAB:dependency:refactoring:FolderRenameRefactoringMessageMulti";
    detailsResource = "MATLAB:dependency:refactoring:RenameRefactoringDetailsMulti";
end
msg = string( message( msgResource, "<b>" + string( numFiles ) + "</b>", name ) );
details = string( message( detailsResource ) );
end

function resultMessages = i_getRenameResultMessages(  )
import dependencies.internal.refactoring.MessageWithDetails;
baseResource = "MATLAB:dependency:refactoring:FolderRename";
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

