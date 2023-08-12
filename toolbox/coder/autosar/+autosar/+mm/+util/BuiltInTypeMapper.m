classdef BuiltInTypeMapper < handle






properties ( Constant, Access = private )


LegacyAR3StdTypeNames = { 'Boolean',  ...
'SInt8',  ...
'SInt16',  ...
'SInt32',  ...
'SInt64',  ...
'UInt8',  ...
'UInt16',  ...
'UInt32',  ...
'UInt64',  ...
'Float',  ...
'Double' };


AR4PlatformTypeNames = { 'boolean',  ...
'sint8',  ...
'sint16',  ...
'sint32',  ...
'sint64',  ...
'uint8',  ...
'uint16',  ...
'uint32',  ...
'uint64',  ...
'float32',  ...
'float64' };

AdaptivePlatformTypeNames = { 'bool',  ...
'int8_t',  ...
'int16_t',  ...
'int32_t',  ...
'int64_t',  ...
'uint8_t',  ...
'uint16_t',  ...
'uint32_t',  ...
'uint64_t',  ...
'float',  ...
'double' };



RTWSimulinkTypeNames = { 'boolean',  ...
'int8',  ...
'int16',  ...
'int32',  ...
'int64',  ...
'uint8',  ...
'uint16',  ...
'uint32',  ...
'uint64',  ...
'single',  ...
'double',  ...
'int',  ...
'uint' };
RTWBuiltInNames = { 'boolean_T',  ...
'int8_T',  ...
'int16_T',  ...
'int32_T',  ...
'int64_T',  ...
'uint8_T',  ...
'uint16_T',  ...
'uint32_T',  ...
'uint64_T',  ...
'real32_T',  ...
'real_T' };

ARTypeMap = containers.Map( [ autosar.mm.util.BuiltInTypeMapper.LegacyAR3StdTypeNames,  ...
autosar.mm.util.BuiltInTypeMapper.AR4PlatformTypeNames,  ...
autosar.mm.util.BuiltInTypeMapper.AdaptivePlatformTypeNames ],  ...
[ autosar.mm.util.BuiltInTypeMapper.RTWBuiltInNames,  ...
autosar.mm.util.BuiltInTypeMapper.RTWBuiltInNames,  ...
autosar.mm.util.BuiltInTypeMapper.RTWBuiltInNames ] );
RTW2Sl2CodegenTypeMap = containers.Map( autosar.mm.util.BuiltInTypeMapper.RTWSimulinkTypeNames,  ...
[ autosar.mm.util.BuiltInTypeMapper.RTWBuiltInNames,  ...
'int32_T',  ...
'uint32_T' ] );
RTW2PlatformTypeMap = containers.Map( autosar.mm.util.BuiltInTypeMapper.RTWBuiltInNames,  ...
autosar.mm.util.BuiltInTypeMapper.AR4PlatformTypeNames );

RTW2AdaptivePlatformTypeMap = containers.Map( autosar.mm.util.BuiltInTypeMapper.RTWBuiltInNames,  ...
autosar.mm.util.BuiltInTypeMapper.AdaptivePlatformTypeNames );
end 

methods ( Static, Access = public )




function isPlatformTypeName = isAUTOSARPlatformType( namedargs )
R36
namedargs.isAdaptive = false;
namedargs.implType;
end 

implType = namedargs.implType;
isAdaptive = namedargs.isAdaptive;


platformTypeNames = autosar.mm.util.BuiltInTypeMapper.getAUTOSARPlatformTypeNames( isAdaptive = isAdaptive );
isPlatformTypeName = ~isempty( implType ) && any( strcmpi( platformTypeNames, implType.Name ) );
end 




function platformTypeNames = getAUTOSARPlatformTypeNames( namedargs )
R36
namedargs.isAdaptive = false;
end 

isAdaptive = namedargs.isAdaptive;

if isAdaptive
platformTypeNames = autosar.mm.util.BuiltInTypeMapper.AdaptivePlatformTypeNames;
else 
platformTypeNames = autosar.mm.util.BuiltInTypeMapper.AR4PlatformTypeNames;
end 
end 




function platformTypeName = getAUTOSARPlatformTypeName( namedargs )
R36
namedargs.isAdaptive = false;
namedargs.rtwTypeName;
end 

rtwTypeName = namedargs.rtwTypeName;
isAdaptive = namedargs.isAdaptive;

if isAdaptive
platformTypeName = autosar.mm.util.BuiltInTypeMapper.getAdaptivePlatformTypeName( rtwTypeName );
else 
platformTypeName = autosar.mm.util.BuiltInTypeMapper.getAR4PlatformTypeName( rtwTypeName );
end 
end 




function arName = convertToAutosarBuiltInTypeAR3Name( typeName )
builtInTypesMap = containers.Map( autosar.mm.util.BuiltInTypeMapper.RTWBuiltInNames,  ...
autosar.mm.util.BuiltInTypeMapper.LegacyAR3StdTypeNames );

if builtInTypesMap.isKey( typeName )
arName = builtInTypesMap( typeName );
else 
arName = typeName;
end 
end 




function arName = convertToAutosarBuiltInTypeName( typeName )
builtInTypesMap = containers.Map( autosar.mm.util.BuiltInTypeMapper.RTWBuiltInNames,  ...
autosar.mm.util.BuiltInTypeMapper.AR4PlatformTypeNames );

if builtInTypesMap.isKey( typeName )
arName = builtInTypesMap( typeName );
else 
arName = typeName;
end 
end 





function isBuiltIn = isARBuiltIn( m3iType )
isBuiltIn = autosar.mm.util.BuiltInTypeMapper.ARTypeMap.isKey( m3iType.Name );


if isBuiltIn
switch ( m3iType.Name )
case { 'boolean', 'Boolean', 'bool' }
isBuiltIn = m3iType.MetaClass == Simulink.metamodel.types.Boolean.MetaClass;
case { 'sint8', 'sint16', 'sint32', 'sint64',  ...
'SInt8', 'SInt16', 'SInt32', 'SInt64',  ...
'uint8', 'uint16', 'uint32', 'uint64',  ...
'UInt8', 'UInt16', 'UInt32', 'UInt64',  ...
'int8_t', 'int16_t', 'int32_t', 'int64_t',  ...
'uint8_t', 'uint16_t', 'uint32_t', 'uint64_t' }
isBuiltIn = m3iType.MetaClass == Simulink.metamodel.types.Integer.MetaClass;
case { 'float32', 'float64', 'Float', 'Double', 'float', 'double' }
isBuiltIn = m3iType.MetaClass == Simulink.metamodel.types.FloatingPoint.MetaClass;
otherwise 
assert( false, 'Unsupported built-in type ''%s''.', m3iType.MetaClass.name );
end 
end 
end 




function isBuiltIn = isRTWBuiltIn( RTWTypeName, modelName )
isBuiltIn = ismember( RTWTypeName, autosar.mm.util.BuiltInTypeMapper.RTWBuiltInNames );
if isBuiltIn
return ;
end 
enableReplacement = strcmp( get_param( modelName, 'IsERTTarget' ), 'on' ) &&  ...
strcmp( get_param( modelName, 'EnableUserReplacementTypes' ), 'on' );
if enableReplacement

replacements = get_param( modelName, 'ReplacementTypes' );
fnames = fieldnames( replacements );

replacementIds = cellfun( @( x )( replacements.( x ) ), fnames, 'UniformOutput', false );

replacementIDToTypeNames = containers.Map( replacementIds, fnames );
isBuiltIn = replacementIDToTypeNames.isKey( RTWTypeName );
if isBuiltIn
RTWSlTypeName = replacementIDToTypeNames( RTWTypeName );
RTWCodegenType = autosar.mm.util.BuiltInTypeMapper.RTW2Sl2CodegenTypeMap( RTWSlTypeName );


autosar.mm.util.BuiltInTypeMapper.updateBuiltInInfoInMaps( RTWCodegenType, RTWTypeName );
end 
end 
end 



function updateBuiltInInfoInMaps( builtInTypeID, replacedTypeID )


platformMap = autosar.mm.util.BuiltInTypeMapper.RTW2PlatformTypeMap;
adaptivePlatformMap = autosar.mm.util.BuiltInTypeMapper.RTW2AdaptivePlatformTypeMap;
if platformMap.isKey( replacedTypeID ) || adaptivePlatformMap.isKey( replacedTypeID )
return ;
end 


assert( platformMap.isKey( builtInTypeID ), 'Incorrect Built-In type' );
assert( adaptivePlatformMap.isKey( builtInTypeID ), 'Incorrect Built-In type' );
platformType = platformMap( builtInTypeID );
AdaptivePlatformType = adaptivePlatformMap( builtInTypeID );

platformMap( replacedTypeID ) = platformType;
adaptivePlatformMap( replacedTypeID ) = AdaptivePlatformType;
end 



function isMLTypeName = isMATLABTypeName( typeName )

matlabNames = { 'boolean', 'int8', 'int16', 'int32',  ...
'uint8', 'uint16', 'uint32', 'single', 'double' };
isMLTypeName = ismember( typeName, matlabNames );
end 





function isEquivalent = isEquivalent( RTWTypeName, m3iType )
if autosar.mm.util.BuiltInTypeMapper.ARTypeMap.isKey( m3iType.Name )
isEquivalent = strcmp( autosar.mm.util.BuiltInTypeMapper.ARTypeMap( m3iType.Name ), RTWTypeName );
else 
isEquivalent = false;
end 
end 





function arName = getAR4PlatformTypeName( RTWTypeName )
if autosar.mm.util.BuiltInTypeMapper.RTW2PlatformTypeMap.isKey( RTWTypeName )
arName = autosar.mm.util.BuiltInTypeMapper.RTW2PlatformTypeMap( RTWTypeName );
else 
assert( false, 'Did not find builtin name' );
end 
end 





function arName = getAdaptivePlatformTypeName( RTWTypeName )
if autosar.mm.util.BuiltInTypeMapper.RTW2AdaptivePlatformTypeMap.isKey( RTWTypeName )
arName = autosar.mm.util.BuiltInTypeMapper.RTW2AdaptivePlatformTypeMap( RTWTypeName );
else 
assert( false, 'Did not find builtin name' );
end 
end 


function [ rtwTypeName, isRTWType ] = getRTWTypeName( arName )
isRTWType = autosar.mm.util.BuiltInTypeMapper.ARTypeMap.isKey( arName );
if isRTWType
rtwTypeName = autosar.mm.util.BuiltInTypeMapper.ARTypeMap( arName );
else 
rtwTypeName = arName;
end 
end 

function builtInTypeMap = getRTWToPlatformTypeMap( modelName )

rtwNames = autosar.mm.util.BuiltInTypeMapper.RTWBuiltInNames;
arNames = autosar.mm.util.BuiltInTypeMapper.AR4PlatformTypeNames;





hardwareImp = rtwwordlengths( modelName );
rtwNames = [ rtwNames, { 'int_T', 'uint_T', 'char_T' } ];
intNumBits = num2str( hardwareImp.IntNumBits );
arNames = [ arNames, { [ 'sint', intNumBits ], [ 'uint', intNumBits ], 'char' } ];
builtInTypeMap = containers.Map( rtwNames, arNames );
end 

function isEquivalent = isFixPtTypeEquivalent( dtName, baseTypeName )





isEquivalent = strcmp( dtName, baseTypeName );
if ~isEquivalent
if ( fixed.internal.type.isNameOfTraditionalFixedPointType( dtName ) )

[ fixdtObj, isScaledDouble ] = fixdt( dtName );

assert( ~isScaledDouble, 'Unknown scaled double type %s', dtName );

bname = '';
if ~fixdtObj.SignednessBool
bname = 'u';
end 
wordLength = fixdtObj.WordLength;
if wordLength <= 8
wordLength = 8;
elseif wordLength <= 16
wordLength = 16;
elseif wordLength <= 32
wordLength = 32;
elseif wordLength <= 64
wordLength = 64;
else 
assert( false, 'Unknown word length for type %s', dtName );
end 

bname = sprintf( '%sint%d', bname, wordLength );
isEquivalent = strcmp( bname, baseTypeName );
end 
end 
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpLoql9m.p.
% Please follow local copyright laws when handling this file.

