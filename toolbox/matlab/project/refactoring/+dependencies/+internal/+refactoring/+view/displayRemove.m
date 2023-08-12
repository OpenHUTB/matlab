function handle = displayRemove( graph, oldPaths, removeAction, debug )



R36
graph( 1, 1 )dependencies.internal.graph.Graph;
oldPaths( 1, : )string{ mustBeNonzeroLengthText };
removeAction( 1, 1 )dependencies.internal.refactoring.Action;
debug( 1, 1 )logical = false;
end 

import dependencies.internal.refactoring.root.makeRemove;

strategy = dependencies.internal.refactoring.util.RemoveFromProjectStrategy(  );

model = mf.zero.Model;

root = makeRemove( model, graph, oldPaths, removeAction, strategy );

if isempty( root )
if nargout > 0
handle = dependencies.internal.refactoring.App.empty;
end 
removeAction.apply(  );
return ;
end 

manager = dependencies.internal.refactoring.TaskManager( root );

app = dependencies.internal.refactoring.App( model, manager, Debug = debug );

if nargout > 0
handle = app;
app.launch(  );
else 
wm = dependencies.internal.widget.WindowManager.Instance;
wm.launchAndRegister( app );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmprGoway.p.
% Please follow local copyright laws when handling this file.

