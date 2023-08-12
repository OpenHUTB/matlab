function [ ansiDataTypeName ] = wrapGenRTWTYPESDOTH( modelName, genDirectory,  ...
sharedLocation,  ...
multiwordLength, genTimingBridge,  ...
genErtSFcnRTWTypes, hostBasedSimTarget,  ...
hasMessages,  ...
needHalfPrecisionType,  ...
usingTimerService,  ...
fixedWidthIntHeader, booleanHeader )






modelConfigSet = getActiveConfigSet( modelName );


hardwareImp = rtwwordlengths( modelName );
hardwareImpProps = rtw_implementation_props( modelName );
fNames = fieldnames( hardwareImpProps );
for i = 1:length( fNames )
hardwareImp.( fNames{ i } ) = hardwareImpProps.( fNames{ i } );
end 
hardwareImp.HWDeviceType = get_param( modelName, 'TargetHWDeviceType' );


hardwareDeploy.LongNumBits = get_param( modelName, 'ProdBitPerLong' );
hardwareDeploy.IntNumBits = get_param( modelName, 'ProdBitPerInt' );
hardwareDeploy.ShortNumBits = get_param( modelName, 'ProdBitPerShort' );
hardwareDeploy.CharNumBits = get_param( modelName, 'ProdBitPerChar' );
hardwareDeploy.LongLongNumBits = get_param( modelName, 'ProdBitPerLongLong' );
hardwareDeploy.LongLongMode = int32( strcmp( get_param( modelName, 'ProdLongLongMode' ), 'on' ) );

replaceRTWTypesWithARTypes = strcmp( get_param( modelName, 'AutosarCompliant' ), 'on' ) &&  ...
autosarinstalled(  ) &&  ...
autosar.code.Utils.shouldReplaceRTWTypesWithARTypes( modelName );
cgModel = get_param( modelName, 'CGModel' );
platformTypes = cgModel.PlatformDataTypes.toArray;
basicTypeNames = containers.Map( { platformTypes.Name }, { platformTypes.Symbol } );


configInfo = coder.internal.BasicTypesConfig(  ...
genDirectory,  ...
PurelyIntegerCode = strcmp( get_param( modelName, 'PurelyIntegerCode' ), 'on' ),  ...
SupportComplex = strcmp( get_param( modelName, 'SupportComplex' ), 'on' ),  ...
MaxMultiwordBits = multiwordLength,  ...
ReplaceRTWTypesWithARTypes = replaceRTWTypesWithARTypes,  ...
ModelName = modelName,  ...
UsingLanguageStandardTypes = cgModel.IsUsingLanguageStandardTypes,  ...
FixedWidthIntHeader = fixedWidthIntHeader,  ...
BooleanHeader = booleanHeader,  ...
BasicTypeNames = basicTypeNames );


lIsERT = strcmp( get_param( modelName, 'IsERTTarget' ), 'on' );
if lIsERT
lGRTInterface = strcmp( get_param( modelName, 'GRTInterface' ), 'on' );
lUseCVMatForImage = strcmp( get_param( modelName, 'ImplementImageWithCVMat' ), 'on' );
else 
lGRTInterface = false;
lUseCVMatForImage = 0;
end 
lReplacementTypesOn = rtwprivate( 'rtwattic', 'AtticData', 'isReplacementOn' );
if lReplacementTypesOn
lReplacementTypesStruct = get_param( modelName, 'ReplacementTypes' );
else 
lReplacementTypesStruct = [  ];
end 
dataDictionary = get_param( modelName, 'DataDictionary' );
if ( isempty( dataDictionary ) )
lDesignDataLocation = 'base';
else 
lDesignDataLocation = dataDictionary;
end 
if hostBasedSimTarget ||  ...
( strcmp( get_param( modelName, 'ExtMode' ), 'on' ) ||  ...
strcmp( get_param( modelName, 'MatFileLogging' ), 'on' ) ) ||  ...
~isempty( regexp( get_param( modelName, 'RTWMakeCommand' ), 'EXT_MODE=1', 'once' ) )
lGenChunkDefs = true;
else 
lGenChunkDefs = false;
end 

if hasMessages ||  ...
( strcmp( get_param( modelName, 'MatFileLogging' ), 'on' ) ||  ...
( modelConfigSet.isValidParam( 'RTWCAPIParams' ) &&  ...
strcmp( get_param( modelName, 'RTWCAPIParams' ), 'on' ) ) ||  ...
( modelConfigSet.isValidParam( 'RTWCAPISignals' ) &&  ...
strcmp( get_param( modelName, 'RTWCAPISignals' ), 'on' ) ) ||  ...
( modelConfigSet.isValidParam( 'RTWCAPIStates' ) &&  ...
strcmp( get_param( modelName, 'RTWCAPIStates' ), 'on' ) ) ||  ...
( modelConfigSet.isValidParam( 'RTWCAPIRootIO' ) &&  ...
strcmp( get_param( modelName, 'RTWCAPIRootIO' ), 'on' ) ) ||  ...
contains( get_param( modelName, 'TLCOptions' ), '-aParameterTuning=1' ) ||  ...
contains( get_param( modelName, 'TLCOptions' ), '-aBlockIOSignals=1' ) )
lGenBuiltInDTEnums = true;
else 
lGenBuiltInDTEnums = false;
end 

[ lReplacementTypeLimitsStruct, lReplacementTypeLimitsHdrFile ] ...
 = hSetTypeLimitIdentifierReplacementFields( modelConfigSet );

simulinkInfo = coder.internal.getCoderTypesSimulinkInfo(  ...
'DesignDataLocation', lDesignDataLocation,  ...
'ExistingSharedCode', get_param( modelName, 'ExistingSharedCode' ),  ...
'GRTInterface', lGRTInterface,  ...
'GenBuiltInDTEnums', lGenBuiltInDTEnums,  ...
'GenChunkDefs', lGenChunkDefs,  ...
'GenErtSFcnRTWTypes', genErtSFcnRTWTypes,  ...
'GenTimingBridge', genTimingBridge,  ...
'IsERT', lIsERT,  ...
'PortableWordSizes', strcmp( get_param( modelName, 'PortableWordSizes' ), 'on' ),  ...
'ReplacementTypeLimitsHdrFile', lReplacementTypeLimitsHdrFile,  ...
'ReplacementTypeLimitsStruct', lReplacementTypeLimitsStruct,  ...
'ReplacementTypesOn', lReplacementTypesOn,  ...
'ReplacementTypesStruct', lReplacementTypesStruct,  ...
'SharedLocation', sharedLocation,  ...
'Style', cgModel.RtwtypesStyle,  ...
'SupportNonInlinedSFcns', strcmp( get_param( modelName, 'SupportNonInlinedSFcns' ), 'on' ),  ...
'UseCVMatForImage', lUseCVMatForImage,  ...
'UsingTimerServices', logical( usingTimerService ) ...
 );

if strcmp( simulinkInfo.Style, 'full' ) &&  ...
simulinkInfo.PortableWordSizes &&  ...
hardwareImp.CharNumBits ~= 8
DAStudio.error( 'RTW:buildProcess:PWSWithFullStyleOnWordAddressableTarget' );
end 


ansiDataTypeName = genRTWTYPESDOTH( hardwareImp, hardwareDeploy, configInfo, simulinkInfo );


if needHalfPrecisionType
[ newContentWritten, ~ ] = genHALFTYPEHDR( modelName, configInfo, simulinkInfo );

ansiDataTypeName.tlcAddBanner_halfType_hdr = newContentWritten;

[ newContentWritten, ~ ] = genHALFTYPESRC( modelName, configInfo, simulinkInfo );

ansiDataTypeName.tlcAddBanner_halfType_src = newContentWritten;
end 


if cgModel.DeclaredImageTypeUsage
newContentWritten = genIMAGETYPEDOTH( modelName, configInfo, simulinkInfo );

ansiDataTypeName.tlcAddBanner_imageType_hdr = newContentWritten;

newContentWritten = genIMAGETYPEDOTC( modelName, configInfo, simulinkInfo );

ansiDataTypeName.tlcAddBanner_imageType_src = newContentWritten;
end 

end 

function [ lReplacementTypeLimitsStruct, lReplacementTypeLimitsHdrFile ] =  ...
hSetTypeLimitIdentifierReplacementFields( cs )





limitParameters = coder.internal.getReplacementLimitParams;

replacementTypeLimitsOn = rtwprivate( 'rtwattic', 'AtticData', 'isLimitsReplacementOn' );

if replacementTypeLimitsOn
for lIdx = 1:length( limitParameters )
currField = limitParameters{ lIdx };

if cs.isValidParam( currField )
lReplacementTypeLimitsStruct.( currField ) = cs.get_param( currField );
else 
lReplacementTypeLimitsStruct.( currField ) = '';
end 
end 
if cs.isValidParam( 'TypeLimitIdReplacementHeaderFile' )
lReplacementTypeLimitsHdrFile =  ...
get_param( cs, 'TypeLimitIdReplacementHeaderFile' );
else 
lReplacementTypeLimitsHdrFile = '';
end 
else 
lReplacementTypeLimitsStruct = [  ];
lReplacementTypeLimitsHdrFile = '';
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpxzxbaA.p.
% Please follow local copyright laws when handling this file.

