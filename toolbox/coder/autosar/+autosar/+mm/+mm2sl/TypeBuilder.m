classdef TypeBuilder < autosar.mm.util.TypeVisitor






properties ( Access = private )
context;
numContext;
msgStream;
App2ImpTypeQNameMap;
App2DataTypeMapObjMap;
App2DataTypeMapSetObjMap;
Mdg2ImpTypeQNameMap;
EnumQName2LiteralPrefixMap;
SysConstsValueMap;
PostBuildCritValueMap;
ChangeLogger;
M3iComp;
SLEnumBuilder;
ReplaceExistingTypeDefinition;
UseValueTypes;
ValueTypeCompatibilityChecker autosar.mm.mm2sl.utils.ValueTypeSupportHelper
end 

properties ( Hidden = true, GetAccess = public, SetAccess = private )
m3iQName2SLTypeInfoMap;
ModelWorkSpace;
SharedWorkSpace;
end 

properties ( Hidden = true, GetAccess = public, SetAccess = public )
keepSLObj;
errorOutForAnonStructType;
end 

methods ( Access = public, Hidden )
function setModelWorkSpace( self, modelWorkSpace )
self.ModelWorkSpace = modelWorkSpace;
end 
end 

methods 



function self = TypeBuilder( m3iModel, keepSLObj, sharedWorkSpace, changeLogger, sysConstsValueMap, pbCritsValueMap, namedargs )
R36
m3iModel
keepSLObj
sharedWorkSpace
changeLogger
sysConstsValueMap
pbCritsValueMap









namedargs.ReplaceExistingTypeDefinition = true
namedargs.UseValueTypes = false
end 


self = self@autosar.mm.util.TypeVisitor( m3iModel );

assert( strcmp( sharedWorkSpace, 'base' ) ||  ...
isa( sharedWorkSpace, 'Simulink.dd.Connection' ),  ...
'Unexpected workspace type' );

self.keepSLObj = keepSLObj;
self.SharedWorkSpace = sharedWorkSpace;
self.ChangeLogger = changeLogger;


self.errorOutForAnonStructType = true;
self.UseValueTypes = namedargs.UseValueTypes;



self.numContext = 0;
self.context = repmat( self.newContext(  ), 1, 20 );
self.nextContext(  );



self.m3iQName2SLTypeInfoMap = autosar.mm.util.Map(  ...
'InitCapacity', 10,  ...
'KeyType', 'char' );


self.msgStream = autosar.mm.util.MessageStreamHandler.instance(  );
self.App2ImpTypeQNameMap = containers.Map(  );
self.Mdg2ImpTypeQNameMap = containers.Map(  );
self.App2DataTypeMapObjMap = containers.Map(  );
self.App2DataTypeMapSetObjMap = containers.Map(  );
self.EnumQName2LiteralPrefixMap = containers.Map(  );
self.SysConstsValueMap = sysConstsValueMap;
self.PostBuildCritValueMap = pbCritsValueMap;
self.ReplaceExistingTypeDefinition = namedargs.ReplaceExistingTypeDefinition;
if strcmp( sharedWorkSpace, 'base' )
self.SLEnumBuilder = autosar.simulink.enum.createEnumBuilder(  );
else 
self.SLEnumBuilder = autosar.simulink.enum.createEnumBuilder( sharedWorkSpace.filespec );
end 
end 




function delete( self )
self.context = [  ];
end 

function sysConstsValueMap = getSysConstsValueMap( self )
sysConstsValueMap = self.SysConstsValueMap;
end 

function postBuildCritsValueMap = getPostBuildCritsValueMap( self )
postBuildCritsValueMap = self.PostBuildCritValueMap;
end 

function buildDataTypeMappingsReferencedByComp( self, m3iComp )


assert( isa( m3iComp, 'Simulink.metamodel.arplatform.component.Component' ),  ...
'Invalid m3iComp' );
self.M3iComp = m3iComp;

dataTypeMapSet = M3I.SequenceOfClassObject.make( m3iComp.rootModel );
autosar.mm.arxml.Exporter.findByBaseType(  ...
dataTypeMapSet,  ...
m3iComp.rootModel,  ...
'Simulink.metamodel.arplatform.common.DataTypeMappingSet' );
self.buildDataTypeMaps( dataTypeMapSet );
self.ValueTypeCompatibilityChecker = autosar.mm.mm2sl.utils.ValueTypeSupportHelper( self.m3iModel,  ...
self.App2DataTypeMapObjMap, self.UseValueTypes );

componentHasBehavior = isa( m3iComp, 'Simulink.metamodel.arplatform.component.AtomicComponent' ) &&  ...
m3iComp.Behavior.isvalid(  );

if componentHasBehavior
self.buildIncludedDataTypeSets( m3iComp.Behavior.IncludedDataTypeSets );
end 
end 

function buildAllDataTypeMappings( self, m3iModel )

dataTypeMapSet = M3I.SequenceOfClassObject.make( m3iModel );
autosar.mm.arxml.Exporter.findByBaseType(  ...
dataTypeMapSet,  ...
m3iModel,  ...
'Simulink.metamodel.arplatform.common.DataTypeMappingSet' );
self.buildDataTypeMaps( dataTypeMapSet );
end 


function slTypeInfo = getDefaultTypeInfo( self )
slTypeInfo = self.newContext(  );
slTypeInfo.name = 'double';
end 





function [ slTypeInfo, alreadyExists ] = buildType( self, m3iType )
if ~isa( m3iType, 'Simulink.metamodel.foundation.Type' )
assert( false, 'Invalid argument: expect a Simulink.metamodel.foundation.Type' );
end 
[ slTypeInfo, alreadyExists ] = self.createType( m3iType );
if ~isa( m3iType, 'Simulink.metamodel.types.Enumeration' )
slTypeInfo = rmfield( slTypeInfo, { 'elems', 'm3iObj' } );
slTypeInfo = rmfield( slTypeInfo, { 'str' } );
end 

if self.canDropDims( m3iType )
slTypeInfo = rmfield( slTypeInfo, { 'dims' } );
end 

if m3iType.InvalidValue.isvalid(  )
m3iType.InvalidValue.Type = m3iType;
end 
end 

function designData = getSLDesignData( this, m3iType )




designData = autosar.mm.mm2sl.TypeBuilder.getDefaultSLDesignData(  );
if ~m3iType.isvalid(  )
return ;
end 


slTypeInfo = this.buildType( m3iType );
assert( ~isempty( slTypeInfo ), 'Failed to find slTypeInfo for data type %s', m3iType.Name );


designData.DataTypeStr = this.getSLBlockDataTypeStr( m3iType );

if isa( slTypeInfo.slObj, 'Simulink.ValueType' )


return ;
end 


if isfield( slTypeInfo, 'dims' )
designData.Dimensions = slTypeInfo.dims.toString(  );
end 


if m3iType.isvalid(  ) && m3iType.IsApplication
if ~isempty( slTypeInfo.minVal )
designData.Min = Simulink.metamodel.arplatform.getRealStringCompact( slTypeInfo.minVal );
end 

if ~isempty( slTypeInfo.maxVal )
designData.Max = Simulink.metamodel.arplatform.getRealStringCompact( slTypeInfo.maxVal );
end 
end 
end 









function objNames = createAll( self, ws )

if nargin < 2
ws = 'base';
end 


keys = self.m3iQName2SLTypeInfoMap.getKeys(  );
objNames = {  };

toDD = false;
transactionAlreadyExists = false;

if isa( ws, 'Simulink.dd.Connection' )

try 
ws.beginTransaction(  );
catch ME
if strcmp( ME.identifier, 'SLDD:sldd:TransactionInProgress' )

transactionAlreadyExists = true;
else 
rethrow( ME );
end 
end 
toDD = true;
end 

for ii = 1:numel( keys )
slTypeInfo = self.m3iQName2SLTypeInfoMap( keys{ ii } );
if slTypeInfo.isSerialized
continue 
end 

if ~slTypeInfo.willBeAssigned
continue 
end 

assert( ~isempty( slTypeInfo.m3iObj ) && ( strcmp( slTypeInfo.m3iObj, 'NOT_NEEDED' ) || slTypeInfo.m3iObj.isvalid(  ) ), 'Type %s cannot be found', keys{ ii } );

switch class( slTypeInfo.m3iObj )
case { 'Simulink.metamodel.types.Enumeration', 'Simulink.metamodel.arplatform.common.ModeDeclarationGroup' }

case 'Simulink.metamodel.types.Structure'


if ~slTypeInfo.hasAnonStructName
objNames{ end  + 1 } = slTypeInfo.name;%#ok<AGROW>
assignin( ws, slTypeInfo.name, slTypeInfo.slObj );
end 

case 'Simulink.metamodel.types.Matrix'




if isa( slTypeInfo.slObj, 'Simulink.ValueType' )
objNames{ end  + 1 } = slTypeInfo.name;%#ok<AGROW>
assignin( ws, slTypeInfo.name, slTypeInfo.slObj );
end 

otherwise 
if ~self.keepSLObj || slTypeInfo.isBuiltIn || slTypeInfo.isAxisData
continue 
end 
objNames{ end  + 1 } = slTypeInfo.name;%#ok<AGROW>
assignin( ws, slTypeInfo.name, slTypeInfo.slObj );
end 


slTypeInfo.isSerialized = true;
self.m3iQName2SLTypeInfoMap( keys{ ii } ) = slTypeInfo;
end 

if toDD
ws.commitTransaction;
if ( transactionAlreadyExists )


ws.beginTransaction;
end 
end 
end 





function slStr = getSLBlockDataTypeStr( self, m3iType )

slStr = m3iType.Name;
switch class( m3iType )
case 'Simulink.metamodel.types.Enumeration'
slStr = [ 'Enum: ', slStr ];

case 'Simulink.metamodel.types.Structure'
slTypeInfo = self.buildType( m3iType );




if slTypeInfo.hasAnonStructName && self.errorOutForAnonStructType
self.msgStream.createError( 'RTW:autosar:anonymousStructTypeNotSupportedForImport', slTypeInfo.name );
end 
slStr = [ 'Bus: ', slStr ];

case 'Simulink.metamodel.types.Matrix'
slTypeInfo = self.buildType( m3iType );
if self.UseValueTypes && isa( slTypeInfo.slObj, 'Simulink.ValueType' )


slStr = sprintf( 'ValueType: %s', slTypeInfo.name );
else 
if m3iType.Reference.isvalid(  )
slStr = self.getSLBlockDataTypeStr( m3iType.Reference.BaseType );
else 
slStr = self.getSLBlockDataTypeStr( m3iType.BaseType );
end 
end 
case 'Simulink.metamodel.types.String'
slStr = self.getBuiltInTypeStr( m3iType );
case 'Simulink.metamodel.types.LookupTableType'
if m3iType.ValueAxisDataType.isvalid(  )
slTypeInfo = self.buildType( m3iType.ValueAxisDataType );
slStr = slTypeInfo.name;
else 
slStr = self.getLookupTableBaseTypeStr( m3iType.BaseType );
end 
case 'Simulink.metamodel.types.SharedAxisType'
if m3iType.ValueAxisDataType.isvalid(  )
slTypeInfo = self.buildType( m3iType.ValueAxisDataType );
slStr = slTypeInfo.name;
else 
slStr = self.getAxisBaseTypeStr( m3iType.Axis );
end 
case 'Simulink.metamodel.types.Axis'
slStr = self.getAxisBaseTypeStr( m3iType );
otherwise 
slTypeInfo = self.buildType( m3iType );
if slTypeInfo.isBuiltIn
slStr = self.getBuiltInTypeStr( m3iType );
elseif isa( slTypeInfo.slObj, 'Simulink.ValueType' )
slStr = sprintf( 'ValueType: %s', slTypeInfo.name );
elseif ~slTypeInfo.isAxisData && self.keepSLObj
slStr = slTypeInfo.name;
else 
if isa( slTypeInfo.slObj, 'Simulink.NumericType' )
fmt = sprintf( '%%.%dg', slTypeInfo.slObj.WordLength );
slStr = sprintf( [ 'fixdt(%d, %d, ', fmt, ', ', fmt, ')' ],  ...
slTypeInfo.slObj.SignednessBool,  ...
slTypeInfo.slObj.WordLength,  ...
slTypeInfo.slObj.Slope,  ...
slTypeInfo.slObj.Bias );
else 
assert( isa( slTypeInfo.slObj, 'Simulink.AliasType' ),  ...
'autosar:mm:mm2sl:TypeBuilder:unexpectedType', 'Unexpected type' );
slStr = slTypeInfo.slObj.BaseType;
end 
end 
end 
end 






function createEnumsFile( self, destFile )
self.SLEnumBuilder.createEnumsFile( destFile );
end 




function buildModeDeclarationGroup( self, m3iMdg )


hasImpType = self.Mdg2ImpTypeQNameMap.isKey( m3iMdg.qualifiedName );
if hasImpType
impTypeQName = self.Mdg2ImpTypeQNameMap( m3iMdg.qualifiedName );
m3iSeq = autosar.mm.Model.findObjectByName( self.m3iModel, impTypeQName );
assert( m3iSeq.size(  ) > 0, 'Sequence is empty' );
m3iImpType = m3iSeq.at( 1 );
else 
m3iImpType = [  ];
end 

matlabStorageType = autosar.mm.util.getStorageTypeForEnumOrMdg(  ...
m3iMdg, m3iImpType );

enumLiteralNames = cell( 1, m3iMdg.Mode.size(  ) );
enumLiteralValues = zeros( 1, m3iMdg.Mode.size(  ) );
explicitOrder = false;
for ii = 1:m3iMdg.Mode.size(  )
enumLiteralNames{ ii } = m3iMdg.Mode.at( ii ).Name;

if ~isempty( m3iMdg.Mode.at( ii ).Value )
enumLiteralValues( ii ) = m3iMdg.Mode.at( ii ).Value;
explicitOrder = true;
end 
end 


enumName = m3iMdg.Name;
[ enumLiteralNames, addClassNameToEnumNames ] =  ...
autosar.mm.util.removeEnumClassNamePrefix( [ enumName, '_' ], enumLiteralNames );


initModeName = m3iMdg.InitialMode.Name;
if ( addClassNameToEnumNames )
initModeName = autosar.mm.util.removeEnumClassNamePrefix( [ enumName, '_' ], initModeName );
end 



if ~explicitOrder
enumLiteralNamesSorted = sort( enumLiteralNames );
enumLiteralValues = cellfun( @( x )find( strcmp( enumLiteralNamesSorted, x ) ),  ...
enumLiteralNames, 'UniformOutput', true );
enumLiteralValues = enumLiteralValues - 1;
end 


enumDesc = autosar.mm.util.DescriptionHelper.getSLDescFromM3IDesc( m3iMdg.desc );

self.defineEnumeration( enumName,  ...
enumLiteralValues, enumLiteralNames, initModeName,  ...
matlabStorageType, addClassNameToEnumNames, enumDesc );

qName = autosar.api.Utils.getQualifiedName( m3iMdg );
slTypeInfo = self.getContext(  );
slTypeInfo.m3iObj = m3iMdg;
slTypeInfo.name = enumName;
if isa( self.SharedWorkSpace, 'Simulink.dd.Connection' )


slTypeInfo.willBeAssigned = true;
end 

self.m3iQName2SLTypeInfoMap( qName ) = slTypeInfo;
end 






function typeName = buildStdReturnType( self )

typeName = 'Std_ReturnType';

if self.m3iQName2SLTypeInfoMap.isKey( typeName )
return 
end 


self.nextContext(  );


self.acceptStdReturnType(  );



slTypeInfo = self.getContext(  );
if ~isa( slTypeInfo.slObj, 'Simulink.ValueType' )
slTypeInfo.slObj.HeaderFile = self.getHeaderFile( typeName );
end 
slTypeInfo.m3iObj = 'NOT_NEEDED';


self.m3iQName2SLTypeInfoMap( typeName ) = slTypeInfo;


self.prevContext(  );
end 

function implDataType = getImplementationDataType( self, appDataType )
implDataType = '';
if self.App2ImpTypeQNameMap.isKey( appDataType )
implDataType = self.App2ImpTypeQNameMap( appDataType );
end 
end 





function needsLongLong = needsLongLong( self )
needsLongLong = false;

keys = self.m3iQName2SLTypeInfoMap.getKeys(  );

for ii = 1:numel( keys )

slTypeInfo = self.m3iQName2SLTypeInfoMap( keys{ ii } );
m3iType = slTypeInfo.m3iObj;

if ~strcmp( m3iType, 'NOT_NEEDED' )
if m3iType.MetaClass == Simulink.metamodel.types.Integer.MetaClass ||  ...
m3iType.MetaClass == Simulink.metamodel.types.FixedPoint.MetaClass ||  ...
m3iType.MetaClass == Simulink.metamodel.types.Enumeration.MetaClass
if m3iType.Length.value > 32
needsLongLong = true;
break 
end 
end 
end 
end 
end 

function setM3iComp( self, m3iComp )
self.M3iComp = m3iComp;
end 
end 

methods ( Access = 'protected' )


function nextContext( self )
numCtx = self.numContext + 1;
self.context( numCtx ) = self.newContext(  );
self.numContext = numCtx;
end 



function prevContext( self )
self.numContext = self.numContext - 1;
end 



function ctx = getContext( self )
ctx = self.context( self.numContext );
end 



function ctx = newContext( ~ )
ctx = struct(  );
ctx.dims = autosar.mm.util.Dimensions( [ 1, 1 ] );
ctx.elems = [  ];
ctx.str = '';
ctx.name = '';
ctx.slObj = [  ];
ctx.minVal = [  ];
ctx.maxVal = [  ];
ctx.m3iObj = [  ];
ctx.isSerialized = false;
ctx.hasAnonStructName = false;
ctx.willBeAssigned = false;
ctx.isBuiltIn = false;
ctx.isAxisData = false;
ctx.axisIndex =  - 1;
ctx.category = '';
end 



function [ slTypeInfo, alreadyExists ] = createType( self, m3iType )
qName = autosar.api.Utils.getQualifiedName( m3iType );

isInPackage = isa( m3iType.containerM3I, 'Simulink.metamodel.arplatform.common.Package' );
isPrimitiveType = isa( m3iType, 'Simulink.metamodel.types.PrimitiveType' );
if m3iType.IsApplication && isInPackage && isPrimitiveType
self.verifyAppTypeHasMapping( m3iType );
end 

alreadyExists = false;
if isempty( m3iType.Name ) || isempty( qName )
assert( false, DAStudio.message( 'RTW:autosar:mmUnnamedObject', 'Type' ) );
end 

if self.m3iQName2SLTypeInfoMap.isKey( qName )
slTypeInfo = self.m3iQName2SLTypeInfoMap( qName );
alreadyExists = true;
return 
end 


self.nextContext(  );


self.apply( m3iType );



slTypeInfo = self.getContext(  );
if ~isa( autosar.mm.mm2sl.TypeBuilder.getUnderlyingType( m3iType ), 'Simulink.metamodel.types.Enumeration' ) ...
 && ~isa( slTypeInfo.slObj, 'Simulink.ValueType' )
slTypeInfo.slObj.HeaderFile = self.getHeaderFile( m3iType.Name );
end 
slTypeInfo.m3iObj = m3iType;


self.m3iQName2SLTypeInfoMap( qName ) = slTypeInfo;



if isa( m3iType, 'Simulink.metamodel.types.Structure' ) && strncmp( m3iType.Name, 'struct_', 7 )



slBusHelper = autosar.mm.mm2sl.SLBusHelper( self, m3iType );
if slBusHelper.doesBusHaveAnonymousStructName( self.SharedWorkSpace )

slTypeInfo.hasAnonStructName = true;
self.m3iQName2SLTypeInfoMap( qName ) = slTypeInfo;
end 


slBusHelper.delete(  );
end 


self.prevContext(  );
end 



function ret = acceptEnumeration( self, type, finish )
ret = [  ];
currCtx = self.numContext;
if finish






if self.ReplaceExistingTypeDefinition




actNames = { self.context( currCtx ).elems( : ).name };
actVal = double( [ self.context( currCtx ).elems( : ).value ] );


hasLiteralPrefix = self.EnumQName2LiteralPrefixMap.isKey( type.qualifiedName );
if hasLiteralPrefix
literalPrefix = self.EnumQName2LiteralPrefixMap( type.qualifiedName );
actNames = strcat( literalPrefix, actNames );
end 


[ actNames, addClassNameToEnumNames ] = autosar.mm.util.removeEnumClassNamePrefix( [ type.Name, '_' ], actNames );

defaultValue = [  ];
if ~isempty( type.GroundValue )
groundValIndex = actVal == type.GroundValue;
defaultValue = actNames{ groundValIndex };
end 


isAppType = self.App2ImpTypeQNameMap.isKey( type.qualifiedName );
if isAppType
impTypeQName = self.App2ImpTypeQNameMap( type.qualifiedName );
m3iSeq = autosar.mm.Model.findObjectByName( self.m3iModel, impTypeQName );
assert( m3iSeq.size(  ) > 0, 'Sequence is empty' );
m3iImpType = m3iSeq.at( 1 );
else 
m3iImpType = [  ];
end 


if isa( m3iImpType, 'Simulink.metamodel.types.Enumeration' )
if ~isempty( type.CompuMethod ) && ~isempty( m3iImpType.CompuMethod )
if ~strcmp( type.CompuMethod.Name, m3iImpType.CompuMethod.Name )
appTypeEnumLiteralNames = self.getEnumLiteralNames( type );
impTypeEnumLiteralNames = self.getEnumLiteralNames( m3iImpType );
inconsistentLiterals = ~isequal( appTypeEnumLiteralNames, impTypeEnumLiteralNames );
if inconsistentLiterals
DAStudio.error( 'autosarstandard:importer:EnumLiteralConflict',  ...
type.CompuMethod.Name, m3iImpType.CompuMethod.Name );
end 
end 
end 
end 

matlabStorageType = autosar.mm.util.getStorageTypeForEnumOrMdg(  ...
type, m3iImpType );

[ ~, enumDesc ] = autosar.mm.util.DescriptionHelper.getSLDescFromM3IType( type );

self.defineEnumeration( type.Name,  ...
actVal, actNames, defaultValue, matlabStorageType,  ...
addClassNameToEnumNames, enumDesc );
self.context( currCtx ).elems = [  ];
autosar.mm.util.setCompuMethodSlDataType( self.m3iModel, type.CompuMethod, { type.Name }, true );

if isa( self.SharedWorkSpace, 'Simulink.dd.Connection' )


self.context( currCtx ).willBeAssigned = true;
end 
end 

self.context( currCtx ).name = type.Name;
end 
end 



function ret = acceptEnumerationLiteral( self, type, literal, value )%#ok<INUSD,INUSL>
ret = [  ];

currCtx = self.numContext;
lastValue =  - 1;
if ~isempty( self.context( currCtx ).elems )
lastValue = self.context( currCtx ).elems( end  ).value;
end 

try 
if literal.hasValidValue
val = literal.Value;
else 



val = lastValue + 1;
end 
catch me %#ok<NASGU>



val = lastValue + 1;
end 
lit = struct( 'name', literal.Name, 'value', val );
self.context( currCtx ).elems = [ self.context( currCtx ).elems;lit ];

end 



function ret = acceptStructure( self, type, finish )
ret = [  ];
currCtx = self.numContext;
if finish
self.verifyNoVariableSizeArray( type );
if self.App2ImpTypeQNameMap.isKey( type.qualifiedName )


impTypeQName = self.App2ImpTypeQNameMap( type.qualifiedName );
m3iSeq = autosar.mm.Model.findObjectByName( self.m3iModel, impTypeQName );
assert( m3iSeq.size(  ) > 0, 'Sequence is empty' );
impType = m3iSeq.at( 1 );

if ~slfeature( 'AUTOSARImplicitMapping' )

if ~isa( impType, 'Simulink.metamodel.types.Structure' )
DAStudio.error( 'RTW:autosar:wrongRecordType',  ...
type.Name, impType.Name );
end 

if type.Elements.size(  ) ~= impType.Elements.size(  )
DAStudio.error( 'RTW:autosar:wrongRecordSize',  ...
type.Name, type.Elements.size(  ),  ...
impType.Name, impType.Elements.size(  ) );
end 

for ii = 1:type.Elements.size(  )
if ~strcmp( type.Elements.at( ii ).Name, impType.Elements.at( ii ).Name )
DAStudio.error( 'RTW:autosar:wrongRecordElementName',  ...
type.Name, type.Elements.at( ii ).Name,  ...
impType.Name, impType.Elements.at( ii ).Name );
end 
end 
end 

end 


if length( type.Name ) == 29 && strncmp( type.Name, 'struct_', 7 )

bus = Simulink.Bus;
isCreated = true;
else 
[ bus, isCreated ] = self.createOrUpdateType( type.Name, 'Simulink.Bus' );
end 
if isCreated || self.ReplaceExistingTypeDefinition
bus.Elements = [  ];
for ii = 1:numel( self.context( currCtx ).elems )
bus.Elements( ii ) = self.context( currCtx ).elems( ii );
end 


bus.Description = autosar.mm.mm2sl.TypeBuilder.getDescriptionForSlObj( type, bus );
end 

for ii = numel( self.context( currCtx ).elems ): - 1:1
self.context( currCtx ).elems( ii ) = [  ];
end 

self.context( currCtx ).willBeAssigned = self.getWillBeAssignedBool( isCreated, bus, type.Name );
self.context( currCtx ).elems = [  ];
self.context( currCtx ).slObj = bus;
self.context( currCtx ).name = type.Name;
end 
self.context( currCtx ).elems = [  ];
end 



function ret = acceptStructureField( self, ~, field )
ret = [  ];
slTypeInfo = self.createType( field.ReferencedType );

currCtx = self.numContext;
elem = Simulink.BusElement;
elem.Complexity = 'real';
elem.SamplingMode = 'Sample based';
elem.Name = field.Name;
elem.DataType = self.getSLBlockDataTypeStr( field.ReferencedType );
elem.Dimensions = double( slTypeInfo.dims.evaluated(  ) );
elem.Min = slTypeInfo.minVal;
elem.Max = slTypeInfo.maxVal;
elem.Description = autosar.mm.mm2sl.TypeBuilder.getDescriptionForSlObj( field, elem );
self.context( currCtx ).elems = [ self.context( currCtx ).elems;elem ];
end 



function ret = acceptMatrix( self, type, elemType )


ret = [  ];

self.verifyNoVariableSizeArray( type );

slTypeInfoBase = self.createType( elemType );

dims = self.getSLDimensions( type, self.SysConstsValueMap );
while isa( elemType, 'Simulink.metamodel.types.Matrix' )
eleDims = self.getSLDimensions( elemType, self.SysConstsValueMap );
dims.append( eleDims );
elemType = elemType.BaseType;
end 

currCtx = self.numContext;
if self.modelAsValueType( type )



[ isAxisData, axisIndex, category ] = self.isAxisDataType( type );
[ slType, isCreated ] = self.createOrUpdateType( type.Name, 'Simulink.ValueType', ~isAxisData );
[ ~, typeName ] = self.createM3iSlDataType( elemType );
slType.DataType = typeName;
slType.Dimensions = dims.toString(  );
if isCreated || self.ReplaceExistingTypeDefinition
slType.Description = autosar.mm.mm2sl.TypeBuilder.getDescriptionForSlObj( type, slType );
end 
self.context( currCtx ).slObj = slType;
self.context( currCtx ).willBeAssigned = self.getWillBeAssignedBool( isCreated, slType, type.Name );
self.context( currCtx ).name = type.Name;
self.context( currCtx ).isAxisData = isAxisData;
self.context( currCtx ).axisIndex = axisIndex;
self.context( currCtx ).category = category;
self.context( currCtx ).dims = dims;

if type.IsApplication
self.setAppTypeAttributes( currCtx, type );
end 
else 
self.context( currCtx ) = slTypeInfoBase;

self.context( currCtx ).dims = dims;
self.context( currCtx ).name = type.Name;
end 
end 

function ret = acceptLookupTableType( self, type, elemType )
ret = [  ];

slTypeInfo = self.createType( elemType );
[ slTypeInfo.isAxisData, slTypeInfo.axisIndex, slTypeInfo.category ] = self.isAxisDataType( type );
m3iAxesDims = M3I.SequenceOfString.make( type.rootModel );
axisCount = type.Axes.size(  );
for ii = 1:axisCount
index = autosar.mm.util.getLookupTableMemberSwappedIndex( axisCount, ii );
axis = type.Axes.at( index );
if axis.SharedAxis.isvalid(  )
m3iAxis = axis.SharedAxis.Axis;
else 
m3iAxis = axis;
end 
if m3iAxis.SymbolicDimensions.size(  ) > 0
for jj = 1:m3iAxis.SymbolicDimensions.size(  )
m3iAxesDims.append( m3iAxis.SymbolicDimensions.at( jj ) );
end 
else 
m3iAxesDims.append( num2str( m3iAxis.Dimensions ) );
end 
end 
currCtx = self.numContext;
self.context( currCtx ) = slTypeInfo;

self.context( currCtx ).dims = autosar.mm.util.Dimensions( m3iAxesDims, self.SysConstsValueMap );
self.context( currCtx ).name = elemType.Name;
end 



function ret = acceptSharedAxisType( self, type, elemType )
ret = [  ];

assert( ~isempty( type ), 'Missing type' );
assert( ~isempty( elemType ), 'Missing element type' );

slTypeInfo = self.createType( elemType );
[ slTypeInfo.isAxisData, slTypeInfo.axisIndex, slTypeInfo.category ] = self.isAxisDataType( type );
dims = self.getSLDimensions( type.Axis, self.SysConstsValueMap );
currCtx = self.numContext;
self.context( currCtx ).isAxisData = slTypeInfo.isAxisData;
self.context( currCtx ) = slTypeInfo;

self.context( currCtx ).dims = dims;
self.context( currCtx ).name = elemType.Name;
end 



function ret = acceptInteger( self, type )
ret = [  ];

if isempty( type.minValue ) || isempty( type.maxValue )

self.m3iModel.beginTransaction(  );
dataSize = Simulink.metamodel.types.DataSize(  );
dataSize.value = 32;
type.Length = dataSize;
type.IsSigned = true;
[ type.minValue, type.maxValue ] = autosar.utils.Math.toLowerAndUpperLimit( type.IsSigned, double( type.Length.value ) );
self.m3iModel.commitTransaction(  );
end 

currCtx = self.numContext;
wordSize = double( type.Length.value );
if type.IsApplication || type.SwBaseType.isvalid(  )
if wordSize < 0 || wordSize > 64
self.msgStream.createError( 'autosarstandard:importer:baseTypeUnsupportedIntSize', { type.Name, int2str( wordSize ) } );
end 
else 
if wordSize < 0 || wordSize > 64
self.msgStream.createError( 'RTW:autosar:incorrectWordSize', { type.Name, int2str( wordSize ) } );
end 
end 

if ~ismember( wordSize, [ 8, 16, 32, 64 ] )
[ isAxisData, axisIndex, category ] = self.isAxisDataType( type );
[ slType, isCreated ] = self.createOrUpdateType( type.Name, 'Simulink.NumericType', ~isAxisData );

if isCreated || self.ReplaceExistingTypeDefinition
slType.IsAlias = true;
slType.DataTypeMode = 'Fixed-point: binary point scaling';
slType.SignednessBool = type.IsSigned;
slType.WordLength = wordSize;
slType.Description = autosar.mm.mm2sl.TypeBuilder.getDescriptionForSlObj( type, slType );
autosar.mm.util.setCompuMethodSlDataType( self.m3iModel, type.CompuMethod, { type.Name }, true );
end 
self.context( currCtx ).slObj = slType;
self.context( currCtx ).willBeAssigned = self.getWillBeAssignedBool( isCreated, slType, type.Name );
self.context( currCtx ).isAxisData = isAxisData;
self.context( currCtx ).axisIndex = axisIndex;
self.context( currCtx ).category = category;
self.context( currCtx ).name = type.Name;
else 
bname = '';
if type.IsSigned == false
bname = 'u';
end 
bname = sprintf( '%sint%d', bname, wordSize );
self.setIsBuiltIn( currCtx, type );
if ~self.context( currCtx ).isBuiltIn
[ isAxisData, axisIndex, category ] = self.isAxisDataType( type );
if self.modelAsValueType( type )
[ slType, isCreated ] = self.createOrUpdateType( type.Name, 'Simulink.ValueType', ~isAxisData );
[ ~, typeName ] = self.createM3iSlDataType( type );
slType.DataType = typeName;
else 
[ slType, isCreated ] = self.createOrUpdateType( type.Name, 'Simulink.AliasType', ~isAxisData );
slType.BaseType = bname;
end 
if isCreated || self.ReplaceExistingTypeDefinition
slType.Description = autosar.mm.mm2sl.TypeBuilder.getDescriptionForSlObj( type, slType );
autosar.mm.util.setCompuMethodSlDataType( self.m3iModel, type.CompuMethod, { type.Name }, true );
end 
self.context( currCtx ).slObj = slType;
self.context( currCtx ).willBeAssigned = self.getWillBeAssignedBool( isCreated, slType, type.Name );
self.context( currCtx ).name = type.Name;
self.context( currCtx ).isAxisData = isAxisData;
self.context( currCtx ).axisIndex = axisIndex;
self.context( currCtx ).category = category;
else 
self.context( currCtx ).name = bname;
end 
end 

if type.IsApplication
self.setAppTypeAttributes( currCtx, type );
end 
end 




function ret = acceptFixedPoint( self, type )
ret = [  ];

[ isAxisData, axisIndex, category ] = self.isAxisDataType( type );



[ slType, isCreated ] = self.createFixedPointNumericType( type, type.Name, isAxisData );

currCtx = self.numContext;
self.context( currCtx ).willBeAssigned = self.getWillBeAssignedBool( isCreated, slType, type.Name );
self.context( currCtx ).slObj = slType;
self.context( currCtx ).name = type.Name;
self.context( currCtx ).isAxisData = isAxisData;
self.context( currCtx ).axisIndex = axisIndex;
self.context( currCtx ).category = category;

if type.IsApplication
self.setAppTypeAttributes( currCtx, type );
end 

end 



function ret = acceptBoolean( self, type )
ret = [  ];
currCtx = self.numContext;

self.setIsBuiltIn( currCtx, type );
if ~self.context( currCtx ).isBuiltIn
[ isAxisData, ~, ~ ] = self.isAxisDataType( type );
if self.modelAsValueType( type )
[ slType, isCreated ] = self.createOrUpdateType( type.Name, 'Simulink.ValueType', ~isAxisData );
[ ~, typeName ] = self.createM3iSlDataType( type );
slType.DataType = typeName;
else 
[ slType, isCreated ] = self.createOrUpdateType( type.Name, 'Simulink.AliasType', ~isAxisData );
slType.BaseType = 'boolean';
end 
if isCreated || self.ReplaceExistingTypeDefinition
slType.Description = autosar.mm.mm2sl.TypeBuilder.getDescriptionForSlObj( type, slType );
self.context( currCtx ).slObj = slType;
autosar.mm.util.setCompuMethodSlDataType( self.m3iModel, type.CompuMethod, { type.Name }, true );
end 
self.context( currCtx ).slObj = slType;
self.context( currCtx ).willBeAssigned = self.getWillBeAssignedBool( isCreated, slType, type.Name );
self.context( currCtx ).isAxisData = isAxisData;
self.context( currCtx ).name = type.Name;
else 
self.context( currCtx ).name = 'boolean';
end 

if type.IsApplication
self.setAppTypeAttributes( currCtx, type );
end 
end 



function ret = acceptFloatingPoint( self, type )
ret = [  ];
bname = 'double';
if type.Kind == Simulink.metamodel.types.FloatingPointKind.IEEE_Single
bname = 'single';
end 
currCtx = self.numContext;
self.setIsBuiltIn( currCtx, type );
if ~self.context( currCtx ).isBuiltIn
[ isAxisData, axisIndex, category ] = self.isAxisDataType( type );
if self.modelAsValueType( type )
[ slType, isCreated ] = self.createOrUpdateType( type.Name, 'Simulink.ValueType', ~isAxisData );
[ ~, typeName ] = self.createM3iSlDataType( type );
slType.DataType = typeName;
else 
[ slType, isCreated ] = self.createOrUpdateType( type.Name, 'Simulink.AliasType', ~isAxisData );
slType.BaseType = bname;
end 
if isCreated || self.ReplaceExistingTypeDefinition
slType.Description = autosar.mm.mm2sl.TypeBuilder.getDescriptionForSlObj( type, slType );
autosar.mm.util.setCompuMethodSlDataType( self.m3iModel, type.CompuMethod, { type.Name }, true );
end 
self.context( currCtx ).slObj = slType;
self.context( currCtx ).willBeAssigned = self.getWillBeAssignedBool( isCreated, slType, type.Name );
self.context( currCtx ).name = type.Name;
self.context( currCtx ).isAxisData = isAxisData;
self.context( currCtx ).axisIndex = axisIndex;
self.context( currCtx ).category = category;
else 
self.context( currCtx ).name = bname;
end 

if type.IsApplication
self.setAppTypeAttributes( currCtx, type );
end 
end 



function ret = acceptVoidPointer( ~, m3iType )
ret = [  ];
swBaseType = m3iType.SwBaseType;



if isempty( swBaseType )
DAStudio.error( 'autosarstandard:importer:UnSupportedImplementationPointerType',  ...
autosar.api.Utils.getQualifiedName( m3iType ) );
end 
end 



function ret = acceptStdReturnType( self )
ret = [  ];
currCtx = self.numContext;

typeName = 'Std_ReturnType';

[ slType, isCreated ] = self.createOrUpdateType( typeName, 'Simulink.AliasType' );
if isCreated || self.ReplaceExistingTypeDefinition
slType.BaseType = 'uint8';
end 

self.context( currCtx ).slObj = slType;
self.context( currCtx ).willBeAssigned = self.getWillBeAssignedBool( isCreated, slType, typeName );
self.context( currCtx ).name = typeName;
end 



function ret = acceptString( self, type )
ret = [  ];



impTypeQName = self.App2ImpTypeQNameMap( type.qualifiedName );
m3iSeq = autosar.mm.Model.findObjectByName( self.m3iModel, impTypeQName );
assert( m3iSeq.size(  ) > 0, 'Sequence is empty' );
impType = m3iSeq.at( 1 );

errId = 'autosarstandard:common:IDTCategoryNotSupportedForString';
errMsg = DAStudio.message( errId, impType.Name, type.Name );
assert( isa( impType, 'Simulink.metamodel.types.Matrix' ), errId, errMsg );

currCtx = self.numContext;
self.context( currCtx ).name = type.Name;
end 
end 

methods ( Access = 'private' )
function useValueTypes = modelAsValueType( self, m3iType )
workSpace = self.SharedWorkSpace;
typeName = m3iType.Name;
typeExists = evalin( workSpace, [ 'exist(''', typeName, ''', ''var'')' ] ) == 1;
if typeExists
if ~Simulink.data.isSupportedEnumClass( typeName )

oldType = evalin( workSpace, typeName );
if ~isa( oldType, 'Simulink.ValueType' )
useValueTypes = false;
return ;
else 
useValueTypes = true;
return ;
end 
end 
end 
useValueTypes = self.UseValueTypes && self.ValueTypeCompatibilityChecker.canM3ITypeBeModeledAsValueType( m3iType );
end 

function m3iImpDataType = getM3iImplementationDataType( self, m3iType )
m3iImpDataType = [  ];
if self.App2DataTypeMapObjMap.isKey( m3iType.qualifiedName )
m3iImpDataType = self.App2DataTypeMapObjMap( m3iType.qualifiedName ).ImplementationType;
else 
assert( false, 'Application DataType not found in App2DataTypeMapObjMap' );
end 
end 

function [ slTypeInfo, typeName ] = createM3iSlDataType( self, m3iType )
if isa( m3iType, "Simulink.metamodel.types.FixedPoint" ) ||  ...
isa( m3iType, "Simulink.metamodel.types.Enumeration" )
slType = m3iType;
else 
slType = self.getM3iImplementationDataType( m3iType );
end 
slTypeInfo = self.createType( slType );


typeName = self.getSLBlockDataTypeStr( slType );
end 

function identifier = getNumericTypeIdentiferName( ~, objectName )
identifier = arxml.arxml_private ...
( 'p_create_aridentifier',  ...
sprintf( '%s_NumericType', objectName ), namelengthmax );
end 

function defineEnumeration( self,  ...
enumName, enumLiteralValues, enumLiteralNames, defaultValue,  ...
matlabStorageType, addClassNameToEnumNames, enumDesc )

headerFile = self.getHeaderFile( enumName );
dataScope = 'Auto';
self.SLEnumBuilder.addEnumeration( enumName,  ...
enumLiteralNames, enumLiteralValues,  ...
defaultValue,  ...
matlabStorageType, addClassNameToEnumNames,  ...
enumDesc, headerFile, dataScope );

end 

function buildDataTypeMaps( self, dataTypeMapSetSeq )
for mIdx = 1:dataTypeMapSetSeq.size(  )

dataTypeMapSet = dataTypeMapSetSeq.at( mIdx );
dtMapSeq = dataTypeMapSet.dataTypeMap;
for idx = 1:dtMapSeq.size(  )
dtMap = dtMapSeq.at( idx );
keyStr = dtMap.ApplicationType.qualifiedName;
valueStr = dtMap.ImplementationType.qualifiedName;
if self.App2DataTypeMapSetObjMap.isKey( keyStr )
val = self.App2DataTypeMapSetObjMap( keyStr );
self.verifyAppTypeMappingIsUnique( dtMap );
self.App2DataTypeMapSetObjMap( keyStr ) = [ val, dataTypeMapSet ];
else 
self.App2DataTypeMapSetObjMap( keyStr ) = dataTypeMapSet;
end 
self.App2DataTypeMapObjMap( keyStr ) = dtMap;
self.App2ImpTypeQNameMap( keyStr ) = valueStr;
end 


modeTypeMap = dataTypeMapSet.ModeRequestTypeMap;
for idx = 1:modeTypeMap.size(  )
dtMap = modeTypeMap.at( idx );
keyStr = dtMap.ModeGroupType.qualifiedName;
valueStr = dtMap.ImplementationType.qualifiedName;
self.Mdg2ImpTypeQNameMap( keyStr ) = valueStr;
end 
end 
end 

function buildIncludedDataTypeSets( self, m3iIncludedDataTypeSets )
for mIdx = 1:m3iIncludedDataTypeSets.size(  )
m3iIncludedDataTypeSet = m3iIncludedDataTypeSets.at( mIdx );
literalPrefix = m3iIncludedDataTypeSet.LiteralPrefix;
dtVec = m3iIncludedDataTypeSet.DataTypes;



if ~isempty( literalPrefix )
for idx = 1:dtVec.size(  )
dt = dtVec.at( idx );
if isa( dt, 'Simulink.metamodel.types.Enumeration' )
keyStr = dt.qualifiedName;
valueStr = literalPrefix;
self.EnumQName2LiteralPrefixMap( keyStr ) = valueStr;
end 
end 
end 


for idx = 1:dtVec.size(  )
dt = dtVec.at( idx );
self.buildType( dt );
end 
end 
end 

function verifyAppTypeMappingIsUnique( self, dtMap )
import autosar.mm.mm2sl.ImplicitMappingHelper



appTypeQName = dtMap.ApplicationType.qualifiedName;
impTypeQName = dtMap.ImplementationType.qualifiedName;
impTypeQNameInMap = self.App2ImpTypeQNameMap( appTypeQName );
conflictingDtMap = self.App2DataTypeMapObjMap( appTypeQName );
if ~strcmp( impTypeQName, impTypeQNameInMap )

appTypeQNameForError = autosar.api.Utils.getQualifiedName( dtMap.ApplicationType );
impTypeQNameForError = autosar.api.Utils.getQualifiedName( dtMap.ImplementationType );
impTypeInMapSeq = autosar.mm.Model.findObjectByName( self.m3iModel, impTypeQNameInMap );
impTypeQNameForErrorInMap = autosar.api.Utils.getQualifiedName( impTypeInMapSeq.at( 1 ) );


isDtMapImplicit = ImplicitMappingHelper.isDataTypeMapImplicit( dtMap );
isConflictingDtMapImplicit = ImplicitMappingHelper.isDataTypeMapImplicit( conflictingDtMap );


if ~isDtMapImplicit && ~isConflictingDtMapImplicit

DAStudio.error( 'autosarstandard:importer:dataTypeMapClash',  ...
appTypeQNameForError, impTypeQNameForError, impTypeQNameForErrorInMap );
else 

if slfeature( 'AUTOSARImplicitMapping' )
ImplicitMappingHelper.reportImplicitMappingClashError( self.m3iModel,  ...
self.App2ImpTypeQNameMap, appTypeQName, impTypeQName, impTypeQNameInMap,  ...
appTypeQNameForError, impTypeQNameForError, impTypeQNameForErrorInMap,  ...
isDtMapImplicit, isConflictingDtMapImplicit );
end 
end 
end 
end 

function [ slType, isCreated ] = createFixedPointNumericType( self, type, typeName, isAxisData )
[ slType, isCreated ] = self.createOrUpdateType( typeName, 'Simulink.NumericType', ~isAxisData );

wordSize = double( type.Length.value );
slope = double( type.slope );
if slope <= 0
self.msgStream.createError( 'RTW:autosar:incorrectImportedSlope', type.Name );
end 

if wordSize < 0 || wordSize > 64
self.msgStream.createError( 'RTW:autosar:incorrectWordSize', { type.Name, int2str( wordSize ) } );
end 
if isCreated || self.ReplaceExistingTypeDefinition
slType.IsAlias = true;
slType.DataTypeMode = 'Fixed-point: slope and bias scaling';
slType.SignednessBool = type.IsSigned;
slType.WordLength = wordSize;
slType.Bias = type.Bias;
slType.Slope = type.slope;
slType.Description = autosar.mm.mm2sl.TypeBuilder.getDescriptionForSlObj( type, slType );
autosar.mm.util.setCompuMethodSlDataType( self.m3iModel, type.CompuMethod, { type.Name }, true );
end 
end 

function [ newType, isCreated ] = createOrUpdateType( self, typeName, newClassName, updateLogger )


if nargin == 3
updateLogger = true;
end 
workSpace = self.SharedWorkSpace;
typeExists = evalin( workSpace, [ 'exist(''', typeName, ''', ''var'')' ] ) == 1;
if typeExists
if ~Simulink.data.isSupportedEnumClass( typeName )

oldType = evalin( workSpace, typeName );
oldTypeClass = class( oldType );
else 
oldType = '';
oldTypeClass = 'Enumeration';
end 
if isa( oldType, newClassName )
if isa( oldType, 'Simulink.ValueType' )

newType = oldType;
else 
newType = copy( oldType );
end 
isCreated = false;

else 
self.msgStream.createWarning( 'RTW:autosar:updateChangeClass', { typeName, oldTypeClass, newClassName } );
eval( [ 'newType = ', newClassName, ';' ] );%#ok<EVLEQ>
isCreated = true;
if updateLogger
self.ChangeLogger.logModification( 'WorkSpace', 'class', oldTypeClass, typeName, oldTypeClass, newClassName );
end 
end 
else 
eval( [ 'newType = ', newClassName, ';' ] );%#ok<EVLEQ>
isCreated = true;
if updateLogger
self.ChangeLogger.logAddition( 'WorkSpace', newClassName, typeName );
end 
end 
end 

function willBeAssigned = getWillBeAssignedBool( self, isCreated, typeObj, name )


if isCreated
willBeAssigned = true;
else 
wsObj = evalin( self.SharedWorkSpace, name );
areTypesEqual = autosar.mm.mm2sl.ObjectBuilder.compareAndLogChanges( name, typeObj, wsObj, self.ChangeLogger );
willBeAssigned = ~areTypesEqual;
end 
end 



function setAppTypeAttributes( self, currCtx, m3iType )
assert( m3iType.isvalid(  ) && m3iType.IsApplication,  ...
'm3iType is not a valid application type!' );


slTypeObj = self.context( currCtx ).slObj;
[ isSupported, minVal, maxVal ] =  ...
autosar.mm.util.MinMaxHelper.getMinMaxValuesFromM3iType( m3iType, slTypeObj );
if isSupported && isa( slTypeObj, 'Simulink.ValueType' )
self.context( currCtx ).slObj.Min = minVal;
self.context( currCtx ).slObj.Max = maxVal;
self.context( currCtx ).minVal = minVal;
self.context( currCtx ).maxVal = maxVal;
elseif isSupported
self.context( currCtx ).minVal = minVal;
self.context( currCtx ).maxVal = maxVal;
end 
end 

function setIsBuiltIn( self, currCtx, m3iType )

if ( ~self.App2ImpTypeQNameMap.isKey( m3iType.qualifiedName ) &&  ...
autosar.mm.util.BuiltInTypeMapper.isARBuiltIn( m3iType ) ) ||  ...
autosar.mm.util.BuiltInTypeMapper.isMATLABTypeName( m3iType.Name )
self.context( currCtx ).isBuiltIn = true;
end 
if isa( m3iType.containerM3I, 'Simulink.metamodel.types.StructElement' )
m3iStructElement = m3iType.containerM3I;
self.context( currCtx ).isBuiltIn = m3iStructElement.InlineType.isvalid(  );
end 
end 



function header = getHeaderFile( self, symbol )
if isa( self.M3iComp, 'Simulink.metamodel.arplatform.component.AdaptiveApplication' )
header = [ 'impl_type_', lower( symbol ), '.h' ];
else 
header = 'Rte_Type.h';
end 
end 





function verifyAppTypeHasMapping( self, m3iType )
assert( m3iType.IsApplication, 'Expected application data type' );

qName = autosar.api.Utils.getQualifiedName( m3iType );
if ~self.App2ImpTypeQNameMap.isKey( m3iType.qualifiedName )
DAStudio.error( 'RTW:autosar:noApplicationDataTypeMap', qName );
end 

if ~isa( self.M3iComp, 'Simulink.metamodel.arplatform.component.AtomicComponent' )

return ;
end 



m3iDtms = self.App2DataTypeMapSetObjMap( m3iType.qualifiedName );
m3iItem = [  ];
m3iRootModel = m3iType.rootModel;
m3iTypeMapping = self.M3iComp.Behavior.DataTypeMapping;
for ii = 1:numel( m3iDtms )
m3iDtm = m3iDtms( ii );
m3iItem = Simulink.metamodel.arplatform.ModelFinder.findNamedItemInSequence(  ...
m3iRootModel, m3iTypeMapping,  ...
m3iDtm.Name, 'Simulink.metamodel.arplatform.common.DataTypeMappingSet' );
if ~isempty( m3iItem ) && m3iItem.isvalid(  )
break ;
end 
end 

if isempty( m3iItem ) || ~m3iItem.isvalid(  )
DAStudio.error( 'RTW:autosar:noDataTypeMapRef', autosar.api.Utils.getQualifiedName( m3iDtm ), qName );
end 
end 

function slStr = getAxisBaseTypeStr( self, m3iAxisType )
if autosar.mm.mm2sl.TypeBuilder.hasValidInputVariableType( m3iAxisType )
slTypeInfo = self.buildType( m3iAxisType.InputVariableType );
slStr = slTypeInfo.name;
else 
baseTypeStr = self.getLookupTableBaseTypeStr( m3iAxisType.BaseType );
slStr = baseTypeStr;
end 
end 
end 

methods ( Static, Access = 'private' )
function verifyNoVariableSizeArray( type )
if ~isempty( type.DynamicArraySizeProfile )


vsaValues = { 'VSA_LINEAR', 'VSA_SQUARE', 'VSA_RECTANGULAR', 'VSA_FULLY_FLEXIBLE' };
if any( contains( vsaValues, type.DynamicArraySizeProfile ) )
DAStudio.error( 'autosarstandard:importer:vsaUsedInModel',  ...
autosar.api.Utils.getQualifiedName( type ), type.DynamicArraySizeProfile );
end 
end 
end 
end 

methods ( Static = true, Access = 'public' )





function m3iBottomType = getUnderlyingType( m3iType )
m3iBottomType = m3iType;
while isa( m3iBottomType, 'Simulink.metamodel.types.Matrix' )
if m3iBottomType.Reference.isvalid(  )
m3iBottomType = m3iBottomType.Reference;
end 
if ~m3iBottomType.BaseType.isvalid(  )
return 
end 
assert( m3iBottomType ~= m3iBottomType.BaseType, 'Did not expect a self referring array type %s', m3iBottomType.Name );
m3iBottomType = m3iBottomType.BaseType;
end 
if isa( m3iBottomType, 'Simulink.metamodel.types.LookupTableType' )
m3iBottomType = m3iType.BaseType;
elseif isa( m3iBottomType, 'Simulink.metamodel.types.SharedAxisType' )
m3iBottomType = m3iBottomType.Axis.BaseType;
end 
end 

function defaultDesignData = getDefaultSLDesignData(  )

defaultDesignData = struct(  ...
'DataTypeStr', 'double',  ...
'Dimensions', 1,  ...
'Min', [  ],  ...
'Max', [  ],  ...
'Unit', '',  ...
'Description', '' );
end 

function createNumericTypeFromCompuMethod( modelName, typeName, cmM3iObj, typeM3iObj )
if ~( isa( typeM3iObj, 'Simulink.metamodel.types.Integer' ) ...
 || isa( typeM3iObj, 'Simulink.metamodel.types.FixedPoint' ) ...
 || isa( typeM3iObj, 'Simulink.metamodel.types.FloatingPoint' ) ...
 || isa( typeM3iObj, 'Simulink.metamodel.types.Boolean' ) ...
 || isa( typeM3iObj, 'Simulink.metamodel.types.Enumeration' ) )
DAStudio.error( 'autosarstandard:api:validateDataTypeForNumericType', typeName );
end 
textTableBoolean = false;
[ bias, slope ] = autosar.mm.util.getScalingFromLinearCompuMethod( cmM3iObj );
[ ~, literalValues, result ] = autosar.mm.util.getLiteralsFromTextTableCompuMethods( cmM3iObj );
if result && numel( literalValues ) == 2 && ismember( 0, literalValues ) && ismember( 1, literalValues )
textTableBoolean = true;
end 
if textTableBoolean
dataTypeMode = 'Boolean';
else 
if slope == 1
if isa( typeM3iObj, 'Simulink.metamodel.types.FloatingPoint' )
if typeM3iObj.Kind == Simulink.metamodel.types.FloatingPointKind.IEEE_Single
dataTypeMode = 'Single';
else 
dataTypeMode = 'Double';
end 
elseif isa( typeM3iObj, 'Simulink.metamodel.types.Integer' ) ||  ...
isa( typeM3iObj, 'Simulink.metamodel.types.FixedPoint' )
dataTypeMode = 'Fixed-point: slope and bias scaling';
elseif isa( typeM3iObj, 'Simulink.metamodel.types.Boolean' )
dataTypeMode = 'Boolean';
else 
dataTypeMode = 'Double';
end 
else 
dataTypeMode = 'Fixed-point: slope and bias scaling';
if ~( isa( typeM3iObj, 'Simulink.metamodel.types.Integer' ) ||  ...
isa( typeM3iObj, 'Simulink.metamodel.types.FixedPoint' ) )
if typeM3iObj.IsApplication
typeStr = 'ApplicationDataType';
else 
typeStr = 'ImplementationDataType';
end 
DAStudio.error( 'autosarstandard:api:incompatibleDataType',  ...
typeStr, typeM3iObj.Name, cmM3iObj.Name, 'Simulink.NumericType', typeStr );
end 
end 
end 
if ~any( strcmp( dataTypeMode, { 'Single', 'Double', 'Boolean' } ) )
if typeM3iObj.IsSigned
signedness = 'Signed';
else 
signedness = 'Unsigned';
end 
wordLength = typeM3iObj.Length.value;
end 

if ~textTableBoolean
category = autosar.mm.util.compuMethodCategoryToString( cmM3iObj.Category );
if any( strcmp( category, { 'TextTable', 'RatFunc' } ) )
DAStudio.error( 'autosarstandard:common:compuMethodIncompatibleDefinition',  ...
'Simulink.NumericType', typeName, cmM3iObj.Name, category );
end 
end 
if ~existsInGlobalScope( modelName, typeName )
evalinGlobalScope( modelName, sprintf( '%s=%s;', typeName, 'Simulink.NumericType' ) );
end 
evalinGlobalScope( modelName, sprintf( '%s.DataTypeMode=%s;', typeName, [ '''', dataTypeMode, '''' ] ) );
if ~any( strcmp( dataTypeMode, { 'Single', 'Double', 'Boolean' } ) )
evalinGlobalScope( modelName, sprintf( '%s.Signedness=%s;', typeName, [ '''', signedness, '''' ] ) );
evalinGlobalScope( modelName, sprintf( '%s.WordLength=%g;', typeName, wordLength ) );
evalinGlobalScope( modelName, sprintf( '%s.Bias=%s;', typeName, rtw.connectivity.CodeInfoUtils.double2str( bias ) ) );
evalinGlobalScope( modelName, sprintf( '%s.Slope=%s;', typeName, rtw.connectivity.CodeInfoUtils.double2str( slope ) ) );
end 
evalinGlobalScope( modelName, sprintf( '%s.IsAlias=%g;', typeName, 1 ) );
evalinGlobalScope( modelName, sprintf( '%s.HeaderFile=%s;', typeName, '''Rte_Type.h''' ) );

autosar.mm.mm2sl.TypeBuilder.removePreviousAssoication( cmM3iObj, typeName );
autosar.mm.mm2sl.TypeBuilder.removePreviousAssoication( typeM3iObj, typeName );

autosar.mm.mm2sl.TypeBuilder.setSlDataType( cmM3iObj, typeM3iObj, typeName );
end 

function createEnumerationFromCompuMethod( enumName, cmM3iObj, typeM3iObj, ddFile, isAdaptive )
import autosar.mm.mm2sl.TypeBuilder;
import autosar.mm.util.ExternalToolInfoAdapter;

if typeM3iObj.IsApplication

impM3iObj = [  ];
[ ~, dtMap ] = autosar.mm.sl2mm.ApplicationTypeMapper.findDataTypeMappingSetForAppType( typeM3iObj );
if ~isempty( dtMap )
impM3iObj = dtMap.ImplementationType;
end 
assert( ~isempty( impM3iObj ),  ...
'Unable to find implementation type for application type %s',  ...
autosar.api.Utils.getQualifiedName( typeM3iObj ) );
else 
impM3iObj = typeM3iObj;
end 

storageType = autosar.mm.util.getStorageTypeFromImpDataType( 'enumeration', enumName, impM3iObj );
category = autosar.mm.util.compuMethodCategoryToString( cmM3iObj.Category );

if ~strcmp( category, 'TextTable' )
DAStudio.error( 'autosarstandard:common:compuMethodIncompatibleDefinition',  ...
'Simulink enumeration', enumName, cmM3iObj.Name, category );
end 

[ enumLiteralNames, enumLiteralValues, result ] = autosar.mm.util.getLiteralsFromTextTableCompuMethods( cmM3iObj );
if ~result
DAStudio.error( 'autosarstandard:common:compuMethodIncompleteDefinition',  ...
enumName, cmM3iObj.Name, category );
end 

defaultValue = enumLiteralNames{ 1 };
addClassName = false;
enumDesc = '';
if isAdaptive
headerFile = [ 'impl_type_', lower( enumName ), '.h' ];
else 
headerFile = 'Rte_Type.h';
end 
dataScope = 'Auto';

slEnumBuilder = autosar.simulink.enum.createEnumBuilder( ddFile );
slEnumBuilder.addEnumeration( enumName,  ...
enumLiteralNames, enumLiteralValues, defaultValue,  ...
storageType, addClassName, enumDesc,  ...
headerFile, dataScope );

if isempty( ddFile )
enumFileName = [ enumName, '_defineIntEnumTypes' ];
enumFileName = [ enumFileName, '.m' ];
slEnumBuilder.createEnumsFile( enumFileName );
end 

autosar.mm.mm2sl.TypeBuilder.removePreviousAssoication( cmM3iObj, enumName );
autosar.mm.mm2sl.TypeBuilder.removePreviousAssoication( typeM3iObj, enumName );

autosar.mm.mm2sl.TypeBuilder.setSlDataType( cmM3iObj, typeM3iObj, enumName );
end 

function [ enumsCreated ] = createEnumsForBitfieldCompuMethod( cmM3iObj, ddFile )
import autosar.mm.mm2sl.TypeBuilder;

narginchk( 1, 2 );

enumsCreated = {  };
category = cmM3iObj.Category.toString(  );


assert( strcmp( category, 'LinearAndTextTable' ) );

bfInfo = autosar.mm.util.ExternalToolInfoAdapter.get( cmM3iObj, 'CellOfBitfieldTables' );
if ~isempty( bfInfo )



slEnumBuilder = autosar.simulink.enum.createEnumBuilder( ddFile );







[ shortLabels, idx ] = unique( bfInfo.shortLabels, 'stable' );
maskVals = bfInfo.masks( idx );



storageType = 'uint16';
addClassNameToEnumNames = true;
description = [ 'Auto generated from BITFIELD_TEXTTABLE ', cmM3iObj.Name ];
maskEnumName = [ cmM3iObj.Name, '_Mask' ];
headerFile = '';
dataScope = 'Auto';

slEnumBuilder.addEnumeration( maskEnumName,  ...
shortLabels, maskVals,  ...
shortLabels{ 1 },  ...
storageType, addClassNameToEnumNames, description,  ...
headerFile, dataScope );


labelMap = containers.Map;
literals = {  };
values = [  ];
for ii = 1:numel( bfInfo.shortLabels )
label = char( bfInfo.shortLabels( ii ) );

if ~labelMap.isKey( label )
literals = bfInfo.names( ii );
values = bfInfo.values( ii );

labelMap( label ) =  ...
struct(  ...
'literals', { literals },  ...
'values', { values } );
else 
literals = [ literals, bfInfo.names( ii ) ];%#ok<AGROW>
values = [ values, bfInfo.values( ii ) ];%#ok<AGROW>
enumInfo = labelMap( label );
enumInfo.literals = literals;
enumInfo.values = values;
labelMap( label ) = enumInfo;
end 
end 


for shortLabelCell = labelMap.keys
shortLabel = char( shortLabelCell );
enumName = [ cmM3iObj.Name, '_', shortLabel ];
description = [ 'Auto generated from BITFIELD_TEXTTABLE ', cmM3iObj.Name ];

slEnumBuilder.addEnumeration( enumName,  ...
labelMap( shortLabel ).literals, labelMap( shortLabel ).values,  ...
labelMap( shortLabel ).literals{ 1 },  ...
storageType, addClassNameToEnumNames,  ...
description, headerFile, dataScope );
end 

if isempty( ddFile )
enumFileName = [ cmM3iObj.Name, '_defineIntEnumTypes' ];
enumFileName = [ enumFileName, '.m' ];
slEnumBuilder.createEnumsFile( enumFileName );
end 
end 
end 


function dimensions = getSLDimensions( type, syscvalues )




if isa( type, 'Simulink.metamodel.types.Matrix' ) ...
 || isa( type, 'Simulink.metamodel.types.PrimitiveType' ) ...
 || isa( type, 'Simulink.metamodel.types.Structure' )

if type.Reference.isvalid(  )
dimensions = autosar.mm.mm2sl.TypeBuilder.getSLDimensions( type.Reference, syscvalues );
return ;
end 
end 

if type.SymbolicDimensions.size == 0
dimensions = autosar.mm.util.Dimensions( type.Dimensions );
else 
dimensions = autosar.mm.util.Dimensions( type.SymbolicDimensions, syscvalues );
end 
end 


function isValid = hasValidInputVariableType( m3iAxisType )


isValid = false;
if ~isa( m3iAxisType, 'Simulink.metamodel.types.Axis' ) ||  ...
~m3iAxisType.InputVariableType.isvalid(  )
return ;
end 
m3iInputVariableType = m3iAxisType.InputVariableType;
m3iAxisBaseType = m3iAxisType.BaseType;

baseTypeStr = autosar.mm.mm2sl.TypeBuilder.getBuiltInTypeStr( m3iAxisBaseType );
inputVariableTypeStr = autosar.mm.mm2sl.TypeBuilder.getBuiltInTypeStr( m3iInputVariableType );

if strcmp( inputVariableTypeStr, baseTypeStr )
isValid = true;
elseif ( isa( m3iInputVariableType, 'Simulink.metamodel.types.FixedPoint' ) ||  ...
isa( m3iInputVariableType, 'Simulink.metamodel.types.Integer' ) ) &&  ...
( isa( m3iAxisBaseType, 'Simulink.metamodel.types.FixedPoint' ) ||  ...
isa( m3iAxisBaseType, 'Simulink.metamodel.types.Integer' ) )
isValid = ( m3iInputVariableType.IsSigned == m3iAxisBaseType.IsSigned &&  ...
m3iInputVariableType.Length == m3iAxisBaseType.Length );
end 
end 
end 

methods ( Static = true, Access = 'private' )

function dropDim = canDropDims( type )

dropDim = ( ~isa( type, 'Simulink.metamodel.types.Matrix' ) ...
 && ~isa( type, 'Simulink.metamodel.types.LookupTableType' ) ...
 && ~isa( type, 'Simulink.metamodel.types.SharedAxisType' ) );
end 

function [ isAxisData, axisIndex, category ] = isAxisDataType( m3iType )
if isa( m3iType, 'Simulink.metamodel.types.LookupTableType' )
isAxisData = true;
axisIndex = 0;
for ii = 1:m3iType.Axes.size(  )
if m3iType.Axes.at( ii ).SharedAxis.isvalid(  )
category = 'COM_AXIS';
elseif autosar.mm.mm2sl.utils.LookupTableUtils.isFixAxis( m3iType.Axes.at( ii ) )
category = 'FIX_AXIS';
else 
category = 'STD_AXIS';
end 
break ;
end 
elseif isa( m3iType, 'Simulink.metamodel.types.SharedAxisType' )
isAxisData = true;
axisIndex =  - 1;
category = 'COM_AXIS';
if m3iType.SharedFrom.size(  ) > 0
m3iLutAxis = m3iType.SharedFrom.at( 1 );
m3iLookupTableType = m3iLutAxis.containerM3I;
for ii = 1:m3iLookupTableType.Axes.size(  )
if m3iLookupTableType.Axes.at( ii ).SharedAxis == m3iType
axisIndex = ii;
break ;
end 
end 
end 
elseif isa( m3iType, 'Simulink.metamodel.types.Axis' )
[ isAxisData, axisIndex, category ] = autosar.mm.mm2sl.TypeBuilder.isAxisDataType( m3iType.containerM3I );
else 
if isa( m3iType.containerM3I, 'Simulink.metamodel.types.Axis' ) ...
 || isa( m3iType.containerM3I, 'Simulink.metamodel.types.LookupTableType' )
isAxisData = true;
else 
isAxisData = false;
end 
axisIndex =  - 1;
category = '';
end 
end 

function setSlDataType( cmM3iObj, typeM3iObj, typeName )
arRoot = cmM3iObj.rootModel;
types = autosar.mm.util.ExternalToolInfoAdapter.get( cmM3iObj, 'SlDataTypes' );
if isempty( types )
types = {  };
end 
if isempty( types ) || ~ismember( typeName, types )
types = [ types, typeName ];
autosar.mm.util.setCompuMethodSlDataType( arRoot, cmM3iObj, types, false );
end 
types = autosar.mm.util.ExternalToolInfoAdapter.get( typeM3iObj, 'SlDataTypes' );
if isempty( types )
types = {  };
end 
if isempty( types ) || ~ismember( typeName, types )
types = [ types, typeName ];
autosar.mm.util.setCompuMethodSlDataType( arRoot, typeM3iObj, types, false );
end 
end 

function removePreviousAssoication( m3iObject, slTypeName )
import autosar.mm.util.ExternalToolInfoAdapter;
arRoot = m3iObject.rootModel;
m3iSeq = Simulink.metamodel.arplatform.ModelFinder.findObjectByMetaClass( arRoot,  ...
m3iObject.MetaClass, true );
for ii = 1:m3iSeq.size(  )
if m3iSeq.at( ii ) == m3iObject
continue ;
end 
slTypeNamesAlreadySet = ExternalToolInfoAdapter.get( m3iSeq.at( ii ),  ...
autosar.ui.metamodel.PackageString.SlDataTypes );
if numel( slTypeNamesAlreadySet ) > 0
slTypeNamesNewSet = {  };
for jj = 1:numel( slTypeNamesAlreadySet )
if ~strcmp( slTypeNamesAlreadySet( jj ), slTypeName )
slTypeNamesNewSet = [ slTypeNamesNewSet, slTypeNamesAlreadySet( jj ) ];%#ok<AGROW>
end 
end 
autosar.mm.util.setCompuMethodSlDataType( arRoot, m3iSeq.at( ii ), slTypeNamesNewSet, false );
break ;
end 
end 
end 



function slDesc = getDescriptionForSlObj( m3iType, slObj )


[ descAvailable, desc ] = autosar.mm.util.DescriptionHelper.getSLDescFromM3IType( m3iType );
if ( descAvailable )
slDesc = desc;
else 
slDesc = slObj.Description;
end 
end 

function slStr = getBuiltInTypeStr( m3iType )

switch class( m3iType )
case 'Simulink.metamodel.types.FixedPoint'
slStr = sprintf( 'fixdt(%d,%d,%s,%s)', m3iType.IsSigned,  ...
m3iType.Length.value, rtw.connectivity.CodeInfoUtils.double2str( m3iType.slope ),  ...
rtw.connectivity.CodeInfoUtils.double2str( m3iType.Bias ) );
case 'Simulink.metamodel.types.Integer'
if m3iType.IsSigned
typeCast = 'int';
else 
typeCast = 'uint';
end 
slStr = [ typeCast, num2str( m3iType.Length.value ) ];
case 'Simulink.metamodel.types.FloatingPoint'
if m3iType.Kind == Simulink.metamodel.types.FloatingPointKind.IEEE_Single
slStr = 'single';
else 
slStr = 'double';
end 
case 'Simulink.metamodel.types.Boolean'
slStr = 'boolean';
case 'Simulink.metamodel.types.String'
slStr = 'string';
otherwise 
assert( false, 'Unsupported meta-class %s.', class( m3iType ) );
end 
end 

function slStr = getLookupTableBaseTypeStr( m3iBaseType )
if isa( m3iBaseType, 'Simulink.metamodel.types.Enumeration' )
slStr = [ 'Enum: ', m3iBaseType.Name ];
else 

slStr = autosar.mm.mm2sl.TypeBuilder.getBuiltInTypeStr( m3iBaseType );
end 
end 

function literalNames = getEnumLiteralNames( type )
ownedLiterals = type.OwnedLiteral;
literalNames = cell( size( ownedLiterals ), 1 );
for i = 1:size( ownedLiterals )
literalNames{ i } = ownedLiterals.at( i ).Name;
end 
end 
end 

end 






% Decoded using De-pcode utility v1.2 from file /tmp/tmphN5QG7.p.
% Please follow local copyright laws when handling this file.

