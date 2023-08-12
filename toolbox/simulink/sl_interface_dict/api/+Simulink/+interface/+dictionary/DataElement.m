classdef DataElement < Simulink.interface.dictionary.InterfaceElement & matlab.mixin.CustomDisplay




properties ( Dependent = true )
Type{ mustBeA( Type, [ "Simulink.interface.dictionary.DataType",  ...
'char', 'string' ] ) }
Description{ mustBeTextScalar }


Dimensions{ mustBeTextScalar }
end 

methods ( Hidden, Access = protected )
function propgrp = getPropertyGroups( ~ )

proplist = { 'Name', 'Type', 'Description', 'Dimensions', 'Owner' };
propgrp = matlab.mixin.util.PropertyGroup( proplist );
end 
end 

methods ( Hidden )
function this = DataElement( zcImpl, dictImpl, interface )

R36
zcImpl systemcomposer.architecture.model.interface.DataElement
dictImpl sl.interface.dict.InterfaceDictionary
interface Simulink.interface.dictionary.DataInterface
end 

this@Simulink.interface.dictionary.InterfaceElement( zcImpl, dictImpl, interface );
end 
end 

methods 

function type = get.Type( this )
type = this.getInterfaceElementType(  );
end 

function set.Type( this, type )
R36
this
type{ mustBeA( type, [ "Simulink.interface.dictionary.DataType",  ...
'char', 'string' ] ) }
end 
if isa( type, 'Simulink.interface.dictionary.DataType' )
typeStr = type.getTypeString(  );
else 
typeStr = type;
end 
this.ZCImpl.cachedWrapper.setTypeFromString( typeStr );
end 

function value = get.Description( this )
value = this.ZCImpl.cachedWrapper.Description;
end 

function set.Description( this, value )
this.ZCImpl.cachedWrapper.setDescription( value );
end 

function value = get.Dimensions( this )
value = this.ZCImpl.cachedWrapper.Dimensions;
end 

function set.Dimensions( this, value )
this.ZCImpl.cachedWrapper.setDimensions( value );
end 
end 

methods ( Access = private )
function type = getInterfaceElementType( this )
idict = this.getDictionary(  );
zcType = this.ZCImpl.cachedWrapper.Type;
slDataType = zcType.DataType;
if Simulink.interface.dictionary.TypeUtils.isBus( slDataType )
typeName = Simulink.interface.dictionary.TypeUtils.stripPrefix( slDataType );


if any( strcmp( typeName, idict.getInterfaceNames(  ) ) )
type = idict.getInterface( typeName );
else 
type = idict.getDataType( typeName );
end 
else 
type = Simulink.interface.dictionary.ValueType( idict, this.ZCImpl.getTypeAsInterface );
end 
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpxkrFSN.p.
% Please follow local copyright laws when handling this file.

