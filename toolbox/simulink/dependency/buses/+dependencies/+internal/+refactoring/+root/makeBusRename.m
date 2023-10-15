function root = makeBusRename( model, graph, oldNode, newName )

arguments
    model( 1, 1 )mf.zero.Model;
    graph( 1, 1 )dependencies.internal.graph.Graph;
    oldNode( 1, 1 )dependencies.internal.graph.Node{ i_mustBeVariableNode };
    newName( 1, 1 )string;
end

import dependencies.internal.refactoring.section.makeGraphSection;
import dependencies.internal.refactoring.util.getBusRenameProperties;
import dependencies.internal.refactoring.Root;

registry = dependencies.internal.buses.BusRegistry.Instance;
handlers = registry.RefactoringHandlers;

transaction = model.beginTransaction;
section = makeGraphSection( model, graph, handlers, oldNode, newName );
if isempty( section )
    transaction.rollBack;
    root = dependencies.internal.refactoring.Root.empty;
    return ;
end

props = getBusRenameProperties( section.Children.Size, graph.Nodes, oldNode, newName );

updateActionName = string( message( "SimulinkDependencyAnalysis:Buses:BusRefactoringUpdateActionName" ) );
cancelActionName = string( message( "SimulinkDependencyAnalysis:Buses:BusRefactoringCancelActionName" ) );
root = Root( model, struct(  ...
    "Type", dependencies.internal.refactoring.Type.GROUP,  ...
    "Title", props.title,  ...
    "Name", props.message,  ...
    "Description", props.details,  ...
    "Success", props.success,  ...
    "Incomplete", props.incomplete,  ...
    "Error", props.error,  ...
    "EnabledByDefault", false,  ...
    "UpdateActionName", updateActionName,  ...
    "CancelActionName", cancelActionName ) );
root.Children.add( section );
transaction.commit(  );
end

function i_mustBeVariableNode( node )
if dependencies.internal.graph.Type( "Variable" ) ~= node.Type
    error( message( "SimulinkDependencyAnalysis:Buses:RenameArgumentMustBeVariable" ) );
end
end
