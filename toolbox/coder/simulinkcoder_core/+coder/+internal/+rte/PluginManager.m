classdef PluginManager < handle






properties ( Access = public )
HasActiveServices( 1, 1 )logical
IsTimerServiceActive( 1, 1 )logical = false;
CodeDescriptor
end 

properties ( Access = private )
Plugins( 1, : )coder.internal.rte.Plugin
end 

properties ( Constant, Access = private )

PluginsForDeployment = [  ...
coder.internal.rte.Plugin(  ...
coder.internal.rte.PluginName.RTEInterface,  ...
coder.internal.rte.PluginType.Interface,  ...
@coder.internal.rte.RTEInterfacePlugin ),  ...
coder.internal.rte.Plugin(  ...
coder.internal.rte.PluginName.Timer,  ...
coder.internal.rte.PluginType.Implementation,  ...
@coder.internal.rte.TimerPluginForDeployment ),  ...
coder.internal.rte.Plugin(  ...
coder.internal.rte.PluginName.DataTransfer,  ...
coder.internal.rte.PluginType.Implementation,  ...
@coder.internal.rte.DataTransferPlugin ) ]


PluginsForXIL = [  ...
coder.internal.rte.Plugin(  ...
coder.internal.rte.PluginName.Timer,  ...
coder.internal.rte.PluginType.Implementation,  ...
@coder.internal.rte.TimerPluginForXIL ),  ...
coder.internal.rte.Plugin(  ...
coder.internal.rte.PluginName.DataTransfer,  ...
coder.internal.rte.PluginType.Implementation,  ...
@coder.internal.rte.DataTransferPlugin ) ]
end 

methods 
function this = PluginManager( codeDescriptor, pluginContext )
R36
codeDescriptor( 1, 1 )coder.codedescriptor.CodeDescriptor
pluginContext( 1, 1 )coder.internal.rte.PluginContext
end 
activePluginNames =  ...
coder.internal.rte.util.getActiveServices( codeDescriptor );

this.HasActiveServices = ~isempty( activePluginNames );
if ~this.HasActiveServices
return ;
end 
this.IsTimerServiceActive = any( activePluginNames == coder.internal.rte.PluginName.Timer );

this.CodeDescriptor = codeDescriptor;

switch pluginContext
case coder.internal.rte.PluginContext.Deployment
pluginsForContext = this.PluginsForDeployment;
case coder.internal.rte.PluginContext.XIL
pluginsForContext = this.PluginsForXIL;
otherwise 
assert( false, 'Unexpected plugin context encountered!' );
end 

this.Plugins = pluginsForContext(  ...
ismember( [ pluginsForContext.Name ], activePluginNames ) );
end 

function [ intFcns, impFcns ] = getPluginFunctionsAsCellArrays( this )


intFcns = {  };
impFcns = {  };
for plugin = this.Plugins
switch plugin.Type
case coder.internal.rte.PluginType.Interface
intFcns{ end  + 1 } = plugin.Function;
case coder.internal.rte.PluginType.Implementation
impFcns{ end  + 1 } = plugin.Function;
otherwise 
assert( false, 'Unexpected plugin type found!' );
end 
end 
end 

function callImplementationPlugins( this, outDir, buildInfo )


for plugin = this.Plugins
switch plugin.Type
case coder.internal.rte.PluginType.Implementation
feval( plugin.Function, this.CodeDescriptor, outDir, buildInfo );
end 
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpjU7u8p.p.
% Please follow local copyright laws when handling this file.

