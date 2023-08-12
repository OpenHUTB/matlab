classdef ( Abstract )AbstractController < handle




properties ( Dependent, GetAccess = protected, SetAccess = immutable )
Key char
UserModified logical
Awake logical
Logger coderapp.internal.log.Logger
end 

properties ( GetAccess = protected, SetAccess = ?coderapp.internal.config.Configuration )
Configuration coderapp.internal.config.Configuration
end 

properties ( Access = protected )


SetAsExternal( 1, 1 ){ mustBeNumericOrLogical( SetAsExternal ) } = false
end 

properties ( Dependent, GetAccess = private, SetAccess = immutable )
Node coderapp.internal.config.runtime.NodeAdapter
Attached( 1, 1 )logical
end 

properties ( Access = private, Transient )
AttachCount( 1, 1 )uint32
Accessor
CanChangeValue
end 

methods ( Sealed, Access = protected )
function this = AbstractController(  )
this.Accessor = coderapp.internal.config.runtime.ScopedAccessSupport(  );
end 

function varargout = value( this, varargin )

if nargin > 1
[ varargout{ 1:nargout } ] = this.Accessor.value( varargin{ : } );
else 
varargout{ 1 } = this.Node.ReferableValue;
end 
end 

function attrValue = get( this, attr, export )

R36
this
attr{ mustBeTextScalar( attr ) } = ''
export( 1, 1 )logical = false
end 
if isempty( attr )
attr = 'Value';
end 
if export
attrValue = this.Node.exportAttr( char( attr ) );
else 
attrValue = this.Node.getAttr( char( attr ) );
end 
end 

function set( this, varargin )

this.doSetAttr( false, varargin{ : } );
end 

function import( this, varargin )
this.doSetAttr( true, varargin{ : } );
end 

function value = metadata( this, metadataProp )
R36
this( 1, 1 )
metadataProp char = ''
end 

value = this.Accessor.metadata( metadataProp );
end 

function yes = hasMetadata( this, metadataProp )
R36
this( 1, 1 )
metadataProp char
end 

yes = this.Accessor.hasMetadata( metadataProp );
end 

function changePerspective( this, perspectiveId )
R36
this( 1, 1 )
perspectiveId{ mustBeTextScalar( perspectiveId ) }
end 

this.Node.deferredSetPerspective( perspectiveId );
end 

function requestRefresh( this )
this.Node.deferredRefresh(  );
end 
end 

methods 
function key = get.Key( this )
key = this.Accessor.Key;
end 

function node = get.Node( this )
node = this.Accessor.Node;
end 

function attached = get.Attached( this )
attached = this.AttachCount > 0;
end 

function configuration = get.Configuration( this )
if this.Attached

configuration = coderapp.internal.config.Configuration.empty(  );
else 


configuration = this.Configuration;
end 
end 

function modified = get.UserModified( this )
node = this.Accessor.Node;
modified = node.NodeType == "Param" && node.UserModified;
end 

function awake = get.Awake( this )
node = this.Accessor.Node;
awake = node.NodeType ~= "Param" || node.Awake;
end 

function logger = get.Logger( this )
node = this.Accessor.Node;
logger = node.Logger;
end 
end 

methods ( Access = ?coderapp.internal.config.runtime.ControllerAdapter )
function varargout = attachToNode( this, node )
this.Accessor.Node = node;
this.AttachCount = this.AttachCount + 1;
if nargout > 0
varargout{ 1 } = onCleanup( @(  )this.detachFromNode(  ) );
end 
end 

function detachFromNode( this )
this.AttachCount = this.AttachCount - 1;
if this.AttachCount == 0
this.Accessor.Node = coderapp.internal.config.runtime.NodeAdapter.empty(  );
this.SetAsExternal = false;
end 
end 
end 

methods ( Access = private )
function doSetAttr( this, isImport, varargin )

if nargin == 3
this.setNodeValue( varargin{ 1 }, isImport );
else 
if mod( numel( varargin ), 2 ) ~= 0
error( 'Calling set with more than two arguments requires arguments be attribute-value pairs' );
end 
for i = 1:2:numel( varargin )
[ attr, value ] = varargin{ i:i + 1 };
if isempty( attr )
attr = 'Value';
elseif ~coderapp.internal.util.isScalarText( attr )
error( 'Attribute name must be scalar text and not a %s', class( attr ) );
end 
if strcmp( attr, 'Value' )
this.setNodeValue( value, isImport );
elseif isImport
this.Node.importAttr( attr, value, false );
else 
this.Node.setAttr( attr, value, false );
end 
end 
end 
end 

function setNodeValue( this, value, isImport )
opts = { 'External', this.SetAsExternal, 'Import', isImport };
if this.SetAsExternal
opts( end  + 1:end  + 2 ) = { 'Validate', false };
end 
this.Node.doSetValue( value, opts{ : } );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpdPq8L7.p.
% Please follow local copyright laws when handling this file.

