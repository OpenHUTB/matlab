classdef ( Abstract )AbstractProducer < handle & matlab.mixin.Heterogeneous









properties ( Dependent, SetAccess = protected )
Production
ScriptModel
end 

properties ( SetAccess = protected )


ValidateOnImport( 1, 1 )logical = true
end 

properties ( SetAccess = ?coderapp.internal.config.runtime.ProductionNodeAdapter )
Key char = ''
ContributorKeys cell = {  }
Importing( 1, 1 )logical = false
end 

properties ( Dependent, SetAccess = immutable )
Logger coderapp.internal.log.Logger
end 

properties ( Access = private, Transient )
Accessor
end 

properties ( GetAccess = private, SetAccess = ?coderapp.internal.config.runtime.ProductionNodeAdapter, Dependent )
Node
end 

methods ( Abstract )

produce( this )
end 

methods 
function this = AbstractProducer(  )
this.Accessor = coderapp.internal.config.runtime.ScopedAccessSupport( true );
end 



function update( this, triggerKeys )%#ok<INUSD>
this.produce(  );
end 






function imported = import( ~, production )%#ok<INUSD>
imported = [  ];
end 



function [ data, valid, validationMsg ] = validateSchemaData( this, data )%#ok<INUSL>
valid = true;
validationMsg = '';
end 




function postConstruct( ~ )
end 
end 

methods ( Access = protected )
function contribKeys = keys( this )

contribKeys = this.ContributorKeys;
end 

function varargout = value( this, varargin )

[ varargout{ 1:nargout } ] = this.Accessor.value( varargin{ : } );
end 

function [ values, prodConfigs ] = contributors( this, keys )
R36
this( 1, 1 )
keys{ mustBeText( keys ) } = this.keys(  )
end 


nodes = this.Accessor.nodes( keys );
values = { nodes.ReferableValue };
prodConfigs = cell( size( nodes ) );
ownKey = this.Accessor.Node.Key;
for i = 1:numel( nodes )
prodConfigs{ i } = nodes( i ).getProductionConfig( ownKey );
end 
end 

function values = metadata( this, keys, metadataProp )
narginchk( 2, 3 );
if nargin > 2
nodes = this.Accessor.nodes( keys );
isCell = iscell( keys );
else 
nodes = this.Accessor.Node;
metadataProp = keys;
isCell = false;
end 
values = cell( size( nodes ) );
for i = 1:numel( nodes )
values{ i } = nodes( i ).getMetadata( metadataProp );
end 
if ~isCell
values = values{ 1 };
end 
end 

function yes = hasMetadata( this, keys, metadataProp )
narginchk( 2, 3 );
if nargin > 2
nodes = this.Accessor.nodes( keys );
else 
nodes = this.Accessor.Node;
metadataProp = keys;
end 
yes = false( size( nodes ) );
for i = 1:numel( nodes )
yes( i ) = nodes( i ).hasMetadata( metadataProp );
end 
end 

function requestImport( this, externalValue, asUser, validateValues )
R36
this
externalValue
asUser( 1, 1 )logical = true
validateValues( 1, 1 )logical = true
end 



this.Node.deferredImportRequested( externalValue, asUser, validateValues );
end 

function requestRefresh( this )
this.Node.deferredRefresh(  );
end 

function modified = isUserModified( this, keys )
if nargin > 1
nodes = this.Accessor.nodes( keys );
else 
nodes = this.Accessor.nodes(  );
keys = { nodes.Key };
mask = strcmp( keys, this.Node.Key );
nodes( mask ) = [  ];
keys( mask ) = [  ];
end 
modified = false( size( cellstr( keys ) ) );
if ~isempty( nodes )
isParam = [ nodes.NodeType ] == "Param";
modified( isParam ) = [ nodes( isParam ).UserModified ];
end 
end 

function types = getDependencyType( this, keys )
if nargin > 1
nodes = this.Accessor.nodes( keys );
else 
nodes = setdiff( this.Accessor.nodes(  ), this.Node, 'stable' );
end 
if ~isempty( nodes )
types = [ nodes.NodeType ];
else 
types = coderapp.internal.config.runtime.NodeType.empty(  );
end 
end 

function code = getScriptValues( this, keys )
if nargin > 1
nodes = this.Accessor.nodes( keys );
else 
nodes = setdiff( this.Accessor.nodes(  ), this.Node, 'stable' );
end 
if ~isempty( nodes )
code = { nodes.ScriptValue };
else 
code = {  };
end 
end 
end 

methods 
function production = get.Production( this )
production = this.Node.ReferableValue;
end 

function set.Production( this, production )
this.Node.updateProduction( production );
end 

function scriptModel = get.ScriptModel( this )
scriptModel = this.Node.ScriptModel;
end 

function set.ScriptModel( this, arg )
assert( ischar( arg ) || isstring( arg ) || isa( arg, 'coderapp.internal.script.ScriptBuilder' ),  ...
'ScriptModel must be scalar text or a ScriptBuilder object' );
this.Node.updateScript( arg );
end 

function node = get.Node( this )
node = this.Accessor.Node;
end 

function set.Node( this, node )
this.Accessor.Node = node;
end 

function logger = get.Logger( this )
node = this.Node;
if ~isempty( node )
logger = node.Logger;
else 
logger = coderapp.internal.log.DummyLogger.empty(  );
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpYBbdMH.p.
% Please follow local copyright laws when handling this file.

