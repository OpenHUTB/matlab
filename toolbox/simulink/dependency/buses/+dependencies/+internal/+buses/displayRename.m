function handle = displayRename( input, oldName, newName, debug )



R36
input
oldName( 1, 1 )string{ mustBeNonzeroLengthText }
newName( 1, 1 )string{ mustBeNonzeroLengthText }
debug( 1, 1 )logical = false;
end 

import dependencies.internal.graph.Nodes;
import dependencies.internal.refactoring.root.makeBusRename;

if nargout > 0
handle = dependencies.internal.refactoring.App.empty;
end 

extensions = dependencies.internal.buses.BusRegistry.Instance.getAnalysisExtensions(  );
nodes = dependencies.internal.util.getNodes( input, extensions );
nodes( end  + 1 ) = Nodes.BaseWorkspaceNode;

busElements = split( oldName, "." );
busNode = Nodes.createVariableNode( busElements );
progressName = "projectRefactoring";

[ graph, cancelled ] = dependencies.internal.buses.analyze( nodes, busNode, progressName );
if cancelled
return ;
end 

model = mf.zero.Model;
rootRefactoring = makeBusRename( model, graph, busNode, newName );
if isempty( rootRefactoring )
return ;
end 

manager = dependencies.internal.refactoring.TaskManager( rootRefactoring );

app = dependencies.internal.refactoring.App( model, manager, "Debug", debug );

if nargout > 0
handle = app;
app.launch(  );
else 
wm = dependencies.internal.widget.WindowManager.Instance;
wm.launchAndRegister( app );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp7IolMw.p.
% Please follow local copyright laws when handling this file.

