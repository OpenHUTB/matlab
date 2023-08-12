classdef DesignDataContents < handle




properties ( Hidden, Constant, Access = private )

AllowedDataTypeClasses = { 'Simulink.Bus',  ...
'Simulink.ValueType', 'Simulink.AliasType',  ...
'Simulink.data.dictionary.EnumTypeDefinition' };
SLDDQualifier = 'Global';
end 

properties ( Access = private )
SLDDConn Simulink.dd.Connection;
DictImpl sl.interface.dict.InterfaceDictionary;
end 

properties ( Dependent, SetAccess = private )
DictionaryFileName
end 

methods 
function this = DesignDataContents( dictFileName )
this.DictImpl = sl.interface.dict.api.openInterfaceDictionary( dictFileName );
this.SLDDConn = Simulink.dd.open( dictFileName );
end 

function value = get.DictionaryFileName( this )
[ ~, f, e ] = fileparts( this.SLDDConn.filespec );
value = [ f, e ];
end 

function addDataType( this, name, dataObject )

if this.checkEntryExists( name )
DAStudio.error( 'interface_dictionary:api:EntryAlreadyExists',  ...
this.DictionaryFileName, name );
end 

if isprop( dataObject, 'HeaderFile' )

dataObject.DataScope = 'Auto';
dataObject.HeaderFile = '';
end 


this.SLDDConn.insertEntry( this.SLDDQualifier, name,  ...
dataObject );
end 


function removeDataType( this, name )
R36
this
name{ mustBeTextScalar, mustBeNonzeroLengthText }
end 
this.removeEntry( name );
end 

function entry = addConstant( this, name )

this.SLDDConn.insertEntry( this.SLDDQualifier, name,  ...
SL.Constant );


entry = this.getEntryObject( name );
end 

function entry = getConstant( this, name )
R36
this
name{ mustBeTextScalar, mustBeNonzeroLengthText }
end 
entry = this.getEntryObject( name );

if isempty( this.DictImpl.DictionaryCatalog.Constants.getByKey( entry.UUID ) )
DAStudio.error( 'interface_dictionary:api:ConstantDoesNotExist',  ...
this.DictionaryFileName, name );
end 
end 

function constantNames = getConstantNames( this )
constantNames = this.SLDDConn.getEntriesWithClass(  ...
this.SLDDQualifier, 'Simulink.Parameter' );
end 

function removeConstant( this, name )
R36
this
name{ mustBeTextScalar, mustBeNonzeroLengthText }
end 
this.removeEntry( name );
end 

function setEntryValue( this, name, value )
entry = this.getEntryObject( name );
entry.setValue( value );
end 

function entry = getEntryObject( this, entryName )
qualifiedEntryName = this.getQualifiedEntryName( entryName );
entry = this.SLDDConn.getEntryObject( qualifiedEntryName );
if isempty( entry )
DAStudio.error( 'interface_dictionary:api:EntryDoesNotExist',  ...
this.DictionaryFileName, entryName );
end 
end 

function setDDEntryPropertyValue( this, entryName, propName, newValue )
ddEntry = this.getEntryObject( entryName );
ddValue = ddEntry.getValue(  );
ddValue.( propName ) = newValue;
this.setEntryValue( entryName, ddValue );
end 

function value = getDDEntryPropertyValue( this, entryName, propName )
ddEntry = this.getEntryObject( entryName );
ddValue = ddEntry.getValue(  );
value = ddValue.getPropValue( propName );
end 

function exists = checkEntryExists( this, name )
qName = this.getQualifiedEntryName( name );
exists = this.SLDDConn.entryExists( qName );
end 
end 

methods ( Static )
function isDT = isAllowedDataTypeClass( entryValue )
import Simulink.interface.dictionary.internal.DesignDataContents
isDT = any( cellfun( @( x )isa( entryValue, x ), DesignDataContents.AllowedDataTypeClasses ) );
end 
end 

methods ( Access = private )
function removeEntry( this, entryName )
qualifiedEntryName = this.getQualifiedEntryName( entryName );
if this.SLDDConn.entryExists( qualifiedEntryName )
this.SLDDConn.deleteEntry( qualifiedEntryName );
else 
DAStudio.error( 'interface_dictionary:api:EntryDoesNotExist',  ...
this.DictionaryFileName, entryName );
end 
end 

function qualifiedEntryName = getQualifiedEntryName( this, entryName )



qualifiedEntryName = [ this.SLDDQualifier, '.', char( entryName ) ];
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpw9KkZC.p.
% Please follow local copyright laws when handling this file.

