function root = makeRemove( model, graph, oldPaths, removeAction, strategy )




R36
model( 1, 1 )mf.zero.Model;
graph( 1, 1 )dependencies.internal.graph.Graph;
oldPaths( 1, : )string{ mustBeNonzeroLengthText };
removeAction( 1, 1 )dependencies.internal.refactoring.Action;
strategy( 1, 1 )dependencies.internal.refactoring.util.RemoveStrategy;
end 

import dependencies.internal.graph.Node.createFileNode;
import dependencies.internal.refactoring.graphtransform.baseTransform;
import dependencies.internal.refactoring.section.makeGraphSection;
import dependencies.internal.refactoring.util.findAllFiles;
import dependencies.internal.refactoring.MessageWithDetails;
import dependencies.internal.refactoring.Root;

filesToRemove = findAllFiles( oldPaths );

graph = baseTransform( graph );
handlers = dependencies.internal.action.RefactoringHandler.empty;
nodesToRemove = createFileNode( filesToRemove );
after = repmat( missing, size( nodesToRemove ) );

transaction = model.beginTransaction;
section = makeGraphSection( model, graph, handlers, nodesToRemove, after );
if isempty( section )
transaction.rollBack;
root = dependencies.internal.refactoring.Root.empty;
return ;
end 

[ msg, details ] = strategy.getDescription( section.Children.Size );

successMsg = MessageWithDetails;
[ successMsg.Message, successMsg.Details ] = strategy.getSuccess(  );

incompleteMsg = MessageWithDetails;
[ incompleteMsg.Message, incompleteMsg.Details ] = strategy.getIncomplete(  );

errorMsg = MessageWithDetails;
[ errorMsg.Message, errorMsg.Details ] = strategy.getError(  );

cancelActionName = string( message( "MATLAB:dependency:refactoring:ButtonCancel" ) );

root = Root( model, struct(  ...
"Type", dependencies.internal.refactoring.Type.GROUP,  ...
"Title", strategy.Title,  ...
"Name", msg,  ...
"Description", details,  ...
"Success", successMsg,  ...
"Incomplete", incompleteMsg,  ...
"Error", errorMsg,  ...
"RefactorAction", removeAction,  ...
"EnabledByDefault", true,  ...
"UpdateActionName", strategy.UpdateButtonName,  ...
"SkipActionName", strategy.SkipButtonName,  ...
"CancelActionName", cancelActionName ) );
root.Children.add( section );

transaction.commit(  );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp0CD4hs.p.
% Please follow local copyright laws when handling this file.

