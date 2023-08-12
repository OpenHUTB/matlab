classdef ( Abstract )DesignNode < sl.interface.dictionaryApp.node.AbstractNode







properties ( Access = public )

UDTAssistOpen = struct( 'tags', { { 'DataType' } }, 'status', { { false } } );
UDTIPOpen = struct( 'tags', { { 'DataType' } }, 'status', { { false } } );
end 

properties ( Access = protected )
DictObj Simulink.interface.Dictionary;
PlatformKind sl.interface.dict.mapping.PlatformMappingKind;
CachedName char;
InterfaceDictElement;

Properties;
IsPlatformPropsInitialized( 1, 1 )logical = false;

Children;

TypeEditorObject;

Studio sl.interface.dictionaryApp.StudioApp;
end 

properties ( Dependent, Access = public )

DataTypeForDTA;
end 

properties ( Abstract, Constant, Access = protected )


GenericPropertyNames cell;


TypePropName( 1, : )char;
end 

methods ( Abstract, Access = public )
nodeType = getNodeType( this );
end 

methods ( Abstract, Access = protected )
dlgSchema = customizeDialogSchema( this, dlgSchema );
end 

methods ( Static, Access = public )
function node = getDesignNode( interfaceDictObj, dictObj, platformKind, studio, listObj )
R36
interfaceDictObj( 1, 1 );
dictObj( 1, 1 )Simulink.interface.Dictionary;
platformKind sl.interface.dict.mapping.PlatformMappingKind
studio sl.interface.dictionaryApp.StudioApp;
listObj sl.interface.dictionaryApp.list.List;
end 

if isa( interfaceDictObj, 'Simulink.interface.dictionary.PortInterface' )
node = sl.interface.dictionaryApp.node.InterfaceNode(  ...
interfaceDictObj, dictObj, platformKind, studio );
elseif isa( interfaceDictObj, 'Simulink.interface.dictionary.DataType' )
node = sl.interface.dictionaryApp.node.DataTypeNode.getDataTypeNode(  ...
interfaceDictObj, dictObj, platformKind, studio );
elseif isa( interfaceDictObj, 'Simulink.interface.dictionary.Constant' )
node = sl.interface.dictionaryApp.node.ConstantNode(  ...
interfaceDictObj, dictObj, platformKind, studio );
else 
assert( false, 'Unexpected object type: %s', class( interfaceDictObj ) )
end 

listObj.setGenericNodePropertiesFromCache( node );
end 
end 

methods ( Access = public )

function initializeGenericProperties( this )



this.Properties = this.getGenericProperties(  );
end 

function propertyNames = getPIPropertyNames( this )

propertyNames = this.Properties.keys;
end 

function propertyMap = getPropertiesMap( this )
propertyMap = this.Properties;
end 

function propertyMap = setPropertiesMap( this, propertyMap )
this.Properties = propertyMap;
end 

function isHier = isHierarchical( this )
isHier = ~isempty( this.Children );
end 

function dlgSchema = getDialogSchema( this )
typeEditorObject = this.getTypeEditorObject(  );
dlgSchema = typeEditorObject.getDialogSchema(  );
dlgSchema.Source = this;
dlgSchema = this.customizeDialogSchema( dlgSchema );
dlgSchema = this.addPlatformWidgetsToDlgSchema( dlgSchema );
end 

function displayLabel = getDisplayLabel( this )

try 

displayLabel = this.InterfaceDictElement.Name;
catch 


displayLabel = this.getCachedName(  );
end 
end 

function icon = getDisplayIcon( this )
icon = '';
if this.isValid


typeEditorObj = this.getTypeEditorObject(  );
icon = typeEditorObj.getDisplayIcon(  );
end 
end 

function children = getHierarchicalChildren( this )
children = this.Children;
end 

function isValid = isValidProperty( this, propName )
propName = this.getRealPropName( propName );
isValid = this.Properties.isKey( propName );
end 

function isReadonly = isReadonlyProperty( this, propName )
propName = this.getRealPropName( propName );
assert( this.isValidProperty( propName ), 'Unexpected property' );
isReadonly = false;
end 

function dataType = getPropDataType( this, propName )
propName = this.getRealPropName( propName );
assert( this.isValidProperty( propName ), 'Unexpected property' );
dataType = this.Properties( propName ).DataType;
end 

function values = getPropAllowedValues( this, propName )
propName = this.getRealPropName( propName );
assert( this.isValidProperty( propName ), 'Unexpected property' );
if this.Properties( propName ).HasDynamicAllowedValues
values = this.getDynamicPropAllowedValuesFor( propName );
else 
values = this.Properties( propName ).AllowedValues;
end 
end 

function propVal = getPropValue( this, propName )
propName = this.getRealPropName( propName );
if strcmp( propName,  ...
sl.interface.dictionaryApp.node.PackageString.NameProp )
propVal = this.InterfaceDictElement.Name;
elseif this.isPlatformProperty( propName )
platformMap = this.DictObj.getPlatformMapping( this.PlatformKind );
propVal = platformMap.getPlatformProperty( this.InterfaceDictElement,  ...
propName );
if strcmp( this.getPropDataType( propName ), 'bool' )
propVal =  ...
sl.interface.dictionaryApp.node.DesignNode.convertBoolToChar( propVal );
end 
elseif this.isGenericProperty( propName )
if isa( this.InterfaceDictElement, 'Simulink.interface.dictionary.Constant' )

propVal = this.getPropValue( propName );
else 
propVal = this.InterfaceDictElement.get( propName );
end 
else 
assert( false, 'Unexpected property' );
end 
end 

function setPropValue( this, propName, propVal )



switch class( this )
case { 'sl.interface.dictionaryApp.node.InterfaceNode',  ...
'sl.interface.dictionaryApp.node.InterfaceElementNode'
'sl.interface.dictionaryApp.node.StructTypeNode',  ...
'sl.interface.dictionaryApp.node.StructElementNode' }



cleanupObj = this.Studio.disableSLDDListener(  );%#ok
isSLDDListenerDisabled = true;
otherwise 

isSLDDListenerDisabled = false;
end 

propName = this.getRealPropName( propName );
try 
if this.isGenericProperty( propName )
if isa( this.InterfaceDictElement, 'Simulink.interface.dictionary.Constant' )

this.setPropValue( propName, propVal );
else 
this.InterfaceDictElement.set( propName, propVal );
end 
if strcmp( propName,  ...
sl.interface.dictionaryApp.node.PackageString.NameProp ) &&  ...
~isempty( propVal )
this.CachedName = propVal;
end 
else 
assert( this.isPlatformProperty( propName ), 'Unexpected property' );
platformMap = this.DictObj.getPlatformMapping( this.PlatformKind );
if strcmp( this.getPropDataType( propName ), 'bool' )
propVal =  ...
sl.interface.dictionaryApp.node.DesignNode.convertCharToBool( propVal );
end 
platformMap.setPlatformProperty( this.InterfaceDictElement,  ...
propName, propVal );
end 
catch ME
this.reportPIError( propName, ME )
return ;
end 
this.clearPIError( propName );
this.refreshGUIObjsAndCachesForNewProp( propName, propVal, isSLDDListenerDisabled );
end 

function isValid = isValid( this )



isValid = this.DictObj.DictImpl.isvalid(  ) &&  ...
this.InterfaceDictElement.isValid(  );
end 

function dataObj = getDataObject( this )
slddEntry = this.DictObj.getDDEntryObject( this.InterfaceDictElement.Name );
dataObj = slddEntry.getValue(  );

if isprop( dataObj, 'UDTAssistOpen' ) && isprop( dataObj, 'UDTIPOpen' )
dataObj.UDTAssistOpen = this.UDTAssistOpen;
dataObj.UDTIPOpen = this.UDTIPOpen;
end 
end 

function itfDictElement = getInterfaceDictElement( this )
itfDictElement = this.InterfaceDictElement;
end 

function fwdObj = getForwardedObject( this )


typeEditorObj = this.getTypeEditorObject(  );
fwdObj = typeEditorObj.getForwardedObject(  );
end 

function replaceDataObject( this, dataObject )
slddEntry = this.DictObj.getDDEntryObject( this.InterfaceDictElement.Name );
slddEntry.setValue( dataObject );
end 

function availableDataTypes = getAvailableDataTypes( this )






if ~isa( this, 'sl.interface.dictionaryApp.node.ElementNode' )


slprivate( 'slUpdateDataTypeListSource', 'set', this.DictObj.SLDDConn );
clearDTL = onCleanup( @(  )slprivate( 'slUpdateDataTypeListSource', 'clear' ) );
end 

allDataTypes = this.getAllDataTypes(  );

availableDataTypes = this.filterInterfacesFromTypes( allDataTypes );
end 

function dictObj = getInterfaceDictionary( this )
dictObj = this.DictObj;
end 

function allowed = isDragAllowed( this )%#ok<MANU>

allowed = false;
end 

function allowed = isDropAllowed( this )%#ok<MANU>

allowed = false;
end 

function contextMenu = getContextMenuItems( this )
typeEditorObject = this.getTypeEditorObject(  );
contextMenu = typeEditorObject.getContextMenuItems(  );
contextMenu = this.customizeContextMenu( contextMenu );
end 

function hasPlatformProps = hasPlatformProperties( this )
hasPlatformProps = ~isempty( this.getPlatformProperties(  ) );
end 

function isNodeExpanded = isExpanded( this )

isNodeExpanded = this.Studio.isNodeExpanded( this );
end 

function typeEditorObject = getTypeEditorObject( this, namedArgs )
R36
this
namedArgs.RefreshTypeEditorObject = false;
end 

if isempty( this.TypeEditorObject ) || namedArgs.RefreshTypeEditorObject
this.TypeEditorObject =  ...
sl.interface.dictionaryApp.node.typeeditor.ObjectAdapter( this,  ...
this.getDataObject(  ), this.getStudio(  ) );
assert( ~isempty( this.TypeEditorObject ),  ...
'Did not construct TypeEditor object' );
end 
typeEditorObject = this.TypeEditorObject;
end 

function dialogTag = getDialogTag( this )
typeEditorObject = this.getTypeEditorObject(  );
dialogTag = typeEditorObject.getDialogTag(  );
end 
end 

methods 
function name = get.DataTypeForDTA( this )
name = this.getPropValue( 'DataType' );
end 

function set.DataTypeForDTA( ~, ~ )
assert( false, 'Cannot set datatype of node' );
end 
end 

methods ( Hidden )
function objType = getObjectType( this )
objClass = class( this.InterfaceDictElement );

objClass = split( objClass, '.' );
objType = objClass{ end  };
end 

function cachedNodeName = getCachedName( this )

cachedNodeName = this.CachedName;
end 

function availableDataTypes = filterInterfacesFromTypes( this, allDataTypes )
if isstruct( allDataTypes )
dataTypeNames = { allDataTypes.name };
else 
dataTypeNames = allDataTypes;
end 
interfaceNames = this.DictObj.getInterfaceNames(  );

for itfIdx = 1:length( interfaceNames )
interfaceNames{ itfIdx } =  ...
sprintf( 'Bus: %s', interfaceNames{ itfIdx } );
end 
[ ~, idxs ] = intersect( dataTypeNames, interfaceNames );
allDataTypes( idxs ) = [  ];
availableDataTypes = allDataTypes;
end 
end 

methods ( Access = protected )
function this = DesignNode( interfaceDictElement, dictObj, platformKind, studio )
this.InterfaceDictElement = interfaceDictElement;
this.DictObj = dictObj;
this.PlatformKind = platformKind;
this.Studio = studio;
this.Properties = containers.Map(  );

try 

this.CachedName = this.Name;
catch 


end 
end 

function platformProps = getPlatformProperties( this )

platformProps = containers.Map( 'KeyType', 'char',  ...
'ValueType', 'any' );

if isempty( this.PlatformKind )

return 
end 

platformMapping = this.DictObj.getPlatformMapping( this.PlatformKind );
platformPropertyNames = platformMapping.getPlatformProperties( this.InterfaceDictElement );

numProps = length( platformPropertyNames );

isPlatformSpecificProp = true;

for propIdx = 1:numProps
propName = platformPropertyNames{ propIdx };
dataType = platformMapping.getPlatformPropertyDataType(  ...
this.InterfaceDictElement, propName );
hasDynamicAllowedValues = platformMapping.hasDynamicAllowedValues(  ...
this.InterfaceDictElement, propName );
if hasDynamicAllowedValues

allowedValues = {  };
else 
allowedValues = platformMapping.getPlatformPropertyAllowedValues(  ...
this.InterfaceDictElement, propName );
end 
platformProps( propName ) =  ...
sl.interface.dictionaryApp.node.PropertySchema(  ...
dataType, allowedValues, hasDynamicAllowedValues,  ...
isPlatformSpecificProp );
end 
end 

function genericProps = getGenericProperties( this )
isPlatformSpecificProp = false;

numProps = length( this.GenericPropertyNames );

genericProps = containers.Map( 'KeyType', 'char',  ...
'ValueType', 'any' );



dataObj = this.getDataObject(  );

for propIdx = 1:numProps
propName = this.GenericPropertyNames{ propIdx };
propName = this.getRealPropName( propName );
dataType = dataObj.getPropDataType( propName );
if any( strcmp( propName,  ...
{ sl.interface.dictionaryApp.node.PackageString.DataTypeProp,  ...
sl.interface.dictionaryApp.node.PackageString.BaseTypeProp } ) )


allowedValues = {  };
hasDynamicAllowedValues = true;
else 
allowedValues = dataObj.getPropAllowedValues( propName );
hasDynamicAllowedValues = false;
end 
genericProps( propName ) =  ...
sl.interface.dictionaryApp.node.PropertySchema(  ...
dataType, allowedValues, hasDynamicAllowedValues,  ...
isPlatformSpecificProp );
end 
end 

function dlgSchema = addPlatformWidgetsToDlgSchema( this, dlgSchema )
if isempty( this.PlatformKind ) || this.PlatformKind ~=  ...
sl.interface.dict.mapping.PlatformMappingKind.AUTOSARClassic

return ;
end 

this.initializePlatformProperties(  );

platformTogglePanel.Name = 'AUTOSAR';
platformTogglePanel.Type = 'togglepanel';
platformTogglePanel.Expand = true;
platformTogglePanel.Tag = [ 'grpPlatformProps_' ...
, char( this.PlatformKind ) ];
platformTogglePanel.Items = {  };
propNames = this.Properties.keys;

for propIdx = 1:length( propNames )
curPropName = propNames{ propIdx };
currentProp = this.Properties( curPropName );
if ~currentProp.IsPlatformSpecificProp

continue ;
end 
propWidget.Name = [ curPropName, ':' ];
propWidget.Graphical = true;
propValue = this.getPropValue( curPropName );
switch currentProp.DataType
case 'enum'
propWidget.Type = 'combobox';
propWidget.Entries = currentProp.AllowedValues;

propWidget.Value =  ...
find( strcmp( currentProp.AllowedValues, propValue ) ) - 1;
case 'bool'
propWidget.Type = 'checkbox';
propWidget.Name = propWidget.Name( 1:end  - 1 );
if strcmp( propValue, '0' )
propWidget.Value = false;
elseif strcmp( propValue, '1' )
propWidget.Value = true;
else 
assert( false, 'unexpected value for boolean property' );
end 
case { 'string', 'edit' }
propWidget.Type = 'edit';
propWidget.Value = propValue;
otherwise 
assert( false, 'Unexpected property data type' );
end 
propWidget.Tag = curPropName;
propWidget.Enabled = true;
propWidget.Mode = true;
propWidget.Graphical = true;
propWidget.ObjectProperty = curPropName;
platformTogglePanel.Items{ end  + 1 } = propWidget;
end 
noRows = length( platformTogglePanel.Items );
platformTogglePanel.LayoutGrid =  ...
[ noRows + 1, 2 ];
platformTogglePanel.RowStretch = [ zeros( 1, noRows ), 1 ];
if noRows > 0
dlgSchema.Items{ end  + 1 } = platformTogglePanel;
end 
end 

function contextMenu = customizeContextMenu( ~, contextMenu )



contextMenu(  ...
strcmp( DAStudio.message( 'Simulink:busEditor:CreateSimulinkParameterContext' ),  ...
{ contextMenu.label } ) ) =  ...
[  ];

contextMenu(  ...
strcmp( DAStudio.message( 'Simulink:busEditor:CreateMATLABStructContext' ),  ...
{ contextMenu.label } ) ) =  ...
[  ];

contextMenu(  ...
strcmp( DAStudio.message( 'Simulink:busEditor:ExportContext' ),  ...
{ contextMenu.label } ) ) =  ...
[  ];
contextMenu(  ...
strcmp( DAStudio.message( 'Simulink:busEditor:ExportWithDependentTypesContext' ),  ...
{ contextMenu.label } ) ) =  ...
[  ];


contextMenu( strcmp( DAStudio.message( 'Simulink:busEditor:Cut' ),  ...
{ contextMenu.label } ) ) =  ...
[  ];
end 

function studio = getStudio( this )
studio = this.Studio;
end 

function isGenericProperty = isGenericProperty( this, propName )
isGenericProperty =  ...
~this.Properties( propName ).IsPlatformSpecificProp;
end 

function isPlatformProperty = isPlatformProperty( this, propName )
isPlatformProperty =  ...
this.Properties( propName ).IsPlatformSpecificProp;
end 

function realPropName = getRealPropName( this, propName )


if any( strcmp( propName,  ...
{ sl.interface.dictionaryApp.node.PackageString.TypeColHeader,  ...
sl.interface.dictionaryApp.node.PackageString.TypeProp,  ...
'DataTypeForDTA' } ) )
realPropName = this.TypePropName;
else 
realPropName = sl.interface.dictionaryApp.node.PackageString. ...
getPropNameForColHeader( propName );
end 
end 

function initializeMimeData( this )
kvPairList = GLEE.ByteArrayList;
propertyNames = this.Properties.keys;
for curProp = propertyNames

val = this.getPropValueAsString( curProp{ 1 } );
ele = GLEE.ByteArrayPair( GLEE.ByteArray( curProp{ 1 } ), GLEE.ByteArray( val ) );
kvPairList.add( ele );

end 
this.MimeData = kvPairList;
end 
end 

methods ( Access = private )

function initializePlatformProperties( this )
if ~this.IsPlatformPropsInitialized
this.Properties = [ this.Properties; ...
this.getPlatformProperties(  ) ];
this.IsPlatformPropsInitialized = true;
end 
end 

function allDataTypes = getAllDataTypes( this )



dataObj = this.getTypeEditorObject(  );
allDataTypes = dataObj.getPropAllowedValues( this.TypePropName );
allDataTypes = this.addDataTypeExpressionToDataTypeList( allDataTypes );
end 

function valStr = getPropValueAsString( this, propName )
val = this.getPropValue( propName );
if isnumeric( val ) || islogical( val )
valStr = num2str( val );
else 
assert( ischar( val ) || isstring( val ) );
valStr = val;
end 
end 

function values = getDynamicPropAllowedValuesFor( this, propName )
if any( strcmp( propName,  ...
{ sl.interface.dictionaryApp.node.PackageString.DataTypeProp,  ...
sl.interface.dictionaryApp.node.PackageString.BaseTypeProp } ) )
values = this.getAvailableDataTypes(  );
elseif this.isPlatformProperty( propName )
platformMapping = this.DictObj.getPlatformMapping( this.PlatformKind );
values = platformMapping.getPlatformPropertyAllowedValues(  ...
this.InterfaceDictElement, propName );
else 
assert( false, 'Unexpected property' );
end 
end 

function destinationTabId = getSpreadsheetTabId( nodeObj )
classType = class( nodeObj );
switch classType
case { 'sl.interface.dictionaryApp.node.InterfaceNode',  ...
'sl.interface.dictionaryApp.node.InterfaceElementNode' }
destinationTabId = 'InterfacesTab';
otherwise 
destinationTabId = 'DataTypesTab';
end 
end 

function refreshGUIObjsAndCachesForNewProp( this, propName, propVal, isSLDDListenerDisabled )


if strcmp( propName, 'Name' ) || strcmp( propName, 'Description' ) && ~isempty( this.getTypeEditorObject )

if ~strcmp( propVal, this.getTypeEditorObject.Name )

oldDictElementName = this.getTypeEditorObject.Name;
this.getTypeEditorObject( RefreshTypeEditorObject = true );
end 

if isSLDDListenerDisabled
if this.isHierarchical



newDictElementName = this.InterfaceDictElement.Name;
destinationTabId = this.getSpreadsheetTabId(  );
this.Studio.forceUpdateTabToNodesMap( this, newDictElementName, oldDictElementName, destinationTabId );
end 
this.Studio.refreshPIDialog(  );
this.Studio.refreshSourceObj(  );
end 
end 
end 
end 

methods ( Static, Access = private )
function boolPropVal = convertCharToBool( charPropVal )


switch charPropVal
case '0'
boolPropVal = false;
case '1'
boolPropVal = true;
otherwise 
assert( false, 'Unexpected input' )
end 
end 

function charPropVal = convertBoolToChar( boolPropVal )


if boolPropVal
charPropVal = '1';
else 
charPropVal = '0';
end 
end 

function allDataTypes = addDataTypeExpressionToDataTypeList( allDataTypes )

if ~any( startsWith( allDataTypes, '<data type expression>' ) )


refreshIdx = find( startsWith( allDataTypes,  ...
DAStudio.message( 'Simulink:DataType:RefreshDataTypeInWorkspace' ) ) );
allDataTypes = [ allDataTypes( 1:refreshIdx - 1 ); ...
{ '<data type expression>' };allDataTypes( refreshIdx:end  ) ];
end 
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp6uCeWT.p.
% Please follow local copyright laws when handling this file.

