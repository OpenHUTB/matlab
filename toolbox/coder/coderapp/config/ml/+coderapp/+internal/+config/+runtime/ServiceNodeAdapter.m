classdef ( Sealed )ServiceNodeAdapter < coderapp.internal.config.runtime.ReferableNodeAdapter



properties ( Constant )
NodeType coderapp.internal.config.runtime.NodeType = coderapp.internal.config.runtime.NodeType.Service
end 

properties ( SetAccess = private )
Dependencies coderapp.internal.config.runtime.ReferableNodeAdapter =  ...
coderapp.internal.config.runtime.ReferableNodeAdapter.empty
end 

properties ( SetAccess = private )
NodeActive logical = false
end 

properties ( SetAccess = protected )
Dirty logical = false
end 

properties ( Dependent, Hidden, SetAccess = immutable )
ReferableValue
ExportedValue
ScriptValue
ScriptCode
end 

properties ( Access = private )
Binding
CachedCode
end 

methods 
function this = ServiceNodeAdapter( serviceDef, schemaIdx, binding )
R36
serviceDef coderapp.internal.config.schema.ServiceDef
schemaIdx
binding = codergui.internal.undefined
end 
this@coderapp.internal.config.runtime.ReferableNodeAdapter( serviceDef, schemaIdx );
this.Binding = binding;
end 

function binding = get.ReferableValue( this )
binding = this.Binding;
end 

function binding = get.ExportedValue( this )
binding = this.Binding;
end 

function scriptValue = get.ScriptValue( this )
scriptValue = this.ScriptCode;
end 

function code = get.ScriptCode( this )
if ~ischar( this.CachedCode )
this.CachedCode = coderapp.internal.value.valueToExpression( this.Binding );
end 
code = this.CachedCode;
end 
end 

methods ( Access = { ?coderapp.internal.config.runtime.NodeAdapter, ?coderapp.internal.config.Configuration,  ...
?coderapp.internal.config.runtime.ConfigStoreAdapter } )
function activateNode( this )
this.NodeActive = ~codergui.internal.undefined( this.Binding );
if ~this.NodeActive
error( 'Initial binding for service "%s" not specified', this.Key );
end 
end 
end 

methods ( Access = { ?coderapp.internal.config.runtime.ServiceNodeAdapter, ?coderapp.internal.config.Configuration } )
function bind( this, binding )
if codergui.internal.undefined( binding )
error( 'Cannot specify an undefined binding for service "%s"', this.Key );
end 
this.Binding = binding;
this.CachedCode = [  ];
this.Propagate = true;
if ~isempty( this.Configuration )
this.updateSuccessorDepViews(  );
this.Configuration.reportChange( this );
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpaJPa9n.p.
% Please follow local copyright laws when handling this file.

