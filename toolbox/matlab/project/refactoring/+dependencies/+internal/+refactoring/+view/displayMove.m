function handle = displayMove(  ...
graph, oldPaths, destination, displayAutoRename, moveAction, debug )



R36
graph( 1, 1 )dependencies.internal.graph.Graph;
oldPaths( 1, : )string{ mustBeNonzeroLengthText };
destination( 1, 1 )string;
displayAutoRename( 1, 1 )logical;
moveAction( 1, 1 )dependencies.internal.refactoring.Action;
debug( 1, 1 )logical = false;
end 

import dependencies.internal.refactoring.root.makeMove;

model = mf.zero.Model;

rootRefactoring = makeMove( model, graph, oldPaths, destination,  ...
displayAutoRename, moveAction );

if isempty( rootRefactoring )
if nargout > 0
handle = dependencies.internal.refactoring.App.empty;
end 
moveAction.apply(  );
return ;
end 

manager = dependencies.internal.refactoring.TaskManager( rootRefactoring );

app = dependencies.internal.refactoring.App( model, manager, Debug = debug );

if nargout > 0
handle = app;
app.launch(  );
else 
wm = dependencies.internal.widget.WindowManager.Instance;
wm.launchAndRegister( app );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmppmO1Jg.p.
% Please follow local copyright laws when handling this file.

