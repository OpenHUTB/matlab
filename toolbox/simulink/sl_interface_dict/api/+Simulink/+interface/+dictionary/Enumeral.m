classdef Enumeral < Simulink.interface.dictionary.NamedElement &  ...
matlab.mixin.CustomDisplay




properties ( Access = private )
EnumType Simulink.interface.dictionary.EnumType
end 

properties ( Dependent = true )
Value
Description{ mustBeTextScalar }
end 

methods ( Hidden, Access = protected )
function propgrp = getPropertyGroups( ~ )

proplist = { 'Name', 'Value', 'Description' };
propgrp = matlab.mixin.util.PropertyGroup( proplist );
end 
end 

methods 
function this = Enumeral( zcImpl, enumType )


R36
zcImpl
enumType Simulink.interface.dictionary.EnumType
end 
this@Simulink.interface.dictionary.NamedElement( zcImpl, enumType.getDictionary(  ).DictImpl );
this.EnumType = enumType;
end 

function destroy( this )



this.EnumType.removeEnumeral( this.Name );
delete( this );
end 

function desc = get.Description( this )
desc = this.ZCImpl.p_Description;
end 

function set.Description( this, value )
this.applyMethodOnSLEnumeral( 'setEnumDescription', value );
end 

function value = get.Value( this )
value = this.ZCImpl.p_Value;
end 

function set.Value( this, value )
this.applyMethodOnSLEnumeral( 'setEnumValue', value );
end 
end 

methods ( Access = protected )
function value = getName( this )
value = this.ZCImpl.getName;
end 

function setName( this, newName )
this.applyMethodOnSLEnumeral( 'setEnumName', newName );
end 
end 

methods ( Access = private )
function applyMethodOnSLEnumeral( this, methodName, varargin )
idict = this.getDictionary;
enumName = this.EnumType.Name;
ddEnum = idict.getDDEntryObject( enumName ).getValue(  );
enumeralIdx = find( strcmp( this.Name, { ddEnum.Enumerals.Name } ) );
ddEnum.( methodName )( enumeralIdx, varargin{ : } );%#ok<FNDSB>
idict.setDDEntryValue( enumName, ddEnum );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpOoJZpI.p.
% Please follow local copyright laws when handling this file.

