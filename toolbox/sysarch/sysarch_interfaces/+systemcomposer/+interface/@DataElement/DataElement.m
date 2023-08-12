classdef DataElement < systemcomposer.interface.Element




properties ( Dependent = true, SetAccess = private )
Interface( 1, 1 )systemcomposer.interface.DataInterface
Name( 1, 1 ){ mustBeTextScalar }
Type( 1, 1 ){ mustBeA( Type, [ "systemcomposer.ValueType",  ...
"systemcomposer.interface.DataInterface" ] ) }
Description( 1, 1 ){ mustBeTextScalar }
Dimensions( 1, 1 ){ mustBeTextScalar }
end 

methods ( Hidden )
function this = DataElement( impl )
narginchk( 1, 1 );
if ~isa( impl, 'systemcomposer.architecture.model.interface.InterfaceElement' )
error( 'systemcomposer:API:SignalElementInvalidInput', message( 'SystemArchitecture:API:SignalElementInvalidInput' ).getString );
end 
this@systemcomposer.interface.Element( impl );
impl.cachedWrapper = this;
end 

function setTypeFromString( this, typeStr )



model = this.Interface.Model;
if ~isempty( model )
dict = model.getImpl.getPortInterfaceCatalog;
else 
dict = this.Interface.getImpl(  ).getCatalog(  );
end 

[ typeObjOrName, isShared ] = systemcomposer.internal.getTypeFromString( typeStr, dict );
if isShared
this.setType( typeObjOrName );
elseif ( ~this.getImpl.hasOwnedType )

this.createOwnedType( 'DataType', typeObjOrName );
else 
this.Type.DataType = typeObjOrName;
end 
end 
end 

methods ( Static, Hidden )
function incheck( inval )
persistent p
if isempty( p )
p = inputParser;
addRequired( p, 'elementAttribute', @( x )( ischar( x ) && ~isempty( x ) || isstring( x ) && ~isequal( x, "" ) ) );
end 
parse( p, inval );
end 

function incheckDescription( inval )
persistent pDescription
if isempty( pDescription )
pDescription = inputParser;
addRequired( pDescription, 'elementAttribute', @( x )ischar( x ) || isstring( x ) );
end 
parse( pDescription, inval );
end 
end 

methods 
function interface = get.Interface( this )
interface = this.getWrapperForImpl( this.getImpl(  ).getInterface(  ) );
end 

function name = get.Name( this )
name = this.getImpl(  ).getName(  );
end 

function setName( this, name )
systemcomposer.interface.DataElement.incheck( name );

if ( this.Interface.isAnonymous )

aPort = this.Interface.getImpl.p_AnonymousUsage.p_Port;
systemcomposer.AnonymousInterfaceManager.RenameInlinedInterfaceElement( aPort, this.Name, name );
else 
isModelContext = isempty( this.Interface.Owner.ddConn );
sourceName = this.Interface.Owner.getSourceName;
systemcomposer.BusObjectManager.RenameInterfaceElement(  ...
sourceName, isModelContext, this.Interface.Name, this.Name, name );
end 
end 

function type = get.Type( this )
type = systemcomposer.internal.getWrapperForImpl( this.getImpl(  ).getTypeAsInterface(  ) );
end 

function setType( this, type )
R36
this( 1, 1 )systemcomposer.interface.DataElement
type( 1, 1 ){ mustBeA( type, [ "systemcomposer.ValueType",  ...
"systemcomposer.interface.DataInterface" ] ) }
end 

if isa( type, 'systemcomposer.ValueType' )
typeStr = [ 'ValueType: ', type.Name ];
else 
typeStr = [ 'Bus: ', type.Name ];
end 

this.setElementProperty( 'Type', typeStr );
end 

function type = createOwnedType( this, nameValuePairs )
R36
this( 1, 1 )systemcomposer.interface.DataElement
nameValuePairs.DataType{ mustBeTextScalar } = 'double'
nameValuePairs.Dimensions{ mustBeTextScalar } = '1'
nameValuePairs.Complexity{ mustBeTextScalar } = 'real'
nameValuePairs.Units{ mustBeTextScalar } = ''
nameValuePairs.Minimum{ mustBeTextScalar } = '[]'
nameValuePairs.Maximum{ mustBeTextScalar } = '[]'
end 

this.setElementProperty( 'Type', nameValuePairs.DataType );
this.setDimensions( nameValuePairs.Dimensions );
this.setUnits( nameValuePairs.Units );
this.setComplexity( nameValuePairs.Complexity );
this.setMinimum( nameValuePairs.Minimum );
this.setMaximum( nameValuePairs.Maximum );
type = this.Type;
end 

function dims = get.Dimensions( this )
dims = this.getImpl(  ).getDimensions(  );
end 

function setDimensions( this, dimensions )
systemcomposer.interface.DataElement.incheck( dimensions );
this.setElementProperty( 'Dimensions', dimensions );
end 

function setUnits( this, units )
R36
this( 1, 1 )systemcomposer.interface.DataElement
units{ mustBeTextScalar }
end 
this.setElementProperty( 'Units', units );
end 

function setComplexity( this, complexity )
p = inputParser;
validComplexities = { 'real', 'complex', 'auto' };
addRequired( p, 'complexity', @( x )any( validatestring( x, validComplexities ) ) );
parse( p, complexity );

systemcomposer.interface.DataElement.incheck( complexity );
this.setElementProperty( 'Complexity', complexity );
end 

function setMinimum( this, minimum )
systemcomposer.interface.DataElement.incheck( minimum );
this.setElementProperty( 'Minimum', minimum );
end 

function setMaximum( this, maximum )
systemcomposer.interface.DataElement.incheck( maximum );
this.setElementProperty( 'Maximum', maximum );
end 

function desc = get.Description( this )
desc = this.getImpl(  ).getDescription(  );
end 

function setDescription( this, description )
systemcomposer.interface.DataElement.incheckDescription( description );
this.setElementProperty( 'Description', description );
end 

function destroy( this )
this.Interface.removeElement( this.Name );
end 
end 

methods ( Access = { ?systemcomposer.ValueType } )
function setElementProperty( this, propName, propVal )
if ( this.Interface.isAnonymous )
aPort = this.Interface.getImpl.p_AnonymousUsage.p_Port;
systemcomposer.AnonymousInterfaceManager.SetInlinedInterfaceElementProperty(  ...
aPort, this.Name, propName, propVal );
else 
isModelContext = isempty( this.Interface.Owner.ddConn );
sourceName = this.Interface.Owner.getSourceName;
systemcomposer.BusObjectManager.SetInterfaceElementProperty(  ...
sourceName, isModelContext, this.Interface.Name, this.Name,  ...
propName, propVal );
end 
end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpH_xhnI.p.
% Please follow local copyright laws when handling this file.

