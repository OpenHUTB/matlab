classdef ValueType < Simulink.interface.dictionary.DataType &  ...
matlab.mixin.CustomDisplay




properties ( Dependent = true )
DataType
Minimum
Maximum
Unit
Complexity
Dimensions
DimensionsMode
Description
end 

properties ( Access = private )
ZCImplFacade
end 

methods ( Hidden )
function this = ValueType( interfaceDictAPI, zcImpl )
R36
interfaceDictAPI
zcImpl{ mustBeA( zcImpl, [ "systemcomposer.architecture.model.interface.ValueTypeInterface",  ...
"systemcomposer.property.ValueTypeDescriptor" ] ) }
end 

this@Simulink.interface.dictionary.DataType( interfaceDictAPI, zcImpl );
if isa( this.ZCImpl, 'systemcomposer.property.ValueTypeDescriptor' )
this.ZCImplFacade = Simulink.interface.dictionary.internal.ValueTypeDescriptorFacade( zcImpl );
else 
this.ZCImplFacade = Simulink.interface.dictionary.internal.ValueTypeInterfaceFacade( zcImpl );
end 
end 
end 

methods ( Hidden, Access = protected )
function propgrp = getPropertyGroups( ~ )

proplist = { 'Name', 'DataType', 'Minimum', 'Maximum', 'Unit',  ...
'Complexity', 'Dimensions', 'Description', 'Owner' };
propgrp = matlab.mixin.util.PropertyGroup( proplist );
end 
end 

methods 
function typeStr = get.DataType( this )
typeStr = this.ZCImplFacade.getDataType(  );
end 

function set.DataType( this, type )
R36
this
type{ mustBeA( type, { 'char', 'string',  ...
'Simulink.interface.dictionary.DataType' } ) }
end 
this.ZCImplFacade.setDataType( type );
end 

function val = get.Dimensions( this )
val = this.ZCImplFacade.getDimensions;
end 

function set.Dimensions( this, value )
this.ZCImplFacade.setDimensions( value );
end 

function val = get.Unit( this )
val = this.ZCImplFacade.getUnit;
end 

function set.Unit( this, unit )
this.ZCImplFacade.setUnit( unit );
end 

function val = get.Complexity( this )
val = this.ZCImplFacade.getComplexity;
end 

function set.Complexity( this, complexity )
this.ZCImplFacade.setComplexity( complexity );
end 

function val = get.Minimum( this )
val = this.ZCImplFacade.getMinimum;
end 

function set.Minimum( this, min )
this.ZCImplFacade.setMinimum( min );
end 

function val = get.Maximum( this )
val = this.ZCImplFacade.getMaximum;
end 

function set.Maximum( this, max )
this.ZCImplFacade.setMaximum( max );
end 

function val = get.Description( this )
val = this.ZCImplFacade.getDescription;
end 

function set.Description( this, value )
this.ZCImplFacade.setDescription( value );
end 

function value = get.DimensionsMode( this )

value = this.getDDEntryPropValue( 'DimensionsMode' );
end 

function set.DimensionsMode( this, newVal )

this.setDDEntryPropValue( 'DimensionsMode', newVal );
end 
end 

methods ( Access = protected )
function value = getName( this )
value = this.ZCImplFacade.getName(  );
end 

function setName( this, newName )
this.ZCImplFacade.setName( newName );
end 
end 

methods ( Hidden )
function str = getTypeString( this )
str = [ 'ValueType: ', this.Name ];
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp5OOG_T.p.
% Please follow local copyright laws when handling this file.

