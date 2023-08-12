classdef App < dependencies.internal.widget.WindowHandle




properties ( GetAccess = private, SetAccess = immutable )
Model;
TaskManager;
Channel;
Synchronizer;
ExpandEventRegistration;
CloseEventRegistration;
end 

methods 
function this = App( model, manager, options )
R36
model( 1, 1 )mf.zero.Model;
manager( 1, 1 )dependencies.internal.refactoring.TaskManager;
options.Debug( 1, 1 )logical = false;
end 
import dependencies.internal.refactoring.EnabledStatus;

task = manager.Task;
baseUrl = i_makeBaseUrl( options.Debug, task.UUID );

title = task.Root.Title;
if "" == title
title = missing;
end 

taskEntries = task.Entries.toArray(  );
enabled = [ taskEntries.Enabled ] == EnabledStatus.YES;
if all( enabled )
height = 150;
elseif all( ~enabled )
height = 350;
else 
height = 500;
end 

this@dependencies.internal.widget.WindowHandle(  ...
baseUrl, Title = title, InitialSize = [ 800, height ],  ...
Tag = "DependencyRefactoringWidget" );
this.Model = model;
this.TaskManager = manager;

window = this.Window;
this.ExpandEventRegistration = task.ExpandRequest.registerHandler(  ...
@( varargin )i_increaseHeight( window ) );

this.CloseEventRegistration = task.CloseRequest.registerHandler(  ...
@( varargin )dependencies.internal.refactoring.invokeLater( @(  )window.close(  ) ) );

commonBase = "/dependency/refactoring/" + task.UUID;

this.Channel = mf.zero.io.ConnectorChannel(  ...
commonBase + "/server", commonBase + "/client" );
this.Synchronizer = mf.zero.io.ModelSynchronizer( this.Model, this.Channel );
this.Synchronizer.start(  );
end 

function delete( this )
this.ExpandEventRegistration.unregister(  );
this.CloseEventRegistration.unregister(  );
drawnow(  );
this.Synchronizer.stop(  );
end 
end 
end 

function url = i_makeBaseUrl( debug, taskUuid )
if debug
pageName = "index-debug";
else 
pageName = "index";
end 

url = "/toolbox/matlab/dependency/refactoring/web/" +  ...
pageName + ".html?task=" + taskUuid;
end 

function i_increaseHeight( window )
winSize = window.getSize(  );
window.resize( winSize( 1 ), winSize( 2 ) + 200 );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpRGShVS.p.
% Please follow local copyright laws when handling this file.

