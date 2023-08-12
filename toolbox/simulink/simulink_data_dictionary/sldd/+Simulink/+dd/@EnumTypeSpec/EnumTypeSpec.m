classdef ( ConstructOnLoad = true )EnumTypeSpec < handle & matlab.io.savevars.internal.Serializable







properties ( SetAccess = private )
Enumerals
end 

properties 
Description char
DataScope char = 'Auto';
HeaderFile char
DefaultValue char
StorageType char
AddClassNameToEnumNames = false;

end 

properties ( Constant, Hidden )


m_editablePropertyNames = {  ...
'Description'; ...
'DataScope'; ...
'HeaderFile'; ...
'DefaultValue'; ...
'StorageType'; ...
'AddClassNameToEnumNames' };
m_storageTypes = {  ...
'int8'; ...
'int16'; ...
'int32'; ...
'uint8'; ...
'uint16' };
m_dataScopes = {  ...
'Auto'; ...
'Exported'; ...
'Imported' };
end 


methods 
function appendEnumeral( obj, name, value, description )
R36
obj( 1, 1 )
name( 1, : )
value( 1, : )
description( 1, : ) = ''
end 

narginchk( 3, 4 );


name = l_validateEnumeralName( obj, name );


stringValue = l_validateEnumeralValue( value );


description = l_validateDescription( description );


newEnumNum = length( obj.Enumerals ) + 1;
obj.Enumerals( newEnumNum ).Name = name;
obj.Enumerals( newEnumNum ).Value = stringValue;
obj.Enumerals( newEnumNum ).Description = description;
end 

function removeEnumeral( obj, enumNum )
R36
obj( 1, 1 )
enumNum( 1, 1 ){ mustBeNumeric }
end 

obj.Enumerals( enumNum ) = [  ];
end 
end 


methods ( Hidden )
function obj = EnumTypeSpec

obj.clearEnumerals(  );
obj.appendEnumeral( obj.getUniqueEnumName, obj.getEnumeralDefaultValue, '' );
end 

function clearEnumerals( obj )
obj.Enumerals = struct( 'Name', {  }, 'Value', {  }, 'Description', {  } );
end 

function numEnums = numEnumerals( obj )
numEnums = length( obj.Enumerals );
end 



function [ name, value, description ] = enumeralAt( obj, enumNum )
if ( enumNum >= 1 ) && ( enumNum <= length( obj.Enumerals ) )
name = obj.Enumerals( enumNum ).Name;
value = obj.Enumerals( enumNum ).Value;
description = obj.Enumerals( enumNum ).Description;
end 
end 

function swapEnumerals( obj, enumNum1, enumNum2 )
numEnums = length( obj.Enumerals );
if ( enumNum1 >= 1 ) && ( enumNum1 <= numEnums ) &&  ...
( enumNum2 >= 1 ) && ( enumNum2 <= numEnums ) &&  ...
( enumNum1 ~= enumNum2 )
tmp = obj.Enumerals( enumNum1 );
obj.Enumerals( enumNum1 ) = obj.Enumerals( enumNum2 );
obj.Enumerals( enumNum2 ) = tmp;
end 
end 

function hasEnum = hasEnumeral( obj, name )
enumeralNames = { obj.Enumerals.Name }';
hasEnum = ismember( name, enumeralNames );
end 

function enumName = getUniqueEnumName( obj )
numEnums = length( obj.Enumerals );
for suffix = ( numEnums + 1 ):( ( numEnums * 2 ) + 1 )
enumName = [ 'enum', num2str( suffix ) ];
if ~hasEnumeral( obj, enumName )
break ;
end 
end 
end 

function outcome = getEnumeralDefaultValue( obj )
MaxRetry = 1000;
value = length( obj.Enumerals );
[ enumeralValues{ 1:length( obj.Enumerals ) } ] = deal( obj.Enumerals.Value );
retryCount = 1;
valueStr = num2str( value );
while ( ismember( valueStr, enumeralValues ) && ( retryCount < MaxRetry ) )
value = value + 1;
valueStr = num2str( value );
retryCount = retryCount + 1;
end 
if retryCount == MaxRetry

value = 0;
end 
outcome = value;
end 

function setEnumName( obj, enumNum, newName )
numEnums = length( obj.Enumerals );
if ( enumNum >= 1 ) && ( enumNum <= numEnums ) &&  ...
~strcmp( obj.Enumerals( enumNum ).Name, newName )
l_validateEnumeralName( obj, newName );
obj.Enumerals( enumNum ).Name = newName;
end 
end 

function setEnumValue( obj, enumNum, newValue )
numEnums = length( obj.Enumerals );
if ( enumNum >= 1 ) && ( enumNum <= numEnums )
stringValue = l_validateEnumeralValue( newValue );
obj.Enumerals( enumNum ).Value = stringValue;
end 
end 

function setEnumDescription( obj, enumNum, newDescription )
numEnums = length( obj.Enumerals );
if ( enumNum >= 1 ) && ( enumNum <= numEnums )
obj.Enumerals( enumNum ).Description = newDescription;
end 
end 

function disp( obj )
disp( '   Simulink.dd.EnumTypeSpec' );
for e = 1:length( obj.Enumerals )
disp( [ '      ', obj.Enumerals( e ).Name ] );
end 
end 





function dlgstruct = getDialogSchema( obj, objName )
dlgstruct = Simulink.dd.enumtypeddg( [  ], obj, objName );
end 

function isValid = isValidProperty( ~, propName )
isValid = ismember( propName, Simulink.dd.EnumTypeSpec.m_editablePropertyNames );
end 
function isReadonly = isReadonlyProperty( ~, ~ )
isReadonly = false;
end 
function out = getPossibleProperties( ~ )
out = Simulink.dd.EnumTypeSpec.m_editablePropertyNames;
end 
function out = getPreferredProperties( ~ )
out = Simulink.dd.EnumTypeSpec.m_editablePropertyNames;
end 
function propDataType = getPropDataType( ~, propName )
if strcmp( propName, 'AddClassNameToEnumNames' )
propDataType = 'bool';
elseif strcmp( propName, 'DefaultValue' ) ||  ...
strcmp( propName, 'DataScope' ) ||  ...
strcmp( propName, 'StorageType' )
propDataType = 'enum';
else 
propDataType = 'string';
end 
end 
function allowedValues = getPropAllowedValues( thisObj, propName )
allowedValues = {  };
if strcmp( propName, 'DefaultValue' )
numEnums = length( thisObj.Enumerals );
allowedValues = cell( numEnums, 1 );
for e = 1:length( thisObj.Enumerals )
allowedValues{ e } = thisObj.Enumerals( e ).Name;
end 
elseif strcmp( propName, 'DataScope' )
allowedValues = { 'Auto';'Exported';'Imported' };
elseif strcmp( propName, 'StorageType' )
allowedValues = [  ...
{ DAStudio.message( 'RTW:configSet:optActiveStateOutputTargetIntegerType' ) }; ...
Simulink.dd.EnumTypeSpec.m_storageTypes ];
end 
end 
function propValue = getPropValue( thisObj, propName )
propValue = '';
if isValidProperty( thisObj, propName )
propValue = thisObj.( propName );

if strcmp( propName, 'DefaultValue' )
if isempty( propValue ) && ~isempty( thisObj.Enumerals )
propValue = enumeralAt( thisObj, 1 );
end 
elseif strcmp( propName, 'StorageType' )
if isempty( propValue )
propValue = DAStudio.message( 'RTW:configSet:optActiveStateOutputTargetIntegerType' );
end 
elseif strcmp( getPropDataType( thisObj, propName ), 'bool' )
assert( isscalar( propValue ) && islogical( propValue ) );
if propValue
propValue = 'on';
else 
propValue = 'off';
end 
end 
end 
end 
function setPropValue( thisObj, propName, propValue )
if isValidProperty( thisObj, propName )
if strcmp( propName, 'StorageType' )
if isequal( propValue, DAStudio.message( 'RTW:configSet:optActiveStateOutputTargetIntegerType' ) )
propValue = '';
end 
end 
thisObj.( propName ) = propValue;
end 
end 
function fileName = getDisplayIcon( ~ )

fileName = 'toolbox/shared/dastudio/resources/SimulinkType.png';
end 

end 


methods 
function set.DataScope( obj, value )
if isempty( value )

obj.DataScope = 'Auto';
elseif ismember( value, Simulink.dd.EnumTypeSpec.m_dataScopes )
obj.DataScope = value;
else 
DAStudio.error( 'Simulink:DataType:InvalidDataScope', value );
end 
end 

function set.DefaultValue( obj, value )
if isempty( value ) || hasEnumeral( obj, value )
obj.DefaultValue = value;
else 
DAStudio.error( 'Simulink:DataType:DynamicEnum_InvalidDefaultValue' );
end 
end 

function set.StorageType( obj, value )

if ( isempty( value ) ||  ...
strcmp( value, 'int' ) ||  ...
strcmp( value, DAStudio.message( 'RTW:configSet:optActiveStateOutputTargetIntegerType' ) ) )
obj.StorageType = '';
elseif ismember( value, Simulink.dd.EnumTypeSpec.m_storageTypes )
obj.StorageType = value;
else 
DAStudio.error( 'Simulink:DataType:DynamicEnum_InvalidStorageType' );
end 
end 

function set.AddClassNameToEnumNames( obj, value )
if ischar( value )
switch value
case { '0', 'off' }
obj.AddClassNameToEnumNames = false;
case { '1', 'on' }
obj.AddClassNameToEnumNames = true;
otherwise 
DAStudio.error( 'SLDD:sldd:ErrorSettingAddClassNameToEnumNamesProperty' );
end 
elseif isscalar( value )
if islogical( value )
obj.AddClassNameToEnumNames = value;
elseif ( isnumeric( value ) &&  ...
( ( value == false ) || ( value == true ) ) )

obj.AddClassNameToEnumNames = logical( value );
else 
DAStudio.error( 'SLDD:sldd:ErrorSettingAddClassNameToEnumNamesProperty' );
end 
else 
DAStudio.error( 'SLDD:sldd:ErrorSettingAddClassNameToEnumNamesProperty' );
end 
end 
end 
end 





function name = l_validateEnumeralName( obj, name )
if isvarname( name )
name = char( name );
if hasEnumeral( obj, name )
DAStudio.error( 'Simulink:DataType:DynamicEnum_DuplicateEnumString', name );
end 
elseif ischar( name ) || ( isstring( name ) && isscalar( name ) )
DAStudio.error( 'Simulink:DataType:DynamicEnum_InvalidEnumString', name );
else 
DAStudio.error( 'Simulink:DataType:DynamicEnum_AttributeValueMustBeString', 'Name' );
end 
end 

function stringValue = l_validateEnumeralValue( value )
if ischar( value ) || isstring( value )
numericValue = str2double( value );
else 
numericValue = value;
end 

if ( isscalar( numericValue ) &&  ...
isnumeric( numericValue ) &&  ...
isreal( numericValue ) &&  ...
isfinite( numericValue ) &&  ...
double( int32( numericValue ) ) == numericValue )

stringValue = num2str( int32( numericValue ) );
else 
DAStudio.error( 'Simulink:DataType:DynamicEnum_EnumValuesNotInteger' );
end 
end 

function description = l_validateDescription( description )
if isstring( description ) && isscalar( description )
description = char( description );
elseif ~ischar( description )
DAStudio.error( 'Simulink:DataType:DynamicEnum_AttributeValueMustBeString', 'Description' );
end 

if isempty( description )
description = '';
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpTrkRfL.p.
% Please follow local copyright laws when handling this file.

