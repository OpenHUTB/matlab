classdef StructType < Simulink.interface.dictionary.DataType &  ...
matlab.mixin.CustomDisplay





properties ( Dependent = true, SetAccess = private )
Elements( 0, : )Simulink.interface.dictionary.StructElement
end 

properties ( Dependent = true )
Description{ mustBeTextScalar }
end 

methods ( Hidden, Access = protected )
function propgrp = getPropertyGroups( ~ )

proplist = { 'Name', 'Description', 'Elements', 'Owner' };
propgrp = matlab.mixin.util.PropertyGroup( proplist );
end 
end 

methods ( Hidden )
function this = StructType( interfaceDictAPI, zcImpl )



R36
interfaceDictAPI
zcImpl{ mustBeA( zcImpl, [ "systemcomposer.architecture.model.interface.CompositeDataInterface",  ...
"systemcomposer.property.StructDataType" ] ) }
end 

this@Simulink.interface.dictionary.DataType( interfaceDictAPI, zcImpl );
end 

function str = getTypeString( this )
str = [ 'Bus: ', this.Name ];
end 
end 

methods ( Hidden, Access = protected )
function value = getName( this )
value = this.ZCImpl.getName;
end 
end 

methods 
function elements = get.Elements( this )
elemsImpl = this.ZCImpl.getStructElementsInIndexOrder(  );
elements = Simulink.interface.dictionary.StructElement.empty( numel( elemsImpl ), 0 );
for i = 1:numel( elemsImpl )
elements( i ) = this.createElement( elemsImpl( i ) );
end 
end 

function element = addElement( this, elementName, varargin )



elemImpl = this.addStructElement( elementName, varargin{ : } );
element = this.createElement( elemImpl );
end 

function removeElement( this, elementName )



systemcomposer.BusObjectManager.DeleteInterfaceElement( this.getSourceName,  ...
false, this.Name, elementName );
end 

function element = getElement( this, elementName )



elemImpl = this.ZCImpl.getStructElement( elementName );
if isempty( elemImpl )
DAStudio.error( 'interface_dictionary:api:TypeElementDoesNotExist',  ...
this.Name, elementName );
end 
element = this.createElement( elemImpl );
end 

function value = get.Description( this )
value = this.ZCImpl.p_Description;
end 

function set.Description( this, newValue )

this.setDDEntryPropValue( 'Description', newValue );
end 
end 

methods ( Access = private )
function element = createElement( this, elemImpl )
element = Simulink.interface.dictionary.StructElement( elemImpl, this );
end 

function elementImpl = addStructElement( this, elementName )



systemcomposer.BusObjectManager.AddInterfaceElement( this.getSourceName,  ...
false, this.Name, elementName );
elementImpl = this.ZCImpl.getStructElement( elementName );
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpf5tMLg.p.
% Please follow local copyright laws when handling this file.

