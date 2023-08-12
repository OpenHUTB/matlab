classdef DependencyViewer < dependencies.internal.widget.WindowHandle



properties ( Dependent, SetAccess = private )
View;
Initialized;
end 

properties ( Hidden = true, SetAccess = immutable )
Controller dependencies.internal.viewer.Controller;
end 

properties ( GetAccess = private, SetAccess = immutable )
InitBarrier;
end 

properties ( Access = private )
ControllerCloseListener event.listener;
WindowCloseListener event.listener;
end 

methods 
function this = DependencyViewer( options )
R36
options.Nodes( 1, : )dependencies.internal.graph.Node =  ...
dependencies.internal.graph.Node.empty( 1, 0 );
options.Debug( 1, 1 )logical = false;
options.Name( 1, 1 )string = missing;
options.Workflow( 1, 1 )string = missing;
options.Controller( 1, : )dependencies.internal.viewer.Controller =  ...
dependencies.internal.viewer.Controller.empty( 1, 0 );
options.Tag( 1, 1 )string = missing;
end 
import dependencies.internal.viewer.DependencyInitBarrier;



if isempty( options.Controller )
controller = dependencies.internal.viewer.Controller;
else 
controller = options.Controller;
end 

txn = controller.ViewModel.beginTransaction;
for customization = dependencies.internal.Registry.Instance.ViewCustomizations'
customization.customize( controller, options.Nodes );
end 
txn.commit;

controller.redisplayGraph(  );

i_updateWorkflow( controller, options.Workflow );

controller.awaitPendingUpdates(  )

view = controller.View;

baseUrl = dependencies.internal.viewer.makeBaseUrl( controller, Debug = options.Debug );
title = i_getAppTitle( options.Name, options.Debug );

this@dependencies.internal.widget.WindowHandle(  ...
baseUrl,  ...
Title = title,  ...
InitialSize = [ 1200, 800 ],  ...
MinimumSize = [ 650, 300 ],  ...
Tag = options.Tag );
this.Controller = controller;

this.InitBarrier = DependencyInitBarrier( view.UUID );


initBarrier = this.InitBarrier.Initialized;

window = this.Window;
this.ControllerCloseListener = listener( controller, "CloseRequest", @( ~, ~ )window.close(  ) );
this.WindowCloseListener = listener( window, "Closed", @( varargin )initBarrier.reset(  ) );
end 

function delete( this )
this.ControllerCloseListener = event.listener.empty;
this.WindowCloseListener = event.listener.empty;
this.Window.close(  );
this.Controller.close(  );
end 

function analyze( this, nodes )
this.Initialized.execute( @(  )this.Controller.analyze( nodes ) );
end 

function update( this )
this.Initialized.execute( @(  )this.Controller.update(  ) );
end 

function setGraph( this, graph )
this.Initialized.execute( @(  )this.Controller.setGraph( graph ) );
end 

function filter( this, nodes, type )
this.Initialized.execute( @(  )this.Controller.filter( nodes, type ) );
end 

function view = get.View( this )
view = this.Controller.View;
end 

function initialized = get.Initialized( this )
initialized = this.InitBarrier.Initialized;
end 
end 
end 

function i_updateWorkflow( controller, workflow )
import dependencies.internal.viewer.postEvent;
if ismissing( workflow )
return ;
end 

avalableWorkflows = controller.View.AvailableWorkflows;
pickedWorkflows = i_findWorkflowsByName( avalableWorkflows, workflow );
if ~isempty( pickedWorkflows )
postEvent( controller, "WorkflowRequestEvent", "Workflow", pickedWorkflows( 1 ) );
end 
end 

function workflows = i_findWorkflowsByName( workflowSequence, name )
workflowNames = arrayfun( @( w )string( w.Name ), workflowSequence.toArray );
matchingIdx = strcmp( name, workflowNames );
workflows = workflowSequence( find( matchingIdx ) );%#ok<FNDSB> I wish it was true for Mf0 sequences!
end 

function title = i_getAppTitle( name, debug )
if ismissing( name ) || strlength( name ) == 0
if debug
msg = message( "MATLAB:dependency:viewer:AppTitleDebug" );
else 
msg = message( "MATLAB:dependency:viewer:AppTitle" );
end 
else 
if debug
msg = message( "MATLAB:dependency:viewer:AppTitleDebugWithName", name );
else 
msg = message( "MATLAB:dependency:viewer:AppTitleWithName", name );
end 
end 

title = msg.getString(  );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpD7YO2G.p.
% Please follow local copyright laws when handling this file.

