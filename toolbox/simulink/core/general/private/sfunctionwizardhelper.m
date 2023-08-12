function sfunctionwizardhelper( sfunName, sfunNameWrapper, mdlStartTempFile, mdlOutputTempFile, mdlUpdateTempFile, mdlDerivativeTempFile, mdlTerminateTempFile, headersTempFile, legacy_c, pathFcnCall, fileParams, bus_header, slVersion, sfbVersion, businfoStruct )












fileHandler = fopen( fileParams, 'r' );
if ( fileHandler ==  - 1 )
DAStudio.error( 'Simulink:SFunctionBuilder:ErrorOpenForRead', fileParams );
end 
INFileParams = fread( fileHandler, '*char' )';
fclose( fileHandler );



NumDiscStates = 0;
DStatesIC = '';
NumContStates = 0;
CStatesIC = '';
sampleTime = '';
CreateWrapperTLC = false;
UseSimStruct = false;
CreateDebugMex = false;
ShowCompileSteps = false;
SaveCodeOnly = false;
LibrarySourceFiles = '';
PanelIndex = '';
FlagGenHeaderFile = false;
FlagGenStartFunction = false;
FlagGenTerminateFunction = false;
sFunMajorityIdx = 0;
FlagSupportForEach = false;
FlagMultiThread = false;
FlagCodeReuse = false;



while ( ~isempty( INFileParams ) )
idx = regexp( INFileParams, '(?m).*?$\n?', 'end', 'once' );
line = strtrim( INFileParams( 1:idx ) );
INFileParams( 1:idx ) = [  ];

lineKeyValPair = regexp( line, '^\s*(?<key>\<.+?\>)\s*=\s*(?<value>\<.+?\>)\s*$', 'names' );

if ( isempty( lineKeyValPair ) )
continue ;
end 

switch lineKeyValPair.key
case 'NumberOfInputPorts'
NumberOfInputPorts = str2double( lineKeyValPair.value );

InPortName = cell( 1, NumberOfInputPorts );
InDimsAbs = cell( 1, NumberOfInputPorts );
InDataType = cell( 1, NumberOfInputPorts );
InComplexity = cell( 1, NumberOfInputPorts );
InBusBased = cell( 1, NumberOfInputPorts );
IsInBusBased = false( 1, NumberOfInputPorts );
InBusName = cell( 1, NumberOfInputPorts );
InDims = cell( 1, NumberOfInputPorts );
InIsSigned = false( 1, NumberOfInputPorts );
InWordLength = zeros( 1, NumberOfInputPorts );
InFractionLength = zeros( 1, NumberOfInputPorts );
FlagInFixPointScaling = false( 1, NumberOfInputPorts );
InBias = cell( 1, NumberOfInputPorts );
InSlope = cell( 1, NumberOfInputPorts );

for i = 1:NumberOfInputPorts
[ idxStart, idxEnd ] = regexp( INFileParams, [ '(?m)^\s*InPort', int2str( i ), '\{.*?\}\s*\n?' ], 'start', 'end', 'once' );
if ( ~isempty( idxStart ) )
portTextSection = regexp( INFileParams( idxStart:idxEnd ), [ '(?<=^\s*InPort', int2str( i ), '\{\s*\n*)((?m)^.*)(?=\}\s*\n?)' ], 'match', 'once' );
INFileParams( idxStart:idxEnd ) = [  ];

portKeyValuePairs = regexp( portTextSection, '(?m)^\s*(?<key>\<\w+?)\d+\>\s*=\s*(?<value>\<[^=\n]*?\>)\s*$', 'names' );
for KVPair = portKeyValuePairs
switch KVPair.key
case 'inPortName'
InPortName{ i } = KVPair.value;
case 'inDimensions'
InDimsAbs{ i } = str2num( KVPair.value );
case 'inDataType'
InDataType{ i } = KVPair.value;
case 'inComplexity'
InComplexity{ i } = KVPair.value;
case 'inBusBased'
InBusBased{ i } = KVPair.value;
IsInBusBased( i ) = strcmp( KVPair.value, 'on' );
case 'inBusname'
InBusName{ i } = KVPair.value;
case 'inDims'
InDims{ i } = KVPair.value;
case 'inIsSigned'
InIsSigned( i ) = strcmp( KVPair.value, '1' );
case 'inWordLength'
InWordLength( i ) = str2double( KVPair.value );
case 'inFractionLength'
InFractionLength( i ) = str2double( KVPair.value );
case 'inFixPointScalingType'
FlagInFixPointScaling( i ) = strcmp( KVPair.value, '1' );
case 'inBias'
InBias{ i } = KVPair.value;
case 'inSlope'
InSlope{ i } = KVPair.value;
end 
end 
end 
end 
case 'NumberOfOutputPorts'
NumberOfOutputPorts = str2double( lineKeyValPair.value );

OutPortName = cell( 1, NumberOfOutputPorts );
OutDimsAbs = cell( 1, NumberOfOutputPorts );
OutDataType = cell( 1, NumberOfOutputPorts );
OutComplexity = cell( 1, NumberOfOutputPorts );
OutBusBased = cell( 1, NumberOfOutputPorts );
IsOutBusBased = false( 1, NumberOfOutputPorts );
OutBusName = cell( 1, NumberOfOutputPorts );
OutDims = cell( 1, NumberOfOutputPorts );
OutIsSigned = false( 1, NumberOfOutputPorts );
OutWordLength = zeros( 1, NumberOfOutputPorts );
OutFractionLength = zeros( 1, NumberOfOutputPorts );
FlagOutFixPointScaling = false( 1, NumberOfOutputPorts );
OutBias = cell( 1, NumberOfOutputPorts );
OutSlope = cell( 1, NumberOfOutputPorts );

for i = 1:NumberOfOutputPorts
[ idxStart, idxEnd ] = regexp( INFileParams, [ '(?m)^\s*OutPort', int2str( i ), '\{.*?\}\s*\n?' ], 'start', 'end', 'once' );
if ( ~isempty( idxStart ) )
portTextSection = regexp( INFileParams( idxStart:idxEnd ), [ '(?<=^\s*OutPort', int2str( i ), '\{\s*\n*)((?m)^.*)(?=\}\s*\n?)' ], 'match', 'once' );
INFileParams( idxStart:idxEnd ) = [  ];

portKeyValuePairs = regexp( portTextSection, '(?m)^\s*(?<key>\<\w+?)\d+\>\s*=\s*(?<value>\<[^=\n]*?\>)\s*$', 'names' );
for KVPair = portKeyValuePairs
switch KVPair.key
case 'outPortName'
OutPortName{ i } = KVPair.value;
case 'outDimensions'
OutDimsAbs{ i } = str2num( KVPair.value );
case 'outDataType'
OutDataType{ i } = KVPair.value;
case 'outComplexity'
OutComplexity{ i } = KVPair.value;
case 'outBusBased'
OutBusBased{ i } = KVPair.value;
IsOutBusBased( i ) = strcmp( KVPair.value, 'on' );
case 'outBusname'
OutBusName{ i } = KVPair.value;
case 'outDims'
OutDims{ i } = KVPair.value;
case 'outIsSigned'
OutIsSigned( i ) = strcmp( KVPair.value, '1' );
case 'outWordLength'
OutWordLength( i ) = str2double( KVPair.value );
case 'outFractionLength'
OutFractionLength( i ) = str2double( KVPair.value );
case 'outFixPointScalingType'
FlagOutFixPointScaling( i ) = strcmp( KVPair.value, '1' );
case 'outBias'
OutBias{ i } = KVPair.value;
case 'outSlope'
OutSlope{ i } = KVPair.value;
end 
end 
end 
end 
case 'NumberOfInputs'

case 'NumberOfOutputs'

case 'directFeed'
directFeed = strcmp( lineKeyValPair.value, '1' );
case 'SupportForEach'
FlagSupportForEach = strcmp( lineKeyValPair.value, '1' );
case 'EnableMultiThread'
FlagMultiThread = strcmp( lineKeyValPair.value, '1' );
case 'EnableCodeReuse'
FlagCodeReuse = strcmp( lineKeyValPair.value, '1' );
case 'NumOfDStates'
NumDiscStates = str2double( lineKeyValPair.value );
case 'DStatesIC'
DStatesIC = lineKeyValPair.value;
case 'NumOfCStates'
NumContStates = str2double( lineKeyValPair.value );
case 'CStatesIC'
CStatesIC = lineKeyValPair.value;
case 'SampleTime'
sampleTime = lineKeyValPair.value;
case 'NumPWorks'
NumUserPWorks = str2double( lineKeyValPair.value );
case 'NumDWorks'
NumUserDWorks = str2double( lineKeyValPair.value );%#ok: DWork support will be in the next release
case 'NumberOfParameters'
NumParams = str2double( lineKeyValPair.value );
ParameterName = cell( 1, NumParams );
ParameterDataType = cell( 1, NumParams );
ParameterComplexity = cell( 1, NumParams );
for i = 1:NumParams
[ idxStart, idxEnd ] = regexp( INFileParams, [ '(?m)^\s*Parameter', int2str( i ), '\{.*?\}\s*\n?' ], 'start', 'end', 'once' );
if ( ~isempty( idxStart ) )
portTextSection = regexp( INFileParams( idxStart:idxEnd ), [ '(?<=^\s*Parameter', int2str( i ), '\{\s*\n*)((?m)^.*)(?=\}\s*\n?)' ], 'match', 'once' );
INFileParams( idxStart:idxEnd ) = [  ];

portKeyValuePairs = regexp( portTextSection, '(?m)^\s*(?<key>\<\w+?)\d+\>\s*=\s*(?<value>\<[^=\n]*?\>)\s*$', 'names' );
for KVPair = portKeyValuePairs
switch KVPair.key
case 'parameterName'
ParameterName{ i } = KVPair.value;
case 'parameterDataType'
ParameterDataType{ i } = KVPair.value;
case 'parameterComplexity'
ParameterComplexity{ i } = KVPair.value;
end 
end 
end 
end 
case 'CreateWrapperTLC'
CreateWrapperTLC = strcmp( lineKeyValPair.value, '1' );
case 'UseSimStruct'
UseSimStruct = strcmp( lineKeyValPair.value, '1' );
case 'CreateDebugMex'
CreateDebugMex = strcmp( lineKeyValPair.value, '1' );
case 'ShowCompileSteps'
ShowCompileSteps = strcmp( lineKeyValPair.value, '1' );
case 'SaveCodeOnly'
SaveCodeOnly = strcmp( lineKeyValPair.value, '1' );
case 'LibList'
LibrarySourceFiles = lineKeyValPair.value;
case 'PanelIndex'
PanelIndex = lineKeyValPair.value;
case 'Gen_HeaderFile'
FlagGenHeaderFile = strcmp( lineKeyValPair.value, '1' );
case 'GenerateStartFunction'
FlagGenStartFunction = strcmp( lineKeyValPair.value, '1' );
case 'GenerateTerminateFunction'
FlagGenTerminateFunction = strcmp( lineKeyValPair.value, '1' );
case 'SFcnMajority'
if ( slfeature( 'RowMajorDimensionSupport' ) == 0 )
sFunMajorityIdx = 0;
else 
switch lineKeyValPair.value
case 'Column'
sFunMajorityIdx = 0;
case 'Row'
sFunMajorityIdx = 1;
case 'Any'
sFunMajorityIdx = 2;
end 
end 
end 

end 





InDataTypeDefine = InDataType;
OutDataTypeDefine = OutDataType;
[ InDataType, FlagInFixPointScaling, InIsSigned, InWordLength, InFractionLength ] = convertInt64ToFixdt( InDataType, FlagInFixPointScaling, InIsSigned, InWordLength, InFractionLength );
[ OutDataType, FlagOutFixPointScaling, OutIsSigned, OutWordLength, OutFractionLength ] = convertInt64ToFixdt( OutDataType, FlagOutFixPointScaling, OutIsSigned, OutWordLength, OutFractionLength );

InDataTypeMacro = cellfun( @( x )getDataTypeMacros( x ), InDataType, 'UniformOutput', false );
OutDataTypeMacro = cellfun( @( x )getDataTypeMacros( x ), OutDataType, 'UniformOutput', false );


FlagBusUsed = any( IsInBusBased ) || any( IsOutBusBased );


sfunFile = regexp( sfunName, '^(?<Name>\w*?)\.(?<Ext>\w*?)$', 'names', 'once' );
sFName = sfunFile.Name;
IsSFunctionInC = strcmpi( sfunFile.Ext, 'c' );

sfun_template = [ pathFcnCall, filesep, 'sfunwiz_template.c.tmpl' ];
sfun_template_wrapper = [ pathFcnCall, filesep, 'sfunwiz_template_wrapper.c.tmpl' ];
sfun_template_wrapperTLC = [ pathFcnCall, filesep, 'sfunwiz_template.tlc' ];

sfunNameWrapperTLC = [ sFName, '.tlc' ];
sfunBusHeaderFile = [ sFName, '_bus.h' ];

timeString = datestr( now, 'ddd mmm dd HH:MM:SS yyyy' );


FlagDynSizedInput = ~isempty( InDimsAbs ) && any( cellfun( @( x )any( x ==  - 1 ), InDimsAbs ) == 1 );
idxDynSizedInput = [  ];
if FlagDynSizedInput
idxDynSizedInput = find( cellfun( @( x )any( x ==  - 1 ), InDimsAbs ) == 1 );
end 
FlagDynSizedOutput = ~isempty( OutDimsAbs ) && any( cellfun( @( x )any( x ==  - 1 ), OutDimsAbs ) == 1 );
idxDynSizedOutput = [  ];
if FlagDynSizedOutput
idxDynSizedOutput = find( cellfun( @( x )any( x ==  - 1 ), OutDimsAbs ) == 1 );
end 

sfunIsRowMajor = ( sFunMajorityIdx == 1 );

bus_Header_List = '';
isNestedInScalarBusMap = containers.Map(  );
if ( FlagBusUsed )
bus_Header_List = genBusHeaderFile( sfunBusHeaderFile, bus_header, FlagGenHeaderFile );




isNestedInScalarBusMap = checkIfNestedBusArray( businfoStruct, InPortName, OutPortName, IsInBusBased, IsOutBusBased, InDimsAbs, OutDimsAbs );
end 
UpdatefcnStr = 'Update';
stateDStr = 'xD';
fcnCallUpdate = genFunctionCall( InDimsAbs, OutDimsAbs, NumParams, NumDiscStates, NumUserPWorks, UpdatefcnStr, stateDStr, sFName, NumberOfInputPorts, NumberOfOutputPorts, InPortName, OutPortName, ParameterName, IsInBusBased, IsOutBusBased, FlagDynSizedInput, FlagDynSizedOutput, idxDynSizedInput, idxDynSizedOutput, directFeed, UseSimStruct, sfunIsRowMajor, isNestedInScalarBusMap );
fcnProtoTypeUpdate = genStatesWrapper( NumParams, NumDiscStates, NumUserPWorks, UpdatefcnStr, stateDStr, sFName, InDataType, OutDataType, ParameterDataType, InPortName, OutPortName, ParameterName, InBusName, OutBusName, NumberOfInputPorts, NumberOfOutputPorts, InWordLength, OutWordLength, InIsSigned, OutIsSigned, IsInBusBased, IsOutBusBased, FlagDynSizedInput, FlagDynSizedOutput, idxDynSizedInput, idxDynSizedOutput, UseSimStruct, 0 );



fcnProtoTypeUpdateTLC1 = genStatesWrapper( NumParams, NumDiscStates, NumUserPWorks, UpdatefcnStr, stateDStr, sFName, InDataType, OutDataType, ParameterDataType, InPortName, OutPortName, ParameterName, InBusName, OutBusName, NumberOfInputPorts, NumberOfOutputPorts, InWordLength, OutWordLength, InIsSigned, OutIsSigned, IsInBusBased, IsOutBusBased, FlagDynSizedInput, FlagDynSizedOutput, idxDynSizedInput, idxDynSizedOutput, UseSimStruct, 1 );



fcnProtoTypeUpdateTLC2 = genStatesWrapper( NumParams, NumDiscStates, NumUserPWorks, UpdatefcnStr, stateDStr, sFName, InDataType, OutDataType, ParameterDataType, InPortName, OutPortName, ParameterName, InBusName, OutBusName, NumberOfInputPorts, NumberOfOutputPorts, InWordLength, OutWordLength, InIsSigned, OutIsSigned, IsInBusBased, IsOutBusBased, FlagDynSizedInput, FlagDynSizedOutput, idxDynSizedInput, idxDynSizedOutput, UseSimStruct, 2 );

DerivativesfcnStr = 'Derivatives';
stateCStr = 'xC';
fcnCallDerivatives = genFunctionCall( InDimsAbs, OutDimsAbs, NumParams, NumContStates, NumUserPWorks, DerivativesfcnStr, stateCStr, sFName, NumberOfInputPorts, NumberOfOutputPorts, InPortName, OutPortName, ParameterName, IsInBusBased, IsOutBusBased, FlagDynSizedInput, FlagDynSizedOutput, idxDynSizedInput, idxDynSizedOutput, directFeed, UseSimStruct, sfunIsRowMajor, isNestedInScalarBusMap );
fcnProtoTypeDerivatives = genStatesWrapper( NumParams, NumContStates, NumUserPWorks, DerivativesfcnStr, stateCStr, sFName, InDataType, OutDataType, ParameterDataType, InPortName, OutPortName, ParameterName, InBusName, OutBusName, NumberOfInputPorts, NumberOfOutputPorts, InWordLength, OutWordLength, InIsSigned, OutIsSigned, IsInBusBased, IsOutBusBased, FlagDynSizedInput, FlagDynSizedOutput, idxDynSizedInput, idxDynSizedOutput, UseSimStruct, 0 );


fcnProtoTypeDerivativesTLC1 = genStatesWrapper( NumParams, NumContStates, NumUserPWorks, DerivativesfcnStr, stateCStr, sFName, InDataType, OutDataType, ParameterDataType, InPortName, OutPortName, ParameterName, InBusName, OutBusName, NumberOfInputPorts, NumberOfOutputPorts, InWordLength, OutWordLength, InIsSigned, OutIsSigned, IsInBusBased, IsOutBusBased, FlagDynSizedInput, FlagDynSizedOutput, idxDynSizedInput, idxDynSizedOutput, UseSimStruct, 1 );
fcnProtoTypeDerivativesTLC2 = genStatesWrapper( NumParams, NumContStates, NumUserPWorks, DerivativesfcnStr, stateCStr, sFName, InDataType, OutDataType, ParameterDataType, InPortName, OutPortName, ParameterName, InBusName, OutBusName, NumberOfInputPorts, NumberOfOutputPorts, InWordLength, OutWordLength, InIsSigned, OutIsSigned, IsInBusBased, IsOutBusBased, FlagDynSizedInput, FlagDynSizedOutput, idxDynSizedInput, idxDynSizedOutput, UseSimStruct, 2 );


fcnCallStart = genFunctionCallStartTerminate( NumParams, NumContStates, NumDiscStates, NumUserPWorks, 'Start', sFName, ParameterName, UseSimStruct, sfunIsRowMajor );
fcnProtoTypeStart = genStartTerminateWrapper( NumParams, NumContStates, NumDiscStates, NumUserPWorks, 'Start', sFName, ParameterDataType, ParameterName, UseSimStruct, 0 );
fcnProtoTypeStartTLC1 = genStartTerminateWrapper( NumParams, NumContStates, NumDiscStates, NumUserPWorks, 'Start', sFName, ParameterDataType, ParameterName, UseSimStruct, 1 );
fcnProtoTypeStartTLC2 = genStartTerminateWrapper( NumParams, NumContStates, NumDiscStates, NumUserPWorks, 'Start', sFName, ParameterDataType, ParameterName, UseSimStruct, 2 );

fcnCallTerminate = genFunctionCallStartTerminate( NumParams, NumContStates, NumDiscStates, NumUserPWorks, 'Terminate', sFName, ParameterName, UseSimStruct, sfunIsRowMajor );
fcnProtoTypeTerminate = genStartTerminateWrapper( NumParams, NumContStates, NumDiscStates, NumUserPWorks, 'Terminate', sFName, ParameterDataType, ParameterName, UseSimStruct, 0 );
fcnProtoTypeTerminateTLC1 = genStartTerminateWrapper( NumParams, NumContStates, NumDiscStates, NumUserPWorks, 'Terminate', sFName, ParameterDataType, ParameterName, UseSimStruct, 1 );
fcnProtoTypeTerminateTLC2 = genStartTerminateWrapper( NumParams, NumContStates, NumDiscStates, NumUserPWorks, 'Terminate', sFName, ParameterDataType, ParameterName, UseSimStruct, 2 );

OutputfcnStr = 'Outputs';
fcnCallOutput = genFunctionCallOutput( InDimsAbs, OutDimsAbs, NumberOfInputPorts, NumberOfOutputPorts, IsInBusBased, IsOutBusBased, NumParams, NumDiscStates, NumContStates, NumUserPWorks, OutputfcnStr, sFName, FlagDynSizedOutput, FlagDynSizedInput, idxDynSizedInput, idxDynSizedOutput, directFeed, InPortName, OutPortName, ParameterName, UseSimStruct, sfunIsRowMajor, isNestedInScalarBusMap );
fcnProtoTypeOutput = genOutputWrapper( NumberOfInputPorts, NumberOfOutputPorts, NumParams, NumDiscStates, NumContStates, NumUserPWorks, OutputfcnStr, sFName, FlagDynSizedInput, FlagDynSizedOutput, idxDynSizedInput, idxDynSizedOutput, IsInBusBased, IsOutBusBased, InIsSigned, OutIsSigned, 0, InWordLength, InPortName, InDataType, InBusName, OutWordLength, OutPortName, OutDataType, OutBusName, ParameterDataType, ParameterName, directFeed, UseSimStruct );


discStatesArray = '';
strDStates = 'NO_USER_DEFINED_DISCRETE_STATES';
if ( isempty( regexp( mdlUpdateTempFile, strDStates, 'end', 'once' ) ) )
fileHandler = fopen( mdlUpdateTempFile, 'r' );
if ( fileHandler ==  - 1 )
DAStudio.error( 'Simulink:SFunctionBuilder:ErrorOpenForRead', mdlUpdateTempFile );
end 
discStatesArray = fread( fileHandler, '*char' )';
fclose( fileHandler );
end 

contStatesArray = '';
strCStates = 'NO_USER_DEFINED_CONTINUOUS_STATES';
if ( isempty( regexp( mdlDerivativeTempFile, strCStates, 'end', 'once' ) ) )
fileHandler = fopen( mdlDerivativeTempFile, 'r' );
if ( fileHandler ==  - 1 )
DAStudio.error( 'Simulink:SFunctionBuilder:ErrorOpenForRead', mdlDerivativeTempFile );
end 
contStatesArray = fread( fileHandler, '*char' )';
fclose( fileHandler );
end 

headerArray = '';
strH = 'NO_USER_DEFINED_HEADER_CODE';
if ( isempty( regexp( headersTempFile, strH, 'end', 'once' ) ) )
fileHandler = fopen( headersTempFile, 'r' );
if ( fileHandler ==  - 1 )
DAStudio.error( 'Simulink:SFunctionBuilder:ErrorOpenForRead', headersTempFile );
end 
headerArray = fread( fileHandler, '*char' )';
fclose( fileHandler );
end 

externDeclarations = '';
strC = 'NO_USER_DEFINED_C_CODE';
if ( isempty( regexp( legacy_c, strC, 'end', 'once' ) ) )
fileHandler = fopen( legacy_c, 'r' );
if ( fileHandler ==  - 1 )
DAStudio.error( 'Simulink:SFunctionBuilder:ErrorOpenForRead', legacy_c );
end 
externDeclarations = fread( fileHandler, '*char' )';
fclose( fileHandler );
end 

fileHandler = fopen( mdlStartTempFile, 'r' );
if ( fileHandler ==  - 1 )
DAStudio.error( 'Simulink:SFunctionBuilder:ErrorOpenForRead', mdlStartTempFile );
end 
mdlStartArray = fread( fileHandler, '*char' )';
fclose( fileHandler );

fileHandler = fopen( mdlOutputTempFile, 'r' );
if ( fileHandler ==  - 1 )
DAStudio.error( 'Simulink:SFunctionBuilder:ErrorOpenForRead', mdlOutputTempFile );
end 
mdlOutputArray = fread( fileHandler, '*char' )';
fclose( fileHandler );

fileHandler = fopen( mdlTerminateTempFile, 'r' );
if ( fileHandler ==  - 1 )
DAStudio.error( 'Simulink:SFunctionBuilder:ErrorOpenForRead', mdlTerminateTempFile );
end 
mdlTerminateArray = fread( fileHandler, '*char' )';
fclose( fileHandler );

inWidth = cellfun( @prod, InDimsAbs );
outWidth = cellfun( @prod, OutDimsAbs );
fcnProtoTypeOutputTLC1 = genOutputWrapper( NumberOfInputPorts, NumberOfOutputPorts, NumParams, NumDiscStates, NumContStates, NumUserPWorks, OutputfcnStr, sFName, FlagDynSizedInput, FlagDynSizedOutput, idxDynSizedInput, idxDynSizedOutput, IsInBusBased, IsOutBusBased, InIsSigned, OutIsSigned, 1, InWordLength, InPortName, InDataType, InBusName, OutWordLength, OutPortName, OutDataType, OutBusName, ParameterDataType, ParameterName, directFeed, UseSimStruct );
fcnProtoTypeOutputTLC2 = genOutputWrapper( NumberOfInputPorts, NumberOfOutputPorts, NumParams, NumDiscStates, NumContStates, NumUserPWorks, OutputfcnStr, sFName, FlagDynSizedInput, FlagDynSizedOutput, idxDynSizedInput, idxDynSizedOutput, IsInBusBased, IsOutBusBased, InIsSigned, OutIsSigned, 2, InWordLength, InPortName, InDataType, InBusName, OutWordLength, OutPortName, OutDataType, OutBusName, ParameterDataType, ParameterName, directFeed, UseSimStruct );
[ wrapperExternDeclarationOutputTLCForBus, idxForExtern ] = genExternDeclarationTLCForBus( sFName, NumberOfInputPorts, InPortName, InBusName, IsInBusBased, NumberOfOutputPorts, OutPortName, OutBusName, IsOutBusBased, NumDiscStates, NumContStates,  ...
FlagGenHeaderFile, sfunBusHeaderFile, bus_Header_List, fcnProtoTypeStartTLC1, fcnProtoTypeStartTLC2, fcnProtoTypeOutputTLC1, fcnProtoTypeOutputTLC2, fcnProtoTypeUpdateTLC1, fcnProtoTypeUpdateTLC2,  ...
fcnProtoTypeDerivativesTLC1, fcnProtoTypeDerivativesTLC2, fcnProtoTypeTerminateTLC1, fcnProtoTypeTerminateTLC2, IsSFunctionInC, FlagGenStartFunction, FlagGenTerminateFunction, inWidth, outWidth,  ...
fcnProtoTypeUpdate, fcnProtoTypeDerivatives, fcnProtoTypeStart, fcnProtoTypeOutput, fcnProtoTypeTerminate );









evalConditionByTemplateVisibleVariables = @( condition,  ...
FlagGenStartFunction,  ...
FlagGenTerminateFunction,  ...
directFeed,  ...
sFunMajorityIdx,  ...
FlagBusUsed,  ...
NumDiscStates,  ...
NumContStates ) ...
eval( condition );



testTemplateCondition = @( condition ) ...
evalConditionByTemplateVisibleVariables( condition,  ...
FlagGenStartFunction,  ...
FlagGenTerminateFunction,  ...
directFeed,  ...
sFunMajorityIdx,  ...
FlagBusUsed,  ...
NumDiscStates,  ...
NumContStates );


fileHandler = fopen( sfun_template, 'r' );
if ( fileHandler ==  - 1 )
DAStudio.error( 'Simulink:SFunctionBuilder:ErrorOpenForRead', sfun_template );
end 
IN = fread( fileHandler, '*char' )';
fclose( fileHandler );
IN = tmplCondtlPreProc( IN, testTemplateCondition );





sfunwiz_gensfunction( sfunName, IN, timeString, FlagBusUsed, FlagGenHeaderFile, sfunBusHeaderFile, bus_Header_List, slVersion, FlagGenTerminateFunction,  ...
FlagDynSizedInput, FlagDynSizedOutput, idxDynSizedInput, idxDynSizedOutput, fcnProtoTypeUpdate, fcnProtoTypeDerivatives, fcnProtoTypeStart, fcnProtoTypeOutput, fcnProtoTypeTerminate, fcnCallUpdate, fcnCallDerivatives, fcnCallStart, fcnCallOutput, fcnCallTerminate,  ...
NumberOfInputPorts, NumberOfOutputPorts, NumParams, NumDiscStates, NumContStates, NumUserPWorks, sFName, LibrarySourceFiles, InDataTypeMacro, OutDataTypeMacro,  ...
InPortName, InDimsAbs, InDataTypeDefine, InComplexity, IsInBusBased, InBusName, InDims, directFeed, InIsSigned, InWordLength, FlagInFixPointScaling, InFractionLength, InBias, InSlope,  ...
OutPortName, OutDimsAbs, OutDataTypeDefine, OutComplexity, IsOutBusBased, OutBusName, OutDims, OutIsSigned, OutWordLength, FlagOutFixPointScaling, OutFractionLength, OutBias, OutSlope,  ...
ParameterName, ParameterDataType, ParameterComplexity, sampleTime, CStatesIC, DStatesIC, PanelIndex, CreateWrapperTLC, ShowCompileSteps, CreateDebugMex, SaveCodeOnly, UseSimStruct, sFunMajorityIdx, businfoStruct, FlagSupportForEach, FlagMultiThread, FlagCodeReuse );

eval( [ 'c_beautifier [-nocomments -codebreakcolumn=#] ', sfunName ] );


fileHandler = fopen( sfun_template_wrapper, 'r' );
if ( fileHandler ==  - 1 )
DAStudio.error( 'Simulink:SFunctionBuilder:ErrorOpenForRead', sfun_template_wrapper );
end 
INWrapper = fread( fileHandler, '*char' )';
fclose( fileHandler );
INWrapper = tmplCondtlPreProc( INWrapper, testTemplateCondition );





sfunwiz_gensfunctionwrapper( sfunNameWrapper, INWrapper, timeString, FlagGenHeaderFile, sfunBusHeaderFile, bus_Header_List, headerArray, NumberOfInputPorts, NumberOfOutputPorts, FlagDynSizedInput, FlagDynSizedOutput,  ...
InDimsAbs, OutDimsAbs, externDeclarations, fcnProtoTypeStart, fcnProtoTypeOutput, fcnProtoTypeUpdate, fcnProtoTypeDerivatives, fcnProtoTypeTerminate, mdlStartArray, mdlOutputArray, discStatesArray, contStatesArray, mdlTerminateArray, UseSimStruct );




if ( CreateWrapperTLC )
fcnCallOutputTLC = genFunctionCallOutputTLC( sFName, OutputfcnStr, NumberOfInputPorts, NumberOfOutputPorts, InPortName, OutPortName, NumParams, NumDiscStates, NumContStates, NumUserPWorks, IsInBusBased, IsOutBusBased, FlagDynSizedInput, FlagDynSizedOutput, idxDynSizedInput, idxDynSizedOutput, FlagBusUsed, directFeed, UseSimStruct, 0 );
fcnCallOutputTLC1 = genFunctionCallOutputTLC( sFName, OutputfcnStr, NumberOfInputPorts, NumberOfOutputPorts, InPortName, OutPortName, NumParams, NumDiscStates, NumContStates, NumUserPWorks, IsInBusBased, IsOutBusBased, FlagDynSizedInput, FlagDynSizedOutput, idxDynSizedInput, idxDynSizedOutput, FlagBusUsed, directFeed, UseSimStruct, 1 );
if ( ~isempty( fcnCallOutputTLC1 ) )
if ( ~IsSFunctionInC )
fcnCallOutputTLC = [ fcnCallOutputTLC1, sprintf( '\n  %%else\n    ' ), makeCgenWrapper( fcnCallOutputTLC ), sprintf( '\n  %%endif\n' ) ];
else 
fcnCallOutputTLC = [ fcnCallOutputTLC1, sprintf( '\n  %%else\n    ' ), fcnCallOutputTLC, sprintf( '\n  %%endif\n' ) ];
end 
end 

stateDStrTLC = '%<pxd>';
fcnCallUpdateTLC = genFunctionCallTLC( sFName, UpdatefcnStr, NumberOfInputPorts, NumberOfOutputPorts, InPortName, OutPortName, IsInBusBased, IsOutBusBased, NumParams, NumDiscStates, NumUserPWorks, stateDStrTLC, FlagDynSizedInput, FlagDynSizedOutput, idxDynSizedInput, idxDynSizedOutput, FlagBusUsed, UseSimStruct, 0 );
fcnCallUpdateTLC1 = genFunctionCallTLC( sFName, UpdatefcnStr, NumberOfInputPorts, NumberOfOutputPorts, InPortName, OutPortName, IsInBusBased, IsOutBusBased, NumParams, NumDiscStates, NumUserPWorks, stateDStrTLC, FlagDynSizedInput, FlagDynSizedOutput, idxDynSizedInput, idxDynSizedOutput, FlagBusUsed, UseSimStruct, 1 );
if ( ~isempty( fcnCallUpdateTLC1 ) )
if ( ~IsSFunctionInC )
fcnCallUpdateTLC = [ fcnCallUpdateTLC1, sprintf( '\n  %%else\n    ' ), makeCgenWrapper( fcnCallUpdateTLC ), sprintf( '\n  %%endif\n' ) ];
else 
fcnCallUpdateTLC = [ fcnCallUpdateTLC1, sprintf( '\n  %%else\n    ' ), fcnCallUpdateTLC, sprintf( '\n  %%endif\n' ) ];
end 
end 

stateCStrTLC = 'pxc';
fcnCallDerivativesTLC = genFunctionCallTLC( sFName, DerivativesfcnStr, NumberOfInputPorts, NumberOfOutputPorts, InPortName, OutPortName, IsInBusBased, IsOutBusBased, NumParams, NumContStates, NumUserPWorks, stateCStrTLC, FlagDynSizedInput, FlagDynSizedOutput, idxDynSizedInput, idxDynSizedOutput, FlagBusUsed, UseSimStruct, 0 );
fcnCallDerivativesTLC1 = genFunctionCallTLC( sFName, DerivativesfcnStr, NumberOfInputPorts, NumberOfOutputPorts, InPortName, OutPortName, IsInBusBased, IsOutBusBased, NumParams, NumContStates, NumUserPWorks, stateCStrTLC, FlagDynSizedInput, FlagDynSizedOutput, idxDynSizedInput, idxDynSizedOutput, FlagBusUsed, UseSimStruct, 1 );
if ( ~isempty( fcnCallDerivativesTLC1 ) )
if ( ~IsSFunctionInC )
fcnCallDerivativesTLC = [ fcnCallDerivativesTLC1, sprintf( '\n  %%else\n    ' ), makeCgenWrapper( fcnCallDerivativesTLC ), sprintf( '\n  %%endif\n' ) ];
else 
fcnCallDerivativesTLC = [ fcnCallDerivativesTLC1, sprintf( '\n  %%else\n    ' ), fcnCallDerivativesTLC, sprintf( '\n  %%endif\n' ) ];
end 
end 

fcnCallStartTLC = genFunctionCallStartTerminateTLC( sFName, 'Start', NumParams, NumContStates, NumDiscStates, NumUserPWorks, UseSimStruct, FlagBusUsed, 0 );
fcnCallStartTLC1 = genFunctionCallStartTerminateTLC( sFName, 'Start', NumParams, NumContStates, NumDiscStates, NumUserPWorks, UseSimStruct, FlagBusUsed, 1 );
if ( ~isempty( fcnCallStartTLC1 ) )
if ( ~IsSFunctionInC )
fcnCallStartTLC = [ fcnCallStartTLC1, sprintf( '\n  %%else\n    ' ), makeCgenWrapper( fcnCallStartTLC ), sprintf( '\n  %%endif\n' ) ];
else 
fcnCallStartTLC = [ fcnCallStartTLC1, sprintf( '\n  %%else\n    ' ), fcnCallStartTLC, sprintf( '\n  %%endif\n' ) ];
end 
end 

fcnCallTerminateTLC = genFunctionCallStartTerminateTLC( sFName, 'Terminate', NumParams, NumContStates, NumDiscStates, NumUserPWorks, UseSimStruct, FlagBusUsed, 0 );
fcnCallTerminateTLC1 = genFunctionCallStartTerminateTLC( sFName, 'Terminate', NumParams, NumContStates, NumDiscStates, NumUserPWorks, UseSimStruct, FlagBusUsed, 1 );

if ( ~isempty( fcnCallTerminateTLC1 ) )
if ( ~IsSFunctionInC )
fcnCallTerminateTLC = [ fcnCallTerminateTLC1, sprintf( '\n  %%else\n    ' ), makeCgenWrapper( fcnCallTerminateTLC ), sprintf( '\n  %%endif\n' ) ];
else 
fcnCallTerminateTLC = [ fcnCallTerminateTLC1, sprintf( '\n  %%else\n    ' ), fcnCallTerminateTLC, sprintf( '\n  %%endif\n' ) ];
end 
end 

fileHandler = fopen( sfun_template_wrapperTLC, 'r' );
if ( fileHandler ==  - 1 )
DAStudio.error( 'Simulink:SFunctionBuilder:ErrorOpenForRead', sfun_template_wrapperTLC );
end 
INWrapperTLC = fread( fileHandler, '*char' )';
fclose( fileHandler );

INWrapperTLC = tmplCondtlPreProc( INWrapperTLC, testTemplateCondition );





sfunwiz_gensfunctionwrappertlc( sfunNameWrapperTLC, INWrapperTLC, sFName, NumberOfInputPorts, NumberOfOutputPorts, InDataType, OutDataType, NumParams, ParameterName, ParameterComplexity, ParameterDataType,  ...
NumDiscStates, NumContStates, DStatesIC, CStatesIC, NumUserPWorks, FlagDynSizedInput, idxDynSizedInput ...
, FlagDynSizedOutput, idxDynSizedOutput, FlagBusUsed, timeString, sfunName, fcnCallStartTLC, fcnCallOutputTLC, fcnCallUpdateTLC, fcnCallDerivativesTLC, fcnCallTerminateTLC,  ...
fcnProtoTypeStart, fcnProtoTypeOutput, wrapperExternDeclarationOutputTLCForBus, fcnProtoTypeUpdate, fcnProtoTypeDerivatives, fcnProtoTypeTerminate, UseSimStruct, IsSFunctionInC, idxForExtern );

end 







genMakeConfigFile( sfbVersion );

end 








function genMakeConfigFile( sfbVersion )
titleForRTWMAKECFG = sprintf( [ 'function makeInfo=rtwmakecfg()\n' ...
, '%%RTWMAKECFG.m adds include and source directories to rtw make files.\n' ...
, '%%  makeInfo=RTWMAKECFG returns a structured array containing\n' ...
, '%%  following field:\n' ...
, '%%     makeInfo.includePath - cell array containing additional include\n' ...
, '%%                            directories. Those directories will be\n' ...
, '%%                            expanded into include instructions of Simulink\n' ...
, '%%                            Coder generated make files.\n' ...
, '%%\n' ...
, '%%     makeInfo.sourcePath  - cell array containing additional source\n' ...
, '%%                            directories. Those directories will be\n' ...
, '%%                            expanded into rules of Simulink Coder generated \n' ...
, '%%                            make files.\n' ...
, 'makeInfo.includePath = {};\n' ...
, 'makeInfo.sourcePath  = {};\n' ...
, 'makeInfo.linkLibsObjs = {};\n' ...
 ] );

sfBuilderInsertTag = sprintf( '\n%%<Generated by S-Function Builder %s. DO NOT REMOVE>\n', sfbVersion );
customBodyForRTWMAKECFG = [ sfBuilderInsertTag ...
, sprintf( [ '\n' ...
, 'sfBuilderBlocksByMaskType = find_system(bdroot,''FollowLinks'',''on'',''LookUnderMasks'',''on'',''MaskType'',''S-Function Builder'');\n' ...
, 'sfBuilderBlocksByCallback = find_system(bdroot,''OpenFcn'',''sfunctionwizard(gcbh)'');\n' ...
, 'sfBuilderBlocksDeployed   = find_system(bdroot,''BlockType'',''S-Function'',''SFunctionDeploymentMode'',''on'');\n' ...
, 'sfBuilderBlocks = {sfBuilderBlocksByMaskType{:} sfBuilderBlocksByCallback{:} sfBuilderBlocksDeployed{:}};\n' ...
, 'sfBuilderBlocks = unique(sfBuilderBlocks);\n' ...
, 'if isempty(sfBuilderBlocks)\n' ...
, '   return;\n' ...
, 'end\n' ...
, 'sfBuilderBlockNameMATFile = cell(1, length(sfBuilderBlocks));\n' ...
, 'for idx = 1:length(sfBuilderBlocks)\n' ...
, '   sfBuilderBlockNameMATFile{idx} = get_param(sfBuilderBlocks{idx},''FunctionName'');\n' ...
, '   sfBuilderBlockNameMATFile{idx} = [''.'' filesep ''SFB__'' char(sfBuilderBlockNameMATFile{idx}) ''__SFB.mat''];\n' ...
, 'end\n' ...
, 'sfBuilderBlockNameMATFile = unique(sfBuilderBlockNameMATFile);\n' ...
, 'for idx = 1:length(sfBuilderBlockNameMATFile)\n' ...
, '   if exist(sfBuilderBlockNameMATFile{idx}, ''file'')\n' ...
, '      loadedData = load(sfBuilderBlockNameMATFile{idx});\n' ...
, '      if isfield(loadedData,''SFBInfoStruct'')\n' ...
, '         makeInfo = UpdateMakeInfo(makeInfo,loadedData.SFBInfoStruct);\n' ...
, '         clear loadedData;\n' ...
, '      end\n' ...
, '   end\n' ...
, 'end\n' ...
 ] ) ...
 ];

sfBuilderUpdateMakeInfoFcn = sprintf( [ '\n' ...
, 'function updatedMakeInfo = UpdateMakeInfo(makeInfo,SFBInfoStruct)\n' ...
, 'updatedMakeInfo = {};\n' ...
, 'if isfield(makeInfo,''includePath'')\n' ...
, '   if isfield(SFBInfoStruct,''includePath'')\n' ...
, '      updatedMakeInfo.includePath = {makeInfo.includePath{:} SFBInfoStruct.includePath{:}};\n' ...
, '   else\n' ...
, '      updatedMakeInfo.includePath = {makeInfo.includePath{:}};\n' ...
, '   end\n' ...
, 'end\n' ...
, 'if isfield(makeInfo,''sourcePath'')\n' ...
, '   if isfield(SFBInfoStruct,''sourcePath'')\n' ...
, '      updatedMakeInfo.sourcePath = {makeInfo.sourcePath{:} SFBInfoStruct.sourcePath{:}};\n' ...
, '   else\n' ...
, '      updatedMakeInfo.sourcePath = {makeInfo.sourcePath{:}};\n' ...
, '   end\n' ...
, 'end\n' ...
, 'if isfield(makeInfo,''linkLibsObjs'')\n' ...
, '   if isfield(SFBInfoStruct,''additionalLibraries'')\n' ...
, '      updatedMakeInfo.linkLibsObjs = {makeInfo.linkLibsObjs{:} SFBInfoStruct.additionalLibraries{:}};\n' ...
, '   else\n' ...
, '      updatedMakeInfo.linkLibsObjs = {makeInfo.linkLibsObjs{:}};\n' ...
, '   end\n' ...
, 'end\n' ...
 ] );

fileName = 'rtwmakecfg.m';

if ( exist( fullfile( pwd, fileName ), 'file' ) == 2 )
[ fileHandler, ~ ] = fopen( fileName, 'r' );
if ( fileHandler ==  - 1 )
DAStudio.error( 'Simulink:SFunctionBuilder:CouldNotOpenRTWMAKECFGFileForRead', fileName );
end 
fileData = fread( fileHandler, '*char' )';
fclose( fileHandler );
if ( isempty( regexp( fileData, sfBuilderInsertTag, 'end', 'once' ) ) )
DAStudio.error( 'Simulink:SFunctionBuilder:RTWMAKECFGFileNotGeneratedBySFunction' );
end 
else 
[ fileHandler, ~ ] = fopen( fileName, 'w' );
if ( fileHandler ==  - 1 )
DAStudio.error( 'Simulink:SFunctionBuilder:CouldNotOpenRTWMAKECFGFileForWrite', fileName );
end 
fwrite( fileHandler, [ titleForRTWMAKECFG, customBodyForRTWMAKECFG, sfBuilderUpdateMakeInfoFcn ] );
fclose( fileHandler );
end 

end 

function simStructStr = getSimStructString( UseSimStruct )
simStructStr = '';
if ( UseSimStruct )
simStructStr = 'S, ';
end 
end 

function paramStr = SimStructParamStr( UseSimStruct )



paramStr = '';
if ( UseSimStruct )
paramStr = 'SimStruct *S,<seprTag>';
end 
end 

function TLCSimStructString = getTLCSimStructStr( UseSimStruct )
TLCSimStructString = '';
if ( UseSimStruct )
TLCSimStructString = ', %<s>';
end 
end 







function fcnPrototype = genOutputWrapper( NumberOfInputPorts, NumberOfOutputPorts, NumParams, NumDStates, NumCStates, NumPWorks, fcnType, sfName, FlagDynSizedInput, FlagDynSizedOutput, idxDynSizedInput, idxDynSizedOutput, IsInBusBased, IsOutBusBased, InIsSigned, OutIsSigned, isAccel, InWordLength, InPortName, InDataType, InBusName, OutWordLength, OutPortName, OutDataType, OutBusName, ParameterDataType, ParameterName, directFeed, UseSimStruct )

fcnPrototypeOpenning = [ 'void ', sfName, '_', fcnType, '_wrapper(' ];
if ( isAccel == 1 )
fcnPrototypeOpenning = [ 'void ', sfName, '_', fcnType, '_wrapper_accel(' ];
elseif ( isAccel == 2 )
fcnPrototypeOpenning = [ sfName, '_', fcnType, '_wrapper(' ];
end 




declareU = '';
declareUAccel = '';
if ( directFeed )
mskFP = strcmp( InDataType, 'fixpt' );
mskCFP = strcmp( InDataType, 'cfixpt' );
if ( any( ( mskFP | mskCFP ) & InWordLength > 64 ) )
DAStudio.error( 'Simulink:SFunctionBuilder:DatatypeLengthExceedsLimit' );
end 
keywordT = cell( 1, NumberOfInputPorts );
keywordT( ( mskFP | mskCFP ) & InWordLength <= 64 ) = { 'int64_T' };
keywordT( ( mskFP | mskCFP ) & InWordLength <= 32 ) = { 'int32_T' };
keywordT( ( mskFP | mskCFP ) & InWordLength <= 16 ) = { 'int16_T' };
keywordT( ( mskFP | mskCFP ) & InWordLength <= 8 ) = { 'int8_T' };
keywordT( ( mskFP | mskCFP ) & ~InIsSigned ) = cellfun( @( x )[ 'u', x ], keywordT( ( mskFP | mskCFP ) & ~InIsSigned ), 'UniformOutput', false );
keywordT( mskCFP ) = cellfun( @( x )[ 'c', x ], keywordT( mskCFP ), 'UniformOutput', false );
keywordT( ~( mskFP | mskCFP ) & IsInBusBased ) = InBusName( ~( mskFP | mskCFP ) & IsInBusBased );
keywordT( ~( mskFP | mskCFP ) & ~IsInBusBased ) = InDataType( ~( mskFP | mskCFP ) & ~IsInBusBased );

declareU = cellfun( @( x, y )sprintf( 'const %s *%s,<seprTag>', x, y ), keywordT, InPortName, 'UniformOutput', false );
if ( isAccel == 1 )
declareU( ~( mskFP | mskCFP ) & IsInBusBased ) = cellfun( @( x, y )sprintf( 'const void *%s, void *__%sBUS,<seprTag>', x, y ),  ...
InPortName( ~( mskFP | mskCFP ) & IsInBusBased ), InPortName( ~( mskFP | mskCFP ) & IsInBusBased ), 'UniformOutput', false );
end 
declareU = [ declareU{ : } ];

declareUAccel = cell( 1, NumberOfInputPorts );
declareUAccel( IsInBusBased ) = cellfun( @( x, y )sprintf( '(%s *) __%sBUS,<seprTag>', x, y ), InBusName( IsInBusBased ), InPortName( IsInBusBased ), 'UniformOutput', false );
declareUAccel( ~IsInBusBased ) = cellfun( @( x )sprintf( '%s,<seprTag>', x ), InPortName( ~IsInBusBased ), 'UniformOutput', false );
declareUAccel = [ declareUAccel{ : } ];
end 




mskFP = strcmp( OutDataType, 'fixpt' );
mskCFP = strcmp( OutDataType, 'cfixpt' );
if ( any( ( mskFP | mskCFP ) & OutWordLength > 64 ) )
DAStudio.error( 'Simulink:SFunctionBuilder:DatatypeLengthExceedsLimit' );
end 
keywordT = cell( 1, NumberOfOutputPorts );
keywordT( ( mskFP | mskCFP ) & OutWordLength <= 64 ) = { 'int64_T' };
keywordT( ( mskFP | mskCFP ) & OutWordLength <= 32 ) = { 'int32_T' };
keywordT( ( mskFP | mskCFP ) & OutWordLength <= 16 ) = { 'int16_T' };
keywordT( ( mskFP | mskCFP ) & OutWordLength <= 8 ) = { 'int8_T' };
keywordT( ( mskFP | mskCFP ) & ~OutIsSigned ) = cellfun( @( x )[ 'u', x ], keywordT( ( mskFP | mskCFP ) & ~OutIsSigned ), 'UniformOutput', false );
keywordT( mskCFP ) = cellfun( @( x )[ 'c', x ], keywordT( mskCFP ), 'UniformOutput', false );
keywordT( ~( mskFP | mskCFP ) & IsOutBusBased ) = OutBusName( ~( mskFP | mskCFP ) & IsOutBusBased );
keywordT( ~( mskFP | mskCFP ) & ~IsOutBusBased ) = OutDataType( ~( mskFP | mskCFP ) & ~IsOutBusBased );

declareY = cellfun( @( x, y )sprintf( '%s *%s,<seprTag>', x, y ), keywordT, OutPortName, 'UniformOutput', false );
if ( isAccel == 1 )
declareY( ~( mskFP | mskCFP ) & IsOutBusBased ) = cellfun( @( x, y )sprintf( 'void *%s, void *__%sBUS,<seprTag>', x, y ),  ...
OutPortName( ~( mskFP | mskCFP ) & IsOutBusBased ), OutPortName( ~( mskFP | mskCFP ) & IsOutBusBased ), 'UniformOutput', false );
end 
declareY = [ declareY{ : } ];

declareYAccel = cell( 1, NumberOfInputPorts );
declareYAccel( IsOutBusBased ) = cellfun( @( x, y )sprintf( '(%s *) __%sBUS,<seprTag>', x, y ), OutBusName( IsOutBusBased ), OutPortName( IsOutBusBased ), 'UniformOutput', false );
declareYAccel( ~IsOutBusBased ) = cellfun( @( x )sprintf( '%s,<seprTag>', x ), OutPortName( ~IsOutBusBased ), 'UniformOutput', false );
declareYAccel = [ declareYAccel{ : } ];

varDStates = '';
varDStatesAccel = '';
if ( NumDStates ~= 0 )
varDStates = 'const real_T *xD,<seprTag>';
varDStatesAccel = 'xD,<seprTag>';
end 

varCStates = '';
varCStatesAccel = '';
if ( NumCStates ~= 0 )
varCStates = 'const real_T *xC,<seprTag>';
varCStatesAccel = 'xC,<seprTag>';
end 

varPWorks = '';
varPWorksAccel = '';
if ( NumPWorks ~= 0 )
varPWorks = 'void **pW,<seprTag>';
varPWorksAccel = 'pW,<seprTag>';
end 

varParams = '';
varParamsAccel = '';
if ( NumParams ~= 0 )
tempCellToPrint = [ ParameterDataType;ParameterName;num2cell( 0:NumParams - 1 ) ];
varParams = sprintf( 'const %s *%s, const int_T p_width%d,<seprTag>', tempCellToPrint{ : } );
tempCellToPrint = [ ParameterName;num2cell( 0:NumParams - 1 ) ];
varParamsAccel = sprintf( '%s, p_width%d,<seprTag>', tempCellToPrint{ : } );
end 

portWidths = '';
portWidthsAccel = '';
if ( FlagDynSizedOutput )
portWidths = sprintf( [ 'const int_T y_%d_width,<seprTag>' ], idxDynSizedOutput( : ) - 1 );
portWidthsAccel = sprintf( [ 'y_%d_width,<seprTag>' ], idxDynSizedOutput( : ) - 1 );
end 
if ( FlagDynSizedInput && directFeed )
portWidths = [ portWidths, sprintf( [ 'const int_T u_%d_width,<seprTag>' ], idxDynSizedInput( : ) - 1 ) ];
portWidthsAccel = [ portWidthsAccel, sprintf( [ 'u_%d_width,<seprTag>' ], idxDynSizedInput( : ) - 1 ) ];
end 

if ( isAccel ~= 2 )
fcnPrototypeList = [ declareU, declareY, varDStates, varCStates, varPWorks ...
, varParams, portWidths, SimStructParamStr( UseSimStruct ) ];
else 
fcnPrototypeList = [ declareUAccel, declareYAccel, varDStatesAccel, varCStatesAccel ...
, varPWorksAccel, varParamsAccel, portWidthsAccel, SimStructParamStr( UseSimStruct ) ];
end 

if ( ~isempty( fcnPrototypeList ) )
fcnPrototypeList( end  - numel( '<seprTag>' ):end  ) = [  ];
else 
fcnPrototypeList = 'void';
end 

fcnPrototypeList = regexprep( fcnPrototypeList, '<seprTag>', '\n\t\t\t' );
fcnPrototype = [ fcnPrototypeOpenning, fcnPrototypeList, ')' ];
end 








function [ busAccelCheckStr, idxForExtern ] = genExternDeclarationTLCForBus( sfName, NumberOfInputPorts, InPortName, InBusName, IsInBusBased, NumberOfOutputPorts, OutPortName, OutBusName, IsOutBusBased, NumDiscStates, NumContStates,  ...
FlagGenHeaderFile, sfunBusHeaderFile, bus_Header_List, fcnProtoTypeStartTLC1, fcnProtoTypeStartTLC2, fcnProtoTypeOutputTLC1, fcnProtoTypeOutputTLC2, fcnProtoTypeUpdateTLC1, fcnProtoTypeUpdateTLC2,  ...
fcnProtoTypeDerivativesTLC1, fcnProtoTypeDerivativesTLC2, fcnProtoTypeTerminateTLC1, fcnProtoTypeTerminateTLC2, IsSFunctionInC, FlagGenStartFunction, FlagGenTerminateFunction, inDims, outDims,  ...
fcnProtoTypeUpdate, fcnProtoTypeDerivatives, fcnProtoTypeStart, fcnProtoTypeOutput, fcnProtoTypeTerminate )
wrapperNameAccel = [ sfName, '_accel_wrapper' ];
if ( FlagGenHeaderFile )
busHeaderTLCList = sprintf( '#include "%s"\n', sfunBusHeaderFile );
else 
busHeaderTLCList = bus_Header_List;
end 

tempCellToPrint = { fcnProtoTypeOutputTLC1 };
if ( FlagGenStartFunction )
tempCellToPrint = [ { fcnProtoTypeStartTLC1 }, tempCellToPrint ];
end 
if ( NumDiscStates > 0 )
tempCellToPrint = [ tempCellToPrint, { fcnProtoTypeUpdateTLC1 } ];
end 
if ( NumContStates > 0 )
tempCellToPrint = [ tempCellToPrint, { fcnProtoTypeDerivativesTLC1 } ];
end 
if ( FlagGenTerminateFunction )
tempCellToPrint = [ tempCellToPrint, { fcnProtoTypeTerminateTLC1 } ];
end 


externPrefix = sprintf( [ '    #ifdef __cplusplus\n' ...
, '    #define SFB_EXTERN_C extern "C"\n' ...
, '    #else\n' ...
, '    #define SFB_EXTERN_C extern\n' ...
, '    #endif\n' ] );

busFunctionDeclarations = sprintf( '    SFB_EXTERN_C %s;\n', tempCellToPrint{ : } );

if IsSFunctionInC
sfunLang = 'c';
else 
sfunLang = 'cpp';
end 

busFunctionDeclarations = [  ...
externPrefix ...
, busFunctionDeclarations ...
, sprintf( '    #undef SFB_EXTERN_C\n' ) ...
 ];


ifCheck = GetPaddingUsedIf(  );
busAccelCheckStr = [ sprintf( '  %%if %s\n', ifCheck ) ...
, sprintf( '    %%assign hFileName = "%s"\n', wrapperNameAccel ) ...
, sprintf( [ '    %%assign hFileNameMacro = FEVAL("upper", hFileName)\n' ...
, '    %%openfile hFile = "%%<hFileName>.h"\n' ...
, '    %%selectfile hFile\n' ...
, '    #ifndef _%%<hFileNameMacro>_H_\n' ...
, '    #define _%%<hFileNameMacro>_H_\n' ...
, '\n' ...
, '    #ifdef MATLAB_MEX_FILE\n' ...
, '    #include "tmwtypes.h"\n' ...
, '    #else\n' ...
, '    #include "rtwtypes.h"\n' ...
, '    #endif\n' ] ) ...
, busFunctionDeclarations ...
, sprintf( [ '    #endif\n' ...
, '    %%closefile hFile\n' ...
, '\n' ...
, '    %%assign cFileName = "%s"\n' ], wrapperNameAccel ) ...
, sprintf( [ '    %%openfile cFile = "%%<cFileName>.%s"\n' ...
, '    %%selectfile cFile\n' ...
, '    #include <string.h>\n' ...
, '    #ifdef MATLAB_MEX_FILE\n' ...
, '    #include "tmwtypes.h"\n' ...
, '    #else\n' ...
, '    #include "rtwtypes.h"\n' ...
, '    #endif\n' ...
, '    #include "%%<hFileName>.h"\n' ...
, '    %s\n' ], sfunLang, busHeaderTLCList ) ...
 ];

idxForExtern = length( busAccelCheckStr );


inTLC = { [ '\n    %%assign dTypeId = LibBlockInputSignalDataTypeId(%d)\n' ...
, '    %%<SLibAssignSLStructToUserStruct(dTypeId, "(*(%s *) __%sBUS)", "(char *) %s", 0)>\n' ],  ...
[ '\n    %%assign dTypeId = LibBlockInputSignalDataTypeId(%d)\n' ...
, '   %%assign width = LibBlockInputSignalWidth(%d)\n' ...
, '    %%<SLibAssignSLStructToUserStructND(dTypeId,width, "((%s *) __%sBUS)", "(char *) %s",Matrix(1,1)[0], 0, 0)>\n' ] };

outTLC = { [ '\n    %%assign dTypeId = LibBlockOutputSignalDataTypeId(%d)\n' ...
, '    %%<SLibAssignUserStructToSLStruct(dTypeId, "(char *) %s", "(*(%s *) __%sBUS)",  0)>\n' ],  ...
[ '\n    %%assign dTypeId = LibBlockOutputSignalDataTypeId(%d)\n' ...
, '    %%assign width = LibBlockOutputSignalWidth(%d)\n' ...
, '    %%<SLibAssignUserStructToSLStructND(dTypeId,width, "(char *) %s", "((%s *) __%sBUS)",Matrix(1,1)[0], 0, 0)>\n' ] };

fcnStartBody = '';
if ( FlagGenStartFunction )
fcnStartBody = [ sprintf( '    %s{\n', fcnProtoTypeStartTLC1 ) ...
, sprintf( '    %s;\n', fcnProtoTypeStartTLC2 ) ...
, sprintf( '    }\n' ) ];
end 

fcnOutputBody = sprintf( '    %s{\n', fcnProtoTypeOutputTLC1 );
portIdNum = num2cell( 0:NumberOfInputPorts - 1 );
tempCellToPrint = { [ portIdNum( IsInBusBased );InBusName( IsInBusBased );InPortName( IsInBusBased );InPortName( IsInBusBased ) ],  ...
[ portIdNum( IsInBusBased );portIdNum( IsInBusBased );InBusName( IsInBusBased );InPortName( IsInBusBased );InPortName( IsInBusBased ) ] };

fcnOutputBody =  ...
[ printFunctionToTLC( fcnOutputBody, inTLC, tempCellToPrint, inDims, IsInBusBased ), sprintf( '    %s;\n', fcnProtoTypeOutputTLC2 ) ];

fcnUpdateBody = '';
if ( NumDiscStates > 0 )
fcnUpdateBody = [ sprintf( '\n    %s{\n', fcnProtoTypeUpdateTLC1 ) ...
, printFunctionToTLC( fcnUpdateBody, inTLC, tempCellToPrint, inDims, IsInBusBased ), sprintf( '    %s;\n', fcnProtoTypeUpdateTLC2 ) ];
end 

fcnDerivativesBody = '';
if ( NumContStates > 0 )
fcnDerivativesBody = [ sprintf( '\n    %s{\n', fcnProtoTypeDerivativesTLC1 ) ...
, printFunctionToTLC( fcnDerivativesBody, inTLC, tempCellToPrint, inDims, IsInBusBased ), sprintf( '    %s;\n', fcnProtoTypeDerivativesTLC2 ) ];
end 

portIdNum = num2cell( 0:NumberOfOutputPorts - 1 );
tempCellToPrint = { [ portIdNum( IsOutBusBased );OutPortName( IsOutBusBased );OutBusName( IsOutBusBased );OutPortName( IsOutBusBased ) ],  ...
[ portIdNum( IsOutBusBased );portIdNum( IsOutBusBased );OutPortName( IsOutBusBased );OutBusName( IsOutBusBased );OutPortName( IsOutBusBased ) ] };

fcnOutputBody =  ...
[ printFunctionToTLC( fcnOutputBody, outTLC, tempCellToPrint, outDims, IsOutBusBased ), sprintf( '    }\n' ) ];

if ( NumDiscStates > 0 )
fcnUpdateBody =  ...
[ printFunctionToTLC( fcnUpdateBody, outTLC, tempCellToPrint, outDims, IsOutBusBased ), sprintf( '    }\n' ) ];
end 

if ( NumContStates > 0 )
fcnDerivativesBody =  ...
[ printFunctionToTLC( fcnDerivativesBody, outTLC, tempCellToPrint, outDims, IsOutBusBased ), sprintf( '    }\n' ) ];
end 

fcnTerminateBody = '';
if ( FlagGenTerminateFunction )
fcnTerminateBody = [ sprintf( '    %s{\n', fcnProtoTypeTerminateTLC1 ) ...
, sprintf( '    %s;\n', fcnProtoTypeTerminateTLC2 ) ...
, sprintf( '    }\n' ) ];
end 

busAccelCheckStr = [ busAccelCheckStr, fcnStartBody, fcnOutputBody, fcnUpdateBody, fcnDerivativesBody, fcnTerminateBody ];
busAccelCheckStr = [ busAccelCheckStr ...
, sprintf( [ '\n    %%closefile cFile\n' ...
, '\n' ...
, '    %%<LibAddToCommonIncludes("%%<hFileName>.h")>\n' ...
, '\n' ...
, '  %%else\n' ...
 ] ) ...
 ];





tempCellToPrint = { makeCgenWrapper( fcnProtoTypeOutput ) };
if ( FlagGenStartFunction )
tempCellToPrint = [ { makeCgenWrapper( fcnProtoTypeStart ) }, tempCellToPrint ];
end 
if ( NumDiscStates > 0 )
tempCellToPrint = [ tempCellToPrint, { makeCgenWrapper( fcnProtoTypeUpdate ) } ];
end 
if ( NumContStates > 0 )
tempCellToPrint = [ tempCellToPrint, { makeCgenWrapper( fcnProtoTypeDerivatives ) } ];
end 
if ( FlagGenTerminateFunction )
tempCellToPrint = [ tempCellToPrint, { makeCgenWrapper( fcnProtoTypeTerminate ) } ];
end 

busFunctionDeclarations = sprintf( '    SFB_EXTERN_C %s;\n', tempCellToPrint{ : } );
busFunctionDeclarations = [  ...
externPrefix ...
, busFunctionDeclarations ...
, sprintf( '    #undef SFB_EXTERN_C\n' ) ...
 ];



if strcmp( sfunLang, 'cpp' )
cgen_wrapper_name = [ sfName, '_cgen_wrapper' ];

busAccelCheckStr = [ busAccelCheckStr ...
, sprintf( '    %%assign hFileName = "%s"\n', cgen_wrapper_name ) ...
, sprintf( [ '    %%assign hFileNameMacro = FEVAL("upper", hFileName)\n' ...
, '    %%openfile hFile = "%%<hFileName>.h"\n' ...
, '    %%selectfile hFile\n' ...
, '    #ifndef _%%<hFileNameMacro>_H_\n' ...
, '    #define _%%<hFileNameMacro>_H_\n' ...
, '\n' ...
, '    #ifdef MATLAB_MEX_FILE\n' ...
, '    #include "tmwtypes.h"\n' ...
, '    #else\n' ...
, '    #include "rtwtypes.h"\n' ...
, '    #endif\n' ...
, '    %s\n' ], busHeaderTLCList ) ...
, busFunctionDeclarations ...
, sprintf( [ '    #endif\n' ...
, '    %%closefile hFile\n' ...
, '\n' ...
, '    %%assign cFileName = "%s"\n' ], cgen_wrapper_name ) ...
, sprintf( [ '    %%openfile cFile = "%%<cFileName>.%s"\n' ...
, '    %%selectfile cFile\n' ...
, '    #include <string.h>\n' ...
, '    #ifdef MATLAB_MEX_FILE\n' ...
, '    #include "tmwtypes.h"\n' ...
, '    #else\n' ...
, '    #include "rtwtypes.h"\n' ...
, '    #endif\n' ...
, '    #include "%%<hFileName>.h"\n' ], sfunLang ) ...
 ];

if ~isempty( fcnStartBody )
fcnStartBody = sprintf( [ '\n\textern %s;' ], fcnProtoTypeStart );
end 

if ~isempty( fcnOutputBody )
fcnOutputBody = sprintf( [ '\n\textern %s;' ], fcnProtoTypeOutput );
end 

if ~isempty( fcnUpdateBody )
fcnUpdateBody = sprintf( [ '\n\textern %s;' ], fcnProtoTypeUpdate );
end 

if ~isempty( fcnDerivativesBody )
fcnDerivativesBody = sprintf( [ '\n\textern %s;' ], fcnProtoTypeDerivatives );
end 

if ~isempty( fcnTerminateBody )
fcnTerminateBody = sprintf( [ '\n\textern %s;' ], fcnProtoTypeTerminate );
end 

externDecls = [ fcnStartBody, fcnOutputBody, fcnUpdateBody, fcnDerivativesBody, fcnTerminateBody ];

if ~isempty( fcnStartBody )
fcnStartBody = sprintf( [ '\n\t %s {\n\t%s;\n\t}' ], makeCgenWrapper( fcnProtoTypeStart ), fcnProtoTypeStartTLC2 );
end 

if ~isempty( fcnOutputBody )
fcnOutputBody = sprintf( [ '\n\t %s {\n\t%s;\n\t}' ], makeCgenWrapper( fcnProtoTypeOutput ), fcnProtoTypeOutputTLC2 );
end 

if ~isempty( fcnUpdateBody )
fcnUpdateBody = sprintf( [ '\n\t %s {\n\t%s;\n\t}' ], makeCgenWrapper( fcnProtoTypeUpdate ), fcnProtoTypeUpdateTLC2 );
end 

if ~isempty( fcnDerivativesBody )
fcnDerivativesBody = sprintf( [ '\n\t %s {\n\t%s;\n\t}' ], makeCgenWrapper( fcnProtoTypeDerivatives ), fcnProtoTypeDerivativesTLC2 );
end 

if ~isempty( fcnTerminateBody )
fcnTerminateBody = sprintf( [ '\n\t %s {\n\t%s;\n\t}' ], makeCgenWrapper( fcnProtoTypeTerminate ), fcnProtoTypeTerminateTLC2 );
end 

busAccelCheckStr = [ busAccelCheckStr, externDecls, fcnStartBody, fcnOutputBody, fcnUpdateBody, fcnDerivativesBody, fcnTerminateBody ];
busAccelCheckStr = [ busAccelCheckStr ...
, sprintf( [ '\n    %%closefile cFile\n' ...
, '\n' ...
, '    %%<LibAddToCommonIncludes("%%<hFileName>.h")>\n' ...
, '\n' ...
 ] ) ...
 ];
end 

end 



function funcDecl = makeCgenWrapper( funcDecl )

if ~isempty( funcDecl )

idx = findstr( funcDecl, '(' );

funcDecl = [ funcDecl( 1:idx( 1 ) - 1 ), '_cgen', funcDecl( idx( 1 ):end  ) ];

end 

end 



function fcnBody = printFunctionToTLC( fcnBody, tlcInfo, cellToPrint, dims, isBusUsed )
numBuses = 0;
for it = 1:numel( dims )
if ( ~isempty( cellToPrint{ 1 } ) || ~isempty( cellToPrint{ 2 } ) )
if isBusUsed( it )
numBuses = numBuses + 1;
if dims( it ) == 1
fcnBody = [ fcnBody ...
, sprintf( [ tlcInfo{ 1 } ], cellToPrint{ 1 }{ :, numBuses } ) ];
else 
fcnBody = [ fcnBody ...
, sprintf( [ tlcInfo{ 2 } ], cellToPrint{ 2 }{ :, numBuses } ) ];
end 
end 
end 
end 
end 



function paramsForWrapper = getParamFromAccelWrapper( sfName, fcnType, fcnProtoType )

fcnNameLen = length( [ 'void ', sfName, '_', fcnType, '_wrapper_accel' ] );
paramsForWrapper = fcnProtoType( fcnNameLen + 1:end  );

end 






function fcnPrototype = genStartTerminateWrapper( NumParams, NumCStates, NumDStates, NumPWorks, fcnType, sfName, ParameterDataType, ParameterName, UseSimStruct, isAccel )
fcnName = [ sfName, '_', fcnType, '_wrapper' ];
returnTypeStr = 'void ';
if ( isAccel == 1 )

fcnName = [ sfName, '_', fcnType, '_wrapper_accel' ];
elseif ( isAccel == 2 )

returnTypeStr = '';
end 

varDx = '';
varDxAccel = '';
varCState = '';
varCStateAccel = '';
if ( NumCStates ~= 0 )


varCState = 'real_T *xC,<seprTag>';
varCStateAccel = 'xC,<seprTag>';
end 

varDState = '';
varDStateAccel = '';
if ( NumDStates ~= 0 )
varDState = 'real_T *xD,<seprTag>';
varDStateAccel = 'xD,<seprTag>';
end 

varPWorks = '';
varPWorksAccel = '';
if ( NumPWorks ~= 0 )
varPWorks = 'void **pW,<seprTag>';
varPWorksAccel = 'pW,<seprTag>';
end 

varParams = '';
varParamsAccel = '';
if ( NumParams ~= 0 )
tempCellToPrint = [ ParameterDataType;ParameterName;num2cell( 0:NumParams - 1 ) ];
varParams = sprintf( 'const %s *%s, const int_T p_width%d,<seprTag>', tempCellToPrint{ : } );
tempCellToPrint = [ ParameterName;num2cell( 0:NumParams - 1 ) ];
varParamsAccel = sprintf( '%s, p_width%d,<seprTag>', tempCellToPrint{ : } );
end 

if ( isAccel ~= 2 )
fcnArgList = [ varDx, varCState, varDState, varPWorks, varParams, SimStructParamStr( UseSimStruct ) ];
else 
fcnArgList = [ varDxAccel, varCStateAccel, varDStateAccel, varPWorksAccel, varParamsAccel, SimStructParamStr( UseSimStruct ) ];
end 

if ( ~isempty( fcnArgList ) )
fcnArgList( end  - numel( '<seprTag>' ):end  ) = [  ];
elseif ( isAccel ~= 2 )
fcnArgList = 'void';
end 

fcnArgList = regexprep( fcnArgList, '<seprTag>', '\n\t\t\t' );
fcnPrototype = [ returnTypeStr, fcnName, '(', fcnArgList, ')' ];
end 








function fcnPrototype = genStatesWrapper( NumParams, NumStates, NumPWorks, fcnType, state, sfName, InDataType, OutDataType, ParameterDataType, InPortName, OutPortName, ParameterName, InBusName, OutBusName, NumberOfInputPorts, NumberOfOutputPorts, InWordLength, OutWordLength, InIsSigned, OutIsSigned, IsInBusBased, IsOutBusBased, FlagDynSizedInput, FlagDynSizedOutput, idxDynSizedInput, idxDynSizedOutput, UseSimStruct, isAccel )
fcnPrototypeOpenning = sprintf( 'void %s_%s_wrapper(', sfName, fcnType );
if ( isAccel == 1 )

fcnPrototypeOpenning = sprintf( 'void %s_%s_wrapper_accel(', sfName, fcnType );
elseif ( isAccel == 2 )

fcnPrototypeOpenning = sprintf( '%s_%s_wrapper(', sfName, fcnType );
end 




mskFP = strcmp( InDataType, 'fixpt' );
mskCFP = strcmp( InDataType, 'cfixpt' );
if ( any( ~IsInBusBased & ( mskFP | mskCFP ) & InWordLength > 64 ) )
DAStudio.error( 'Simulink:SFunctionBuilder:DatatypeLengthExceedsLimit' );
end 
keywordT = cell( 1, NumberOfInputPorts );
keywordT( ~IsInBusBased & ( mskFP | mskCFP ) & InWordLength <= 64 ) = { 'int64_T' };
keywordT( ~IsInBusBased & ( mskFP | mskCFP ) & InWordLength <= 32 ) = { 'int32_T' };
keywordT( ~IsInBusBased & ( mskFP | mskCFP ) & InWordLength <= 16 ) = { 'int16_T' };
keywordT( ~IsInBusBased & ( mskFP | mskCFP ) & InWordLength <= 8 ) = { 'int8_T' };
keywordT( ~IsInBusBased & ( mskFP | mskCFP ) & ~InIsSigned ) = cellfun( @( x )[ 'u', x ], keywordT( ~IsInBusBased & ( mskFP | mskCFP ) & ~InIsSigned ), 'UniformOutput', false );
keywordT( ~IsInBusBased & mskCFP ) = cellfun( @( x )[ 'c', x ], keywordT( ~IsInBusBased & mskCFP ), 'UniformOutput', false );
keywordT( ~IsInBusBased & ~( mskFP | mskCFP ) ) = InDataType( ~IsInBusBased & ~( mskFP | mskCFP ) );
keywordT( IsInBusBased ) = InBusName( IsInBusBased );

declareU = cellfun( @( x, y )sprintf( 'const %s *%s,<seprTag>', x, y ), keywordT, InPortName, 'UniformOutput', false );
if ( isAccel == 1 )
declareU( IsInBusBased ) = cellfun( @( x, y )sprintf( 'const void *%s, void *__%sBUS,<seprTag>', x, y ), InPortName( IsInBusBased ), InPortName( IsInBusBased ), 'UniformOutput', false );
end 
declareU = [ declareU{ : } ];

declareUAccel = cell( 1, NumberOfInputPorts );
if ( isAccel == 2 )
declareUAccel( IsInBusBased ) = cellfun( @( x, y )sprintf( '(%s *) __%sBUS,<seprTag>', x, y ), InBusName( IsInBusBased ), InPortName( IsInBusBased ), 'UniformOutput', false );
declareUAccel( ~IsInBusBased ) = cellfun( @( x )sprintf( '%s,<seprTag>', x ), InPortName( ~IsInBusBased ), 'UniformOutput', false );
end 
declareUAccel = [ declareUAccel{ : } ];




mskFP = strcmp( OutDataType, 'fixpt' );
mskCFP = strcmp( OutDataType, 'cfixpt' );
if ( any( ~IsOutBusBased & ( mskFP | mskCFP ) & OutWordLength > 64 ) )
DAStudio.error( 'Simulink:SFunctionBuilder:DatatypeLengthExceedsLimit' );
end 
keywordT = cell( 1, NumberOfOutputPorts );
keywordT( ~IsOutBusBased & ( mskFP | mskCFP ) & OutWordLength <= 64 ) = { 'int64_T' };
keywordT( ~IsOutBusBased & ( mskFP | mskCFP ) & OutWordLength <= 32 ) = { 'int32_T' };
keywordT( ~IsOutBusBased & ( mskFP | mskCFP ) & OutWordLength <= 16 ) = { 'int16_T' };
keywordT( ~IsOutBusBased & ( mskFP | mskCFP ) & OutWordLength <= 8 ) = { 'int8_T' };
keywordT( ~IsOutBusBased & ( mskFP | mskCFP ) & ~OutIsSigned ) = cellfun( @( x )[ 'u', x ], keywordT( ~IsOutBusBased & ( mskFP | mskCFP ) & ~OutIsSigned ), 'UniformOutput', false );
keywordT( ~IsOutBusBased & mskCFP ) = cellfun( @( x )[ 'c', x ], keywordT( ~IsOutBusBased & mskCFP ), 'UniformOutput', false );
keywordT( ~IsOutBusBased & ~( mskFP | mskCFP ) ) = OutDataType( ~IsOutBusBased & ~( mskFP | mskCFP ) );
keywordT( IsOutBusBased ) = OutBusName( IsOutBusBased );

declareY = cellfun( @( x, y )sprintf( '%s *%s,<seprTag>', x, y ), keywordT, OutPortName, 'UniformOutput', false );
if ( isAccel == 1 )
declareY( IsOutBusBased ) = cellfun( @( x, y )sprintf( 'void *%s, void *__%sBUS,<seprTag>', x, y ), OutPortName( IsOutBusBased ), OutPortName( IsOutBusBased ), 'UniformOutput', false );
end 
declareY = [ declareY{ : } ];

declareYAccel = cell( 1, NumberOfInputPorts );
if ( isAccel == 2 )
declareYAccel( IsOutBusBased ) = cellfun( @( x, y )sprintf( '(%s *) __%sBUS,<seprTag>', x, y ), OutBusName( IsOutBusBased ), OutPortName( IsOutBusBased ), 'UniformOutput', false );
declareYAccel( ~IsOutBusBased ) = cellfun( @( x )sprintf( '%s,<seprTag>', x ), OutPortName( ~IsOutBusBased ), 'UniformOutput', false );
end 
declareYAccel = [ declareYAccel{ : } ];

varDx = '';
varDxAccel = '';
if ( strcmp( state, 'xC' ) )
varDx = 'real_T *dx,<seprTag>';
varDxAccel = 'dx,<seprTag>';
end 

varState = '';
varStateAccel = '';
if ( NumStates ~= 0 )
varState = sprintf( 'real_T *%s,<seprTag>', state );
varStateAccel = sprintf( '%s,<seprTag>', state );
end 

varPWork = '';
varPWorkAccel = '';
if ( NumPWorks ~= 0 )
varPWork = 'void **pW,<seprTag>';
varPWorkAccel = 'pW,<seprTag>';
end 

varParams = '';
varParamsAccel = '';
if ( NumParams ~= 0 )
tempCellToPrint = [ ParameterDataType;ParameterName;num2cell( 0:NumParams - 1 ) ];
varParams = sprintf( 'const %s *%s, const int_T p_width%d,<seprTag>', tempCellToPrint{ : } );
tempCellToPrint = [ ParameterName;num2cell( 0:NumParams - 1 ) ];
varParamsAccel = sprintf( '%s, p_width%d,<seprTag>', tempCellToPrint{ : } );
end 


portWidths = '';
portWidthsAccel = '';
if ( FlagDynSizedOutput )
portWidths = sprintf( [ 'const int_T y_%d_width,<seprTag>' ], idxDynSizedOutput( : ) - 1 );
portWidthsAccel = sprintf( [ 'y_%d_width,<seprTag>' ], idxDynSizedOutput( : ) - 1 );
end 
if ( FlagDynSizedInput )
portWidths = [ portWidths, sprintf( [ 'const int_T u_%d_width,<seprTag>' ], idxDynSizedInput( : ) - 1 ) ];
portWidthsAccel = [ portWidthsAccel, sprintf( [ 'u_%d_width,<seprTag>' ], idxDynSizedInput( : ) - 1 ) ];
end 

if ( isAccel ~= 2 )
fcnPrototypeList = [ declareU, declareY, varDx, varState, varPWork, varParams ...
, portWidths, SimStructParamStr( UseSimStruct ) ];
else 
fcnPrototypeList = [ declareUAccel, declareYAccel, varDxAccel, varStateAccel ...
, varPWorkAccel, varParamsAccel, portWidthsAccel, SimStructParamStr( UseSimStruct ) ];
end 

if ( ~isempty( fcnPrototypeList ) )
fcnPrototypeList( end  - numel( '<seprTag>' ):end  ) = [  ];
else 
fcnPrototypeList = 'void';
end 

fcnPrototypeList = regexprep( fcnPrototypeList, '<seprTag>', '\n\t\t\t' );
fcnPrototype = [ fcnPrototypeOpenning, fcnPrototypeList, ')' ];
end 







function fcnCall = genFunctionCallStartTerminate( NParams, NCStates, NDStates, NPWorks, fcnType, sfName, ParameterName, UseSimStruct, sfunIsRowMajor )
fcnName = [ sfName, '_', fcnType, '_wrapper' ];
fcnArgList = '';
if ( NCStates ~= 0 )

fcnArgList = [ fcnArgList, 'xC, ' ];
end 

if ( NDStates ~= 0 )
fcnArgList = [ fcnArgList, 'xD, ' ];
end 

if ( NPWorks ~= 0 )
fcnArgList = [ fcnArgList, 'pW, ' ];
end 

Params = '';
tempCellToPrint = [ ParameterName;num2cell( 0:NParams - 1 ) ];
if ( ~isempty( tempCellToPrint ) )
if ( sfunIsRowMajor )
Params = sprintf( '%s_t, p_width%d, ', tempCellToPrint{ : } );
else 
Params = sprintf( '%s, p_width%d, ', tempCellToPrint{ : } );
end 
end 
fcnArgList = [ fcnArgList, Params ];

fcnArgList = [ fcnArgList, getSimStructString( UseSimStruct ) ];
if ( ~isempty( fcnArgList ) )
fcnArgList( end  - 1:end  ) = [  ];
end 
fcnCall = [ fcnName, '(', fcnArgList, ');' ];

end 






function nestedInScalarBusMap = checkIfNestedBusArray( businfoStruct, InPortName, OutPortName, IsInBusBased, IsOutBusBased, InDimsAbs, OutDimsAbs )

nestedInScalarBusMap = containers.Map(  );

inputIdx = 1;
outputIdx = 1;
idxInputBuses = find( IsInBusBased == 1 );
idxOutputBuses = find( IsOutBusBased == 1 );

for i = 1:length( businfoStruct )
isInput = businfoStruct( i ).isinput_port;

if isInput
isNestedBusArray = businfoStruct( i ).bus_structure( 1 ).isNestedBusArray;
width = prod( InDimsAbs{ idxInputBuses( inputIdx ) } );
tempBusName = sprintf( '_%sBUS', InPortName{ idxInputBuses( inputIdx ) } );
if isequal( width, 1 )
if isNestedBusArray
nestedInScalarBusMap( tempBusName ) = '';
else 
nestedInScalarBusMap( tempBusName ) = '&';
end 
end 

inputIdx = inputIdx + 1;
end 
end 

for i = 1:length( businfoStruct )
isOutput = ~businfoStruct( i ).isinput_port;

if isOutput
isNestedBusArray = businfoStruct( i ).bus_structure( 1 ).isNestedBusArray;
width = prod( OutDimsAbs{ idxOutputBuses( outputIdx ) } );
tempBusName = sprintf( '_%sBUS', OutPortName{ idxOutputBuses( outputIdx ) } );
if isequal( width, 1 )
if isNestedBusArray
nestedInScalarBusMap( tempBusName ) = '';
else 
nestedInScalarBusMap( tempBusName ) = '&';
end 
end 

outputIdx = outputIdx + 1;
end 
end 

end 






function fcnCall = genFunctionCall( InDimsAbs, OutDimsAbs, NParams, NStates, NPWorks, fcnType, state, sfName, NumberOfInputPorts, NumberOfOutputPorts, InPortName, OutPortName, ParameterName, IsInBusBased, IsOutBusBased, FlagDynSizedInput, FlagDynSizedOutput, idxDynSizedInput, idxDynSizedOutput, directFeed, UseSimStruct, sfunIsRowMajor, isNestedInScalarBusMap )

fcnCallOpenning = [ sfName, '_', fcnType, '_wrapper(' ];




declareU = cell( 1, NumberOfInputPorts );


declareU( IsInBusBased == 1 & cellfun( @( x )any( x > 1 ), InDimsAbs ) ) = cellfun( @( x )sprintf( '_%sBUS, ', x ), InPortName( IsInBusBased == 1 & cellfun( @( x )any( x > 1 ), InDimsAbs ) ), 'UniformOutput', false );


declareU( IsInBusBased == 1 & cellfun( @( x )prod( x ) == 1, InDimsAbs ) ) = cellfun( @( x )sprintf( '%s_%sBUS, ', isNestedInScalarBusMap( sprintf( '_%sBUS', x ) ), x ), InPortName( IsInBusBased == 1 & cellfun( @( x )prod( x ) == 1, InDimsAbs ) ), 'UniformOutput', false );

declareU( ~IsInBusBased & ~sfunIsRowMajor ) = cellfun( @( x )sprintf( '%s, ', x ), InPortName( ~IsInBusBased & ~sfunIsRowMajor ), 'UniformOutput', false );
declareU( ~IsInBusBased & sfunIsRowMajor ) = cellfun( @( x )sprintf( '%s_t, ', x ), InPortName( ~IsInBusBased & sfunIsRowMajor ), 'UniformOutput', false );
declareU = [ declareU{ : } ];




declareY = cell( 1, NumberOfOutputPorts );

declareY( IsOutBusBased == 1 & cellfun( @( x )prod( x ) > 1, OutDimsAbs ) ) = cellfun( @( x )sprintf( '_%sBUS, ', x ), OutPortName( IsOutBusBased == 1 & cellfun( @( x )prod( x ) > 1, OutDimsAbs ) ), 'UniformOutput', false );

declareY( IsOutBusBased == 1 & cellfun( @( x )prod( x ) == 1, OutDimsAbs ) ) = cellfun( @( x )sprintf( '%s_%sBUS, ', isNestedInScalarBusMap( sprintf( '_%sBUS', x ) ), x ), OutPortName( IsOutBusBased == 1 & cellfun( @( x )prod( x ) == 1, OutDimsAbs ) ), 'UniformOutput', false );

declareY( ~IsOutBusBased & ~sfunIsRowMajor ) = cellfun( @( x )sprintf( '%s, ', x ), OutPortName( ~IsOutBusBased & ~sfunIsRowMajor ), 'UniformOutput', false );
declareY( ~IsOutBusBased & sfunIsRowMajor ) = cellfun( @( x )sprintf( '%s_t, ', x ), OutPortName( ~IsOutBusBased & sfunIsRowMajor ), 'UniformOutput', false );
declareY = [ declareY{ : } ];
fcnCall = [ fcnCallOpenning, declareU, declareY ];

if ( strcmp( state, 'xC' ) )
fcnCall = [ fcnCall, 'dx, ' ];
end 
DStates = state;
if ( NStates > 0 )
fcnCall = [ fcnCall, DStates, ', ' ];
end 

if ( NPWorks > 0 )
fcnCall = [ fcnCall, 'pW, ' ];
end 

tempCellToPrint = [ ParameterName;num2cell( 0:NParams - 1 ) ];
if ( ~sfunIsRowMajor )
Params = sprintf( '%s, p_width%d, ', tempCellToPrint{ : } );
else 
Params = sprintf( '%s_t, p_width%d, ', tempCellToPrint{ : } );
end 
fcnCall = [ fcnCall, Params ];

portwidths = '';
if ( FlagDynSizedOutput )
portwidths = [ portwidths, sprintf( [ 'y_%d_width, ' ], idxDynSizedOutput( : ) - 1 ) ];
end 
if ( FlagDynSizedInput && directFeed )
portwidths = [ portwidths, sprintf( [ 'u_%d_width, ' ], idxDynSizedInput( : ) - 1 ) ];
end 

fcnCall = [ fcnCall, portwidths, getSimStructString( UseSimStruct ) ];
if ( numel( fcnCall ) ~= numel( fcnCallOpenning ) )
fcnCall( end  - 1:end  ) = [  ];
end 
fcnCall = [ fcnCall, ');' ];

end 





function fcnCallOut = genFunctionCallOutput( InDimsAbs, OutDimsAbs, NumberOfInputPorts, NumberOfOutputPorts, IsInBusBased, IsOutBusBased,  ...
NParams, NDStates, NCStates, NPWorks, fcnType, sfName, FlagDynSizedOutput, FlagDynSizedInput, idxDynSizedInput, idxDynSizedOutput, directFeed, InPortName, OutPortName, ParameterName, UseSimStruct, sfunIsRowMajor, isNestedInScalarBusMap )

portwidths = '';
if ( FlagDynSizedOutput )
portwidths = [ portwidths, sprintf( [ 'y_%d_width, ' ], idxDynSizedOutput( : ) - 1 ) ];
end 
if ( FlagDynSizedInput && directFeed )
portwidths = [ portwidths, sprintf( [ 'u_%d_width, ' ], idxDynSizedInput( : ) - 1 ) ];
end 

fcnCallOpenning = [ sfName, '_', fcnType, '_wrapper(' ];



declareU = '';
if ( directFeed )
declareUCell = cell( 1, NumberOfInputPorts );


declareUCell( IsInBusBased == 1 & cellfun( @( x )prod( x ) > 1, InDimsAbs ) ) = cellfun( @( x )sprintf( '_%sBUS, ', x ), InPortName( IsInBusBased == 1 & cellfun( @( x )prod( x ) > 1, InDimsAbs ) ), 'UniformOutput', false );


declareUCell( IsInBusBased == 1 & cellfun( @( x )prod( x ) == 1, InDimsAbs ) ) = cellfun( @( x )sprintf( '%s_%sBUS, ', isNestedInScalarBusMap( sprintf( '_%sBUS', x ) ), x ), InPortName( IsInBusBased == 1 & cellfun( @( x )prod( x ) == 1, InDimsAbs ) ), 'UniformOutput', false );

declareUCell( ~IsInBusBased & ~sfunIsRowMajor ) = cellfun( @( x )sprintf( '%s, ', x ), InPortName( ~IsInBusBased & ~sfunIsRowMajor ), 'UniformOutput', false );
declareUCell( ~IsInBusBased & sfunIsRowMajor ) = cellfun( @( x )sprintf( '%s_t, ', x ), InPortName( ~IsInBusBased & sfunIsRowMajor ), 'UniformOutput', false );
declareU = [ declareUCell{ : } ];
end 




declareYCell = cell( 1, NumberOfOutputPorts );


declareYCell( IsOutBusBased == 1 & cellfun( @( x )prod( x ) > 1, OutDimsAbs ) ) = cellfun( @( x )sprintf( '_%sBUS, ', x ), OutPortName( IsOutBusBased == 1 & cellfun( @( x )prod( x ) > 1, OutDimsAbs ) ), 'UniformOutput', false );

declareYCell( IsOutBusBased == 1 & cellfun( @( x )prod( x ) == 1, OutDimsAbs ) ) = cellfun( @( x )sprintf( '%s_%sBUS, ', isNestedInScalarBusMap( sprintf( '_%sBUS', x ) ), x ), OutPortName( IsOutBusBased == 1 & cellfun( @( x )prod( x ) == 1, OutDimsAbs ) ), 'UniformOutput', false );
declareYCell( ~IsOutBusBased & ~sfunIsRowMajor ) = cellfun( @( x )sprintf( '%s, ', x ), OutPortName( ~IsOutBusBased & ~sfunIsRowMajor ), 'UniformOutput', false );
declareYCell( ~IsOutBusBased & sfunIsRowMajor ) = cellfun( @( x )sprintf( '%s_t, ', x ), OutPortName( ~IsOutBusBased & sfunIsRowMajor ), 'UniformOutput', false );
declareY = [ declareYCell{ : } ];
fcnCallOut = [ fcnCallOpenning, declareU, declareY ];

if ( NDStates > 0 )
fcnCallOut = [ fcnCallOut, 'xD, ' ];
end 
if ( NCStates > 0 )
fcnCallOut = [ fcnCallOut, 'xC, ' ];
end 

if ( NPWorks > 0 )
fcnCallOut = [ fcnCallOut, 'pW, ' ];
end 

tempCellToPrint = [ ParameterName;num2cell( 0:NParams - 1 ) ];
if ( ~sfunIsRowMajor )
Params = sprintf( '%s, p_width%d, ', tempCellToPrint{ : } );
else 
Params = sprintf( '%s_t, p_width%d, ', tempCellToPrint{ : } );
end 
fcnCallOut = [ fcnCallOut, Params, portwidths, getSimStructString( UseSimStruct ) ];
if ( numel( fcnCallOut ) ~= numel( fcnCallOpenning ) )
fcnCallOut( end  - 1:end  ) = [  ];
end 
fcnCallOut = [ fcnCallOut, ');' ];

end 







function fcnCallOutTLC = genFunctionCallOutputTLC( sfName, fcnType, NumberOfInputPorts, NumberOfOutputPorts, InPortName, OutPortName, NumParams, NDStates, NCStates, NPWorks, IsInBusBased, IsOutBusBased, FlagDynSizedInput, FlagDynSizedOutput, idxDynSizedInput, idxDynSizedOutput, FlagBusUsed, directFeed, UseSimStruct, isAccelForBus )

portwidths = '';
if ( FlagDynSizedOutput )
portwidths = [ portwidths, sprintf( [ '%%<py_%d_width>, ' ], idxDynSizedOutput( : ) - 1 ) ];
end 
if ( FlagDynSizedInput && directFeed )
portwidths = [ portwidths, sprintf( [ '%%<pu_%d_width>, ' ], idxDynSizedInput( : ) - 1 ) ];
end 

fcnCallOpenning = [ sfName, '_', fcnType, '_wrapper(' ];

if ( isAccelForBus )

ifCheck = GetPaddingUsedIf(  );
fcnCallOpenning = sprintf( '\n  %%if %s\n', ifCheck );

dWorkAddrStrU = '';
tempCellToPrint = [ InPortName( IsInBusBased );InPortName( IsInBusBased ) ];
if ( ~isempty( tempCellToPrint ) )
dWorkAddrStrU = sprintf( '    %%assign %sBUS_ptr = LibBlockDWorkAddr(%sBUS, "", "", 0)\n', tempCellToPrint{ : } );
end 

dWorkAddrStrY = '';
tempCellToPrint = [ OutPortName( IsOutBusBased );OutPortName( IsOutBusBased ) ];
if ( ~isempty( tempCellToPrint ) )
dWorkAddrStrY = sprintf( '    %%assign %sBUS_ptr = LibBlockDWorkAddr(%sBUS, "", "", 0)\n', tempCellToPrint{ : } );
end 
fcnCallOpenning = [ fcnCallOpenning, dWorkAddrStrU, dWorkAddrStrY, '    ', sfName, '_', fcnType, '_wrapper_accel(' ];
end 




declareU = '';
if ( directFeed )
portIdNum = num2cell( 0:NumberOfInputPorts - 1 );
argList1 = cellfun( @( x )sprintf( '%%<pu%d>, ', x ), portIdNum, 'UniformOutput', false );
argList2 = cellfun( @( x )sprintf( '%%<%sBUS_ptr>, ', x ), InPortName, 'UniformOutput', false );
argList2( ~isAccelForBus | ~IsInBusBased ) = { '' };

argList = [ argList1;argList2 ];
declareU = [ argList{ : } ];
end 




portIdNum = num2cell( 0:NumberOfOutputPorts - 1 );
argList1 = cellfun( @( x )sprintf( '%%<py%d>, ', x ), portIdNum, 'UniformOutput', false );
argList2 = cellfun( @( x )sprintf( '%%<%sBUS_ptr>, ', x ), OutPortName, 'UniformOutput', false );
argList2( ~isAccelForBus | ~IsOutBusBased ) = { '' };

argList = [ argList1;argList2 ];
declareY = [ argList{ : } ];


DStates = '';
if ( NDStates > 0 )
DStates = '%<pxd>, ';
end 
CStates = '';
if ( NCStates > 0 )
CStates = 'pxc, ';
end 

PWorks = '';
if ( NPWorks > 0 )
PWorks = '%<ppw>, ';
end 

params = '';
paramIdNum = num2cell( 1:NumParams );
tempCellToPrint = [ paramIdNum;paramIdNum ];
if ( ~isempty( tempCellToPrint ) )
params = sprintf( '%%<pp%d>, %%<param_width%d>, ', tempCellToPrint{ : } );
end 

fcnCallOutTLC = [ fcnCallOpenning, declareU, declareY, DStates, CStates, PWorks, params, portwidths, getTLCSimStructStr( UseSimStruct ) ];

if ( numel( fcnCallOutTLC ) ~= numel( fcnCallOpenning ) )
fcnCallOutTLC( end  - 1:end  ) = [  ];
end 

fcnCallOutTLC = [ fcnCallOutTLC, ');' ];


end 





function fcnCallOut = genFunctionCallStartTerminateTLC( sfName, fcnType, NumParams, NCStates, NDStates, NPWorks, UseSimStruct,  ...
FlagBusUsed, isAccelForBus )

fcnName = [ sfName, '_', fcnType, '_wrapper' ];




if ( isAccelForBus )

ifCheck = GetPaddingUsedIf(  );
fcn = sprintf( '\n  %%if %s\n', ifCheck );

fcnName = [ fcn, '    ', sfName, '_', fcnType, '_wrapper_accel' ];
end 

fcnArgList = '';
if ( NCStates ~= 0 )

fcnArgList = [ fcnArgList, 'pxc, ' ];
end 
if ( NDStates ~= 0 )
fcnArgList = [ fcnArgList, '%<pxd>, ' ];
end 
if ( NPWorks ~= 0 )
fcnArgList = [ fcnArgList, '%<ppw>, ' ];
end 
params = '';
paramIdNum = num2cell( 1:NumParams );
tempCellToPrint = [ paramIdNum;paramIdNum ];
if ( ~isempty( tempCellToPrint ) )
params = sprintf( '%%<pp%d>, %%<param_width%d>, ', tempCellToPrint{ : } );
end 

fcnArgList = [ fcnArgList, params, getTLCSimStructStr( UseSimStruct ) ];

if ( ~isempty( fcnArgList ) )
fcnArgList( end  - 1:end  ) = [  ];
end 

fcnCallOut = [ fcnName, '(', fcnArgList, ');' ];
end 





function fcnCallOut = genFunctionCallTLC( sfName, fcnType, NumberOfInputPorts, NumberOfOutputPorts, InPortName, OutPortName, IsInBusBased, IsOutBusBased, NumParams, NStates, NPWorks, state, FlagDynSizedInput, FlagDynSizedOutput, idxDynSizedInput, idxDynSizedOutput, FlagBusUsed, UseSimStruct, isAccelForBus )
portwidths = '';
if ( FlagDynSizedOutput )
portwidths = [ portwidths, sprintf( [ '%%<py_%d_width>, ' ], idxDynSizedOutput( : ) - 1 ) ];
end 
if ( FlagDynSizedInput )
portwidths = [ portwidths, sprintf( [ '%%<pu_%d_width>, ' ], idxDynSizedInput( : ) - 1 ) ];
end 

fcnCallOpenning = [ sfName, '_', fcnType, '_wrapper(' ];

if ( isAccelForBus )

ifCheck = GetPaddingUsedIf(  );
fcnCallOpenning = sprintf( '  %%if %s\n', ifCheck );

dWorkAddrStrU = '';
tempCellToPrint = [ InPortName( IsInBusBased );InPortName( IsInBusBased ) ];
if ( ~isempty( tempCellToPrint ) )
dWorkAddrStrU = sprintf( '    %%assign %sBUS_ptr = LibBlockDWorkAddr(%sBUS, "", "", 0)\n', tempCellToPrint{ : } );
end 

dWorkAddrStrY = '';
tempCellToPrint = [ OutPortName( IsOutBusBased );OutPortName( IsOutBusBased ) ];
if ( ~isempty( tempCellToPrint ) )
dWorkAddrStrY = sprintf( '    %%assign %sBUS_ptr = LibBlockDWorkAddr(%sBUS, "", "", 0)\n', tempCellToPrint{ : } );
end 

fcnCallOpenning = [ fcnCallOpenning, dWorkAddrStrU, dWorkAddrStrY, '    ', sfName, '_', fcnType, '_wrapper_accel(' ];
end 




portIdNum = num2cell( 0:NumberOfInputPorts - 1 );
argList1 = cellfun( @( x )sprintf( '%%<pu%d>, ', x ), portIdNum, 'UniformOutput', false );
argList2 = cellfun( @( x )sprintf( '%%<%sBUS_ptr>, ', x ), InPortName, 'UniformOutput', false );
argList2( ~isAccelForBus | ~IsInBusBased ) = { '' };

argList = [ argList1;argList2 ];
declareU = [ argList{ : } ];




portIdNum = num2cell( 0:NumberOfOutputPorts - 1 );
argList1 = cellfun( @( x )sprintf( '%%<py%d>, ', x ), portIdNum, 'UniformOutput', false );
argList2 = cellfun( @( x )sprintf( '%%<%sBUS_ptr>, ', x ), OutPortName, 'UniformOutput', false );
argList2( ~isAccelForBus | ~IsOutBusBased ) = { '' };

argList = [ argList1;argList2 ];
declareY = [ argList{ : } ];

fcnCallOut = [ fcnCallOpenning, declareU, declareY ];

if ( ~isempty( regexp( state, 'pxc', 'end', 'once' ) ) )
fcnCallOut = [ fcnCallOut, 'dx, ' ];
end 
if ( NStates > 0 )
DStates = state;
fcnCallOut = [ fcnCallOut, DStates, ', ' ];
end 

if ( NPWorks > 0 )
fcnCallOut = [ fcnCallOut, '%<ppw>, ' ];
end 

params = '';
paramIdNum = num2cell( 1:NumParams );
tempCellToPrint = [ paramIdNum;paramIdNum ];
if ( ~isempty( tempCellToPrint ) )
params = sprintf( '%%<pp%d>, %%<param_width%d>, ', tempCellToPrint{ : } );
end 

fcnCallOut = [ fcnCallOut, params, portwidths, getTLCSimStructStr( UseSimStruct ) ];

if ( numel( fcnCallOut ) ~= numel( fcnCallOpenning ) )
fcnCallOut( end  - 1:end  ) = [  ];
end 

fcnCallOut = [ fcnCallOut, ');' ];

end 




function iDataTypeMacro = getDataTypeMacros( localDataTypeMacro )
switch localDataTypeMacro
case { 'real_T', 'creal_T' }
iDataTypeMacro = 'SS_DOUBLE';
case { 'real32_T', 'creal32_T' }
iDataTypeMacro = 'SS_SINGLE';
case { 'int8_T', 'cint8_T' }
iDataTypeMacro = 'SS_INT8';
case { 'int16_T', 'cint16_T' }
iDataTypeMacro = 'SS_INT16';
case { 'int32_T', 'cint32_T' }
iDataTypeMacro = 'SS_INT32';
case { 'uint8_T', 'cuint8_T' }
iDataTypeMacro = 'SS_UINT8';
case { 'uint16_T', 'cuint16_T' }
iDataTypeMacro = 'SS_UINT16';
case { 'uint32_T', 'cuint32_T' }
iDataTypeMacro = 'SS_UINT32';
case { 'boolean_T', 'cboolean_T' }
iDataTypeMacro = 'SS_BOOLEAN';
case { 'fixpt', 'cfixpt' }
iDataTypeMacro = 'DataTypeId';
otherwise 
iDataTypeMacro = 'DataTypeId';
end 
end 

function INBusHeaderFile = genBusHeaderFile( outBusHeader, inBusHeader, FlagGenHeader )
fileHandler = fopen( inBusHeader, 'r' );
if ( fileHandler ==  - 1 )
DAStudio.error( 'Simulink:SFunctionBuilder:ErrorOpenForRead', inBusHeader );
end 
INBusHeaderFile = fread( fileHandler, '*char' )';
fclose( fileHandler );

if ( FlagGenHeader )
tempLines0 = '';
tempLines1 = '';

[ idxL, idxR ] = regexp( INBusHeaderFile, '(?m)^(?:[^\n])*INCLUDE_FILES.*?$\n?', 'start', 'end' );
lenPref = length( 'INCLUDE_FILES=' );
for i = 1:numel( idxL )
tempLines0 = [ tempLines0, sprintf( INBusHeaderFile( idxL( i ) + lenPref:idxR( i ) ) ), sprintf( '\n' ) ];
end 

if numel( idxL ) > 0
INBusHeaderFile( idxL( 1 ):idxR( numel( idxL ) ) ) = [  ];
end 

[ idxL, idxR ] = regexp( INBusHeaderFile, '(?m)^(?:[^\n])*SETUP_BUSHEADER.*?$\n?', 'start', 'end' );
for i = 1:numel( idxL )
tempLines1 = [ tempLines1, regexp( INBusHeaderFile( idxL( i ):idxR( i ) ), '(?<=\s*=\s*)(.*)(?=\n)', 'match', 'once' ), sprintf( '\n' ) ];%#ok
end 
for i = numel( idxL ): - 1:1
INBusHeaderFile( idxL( i ):idxR( i ) ) = [  ];
end 

tempLines2 = INBusHeaderFile;
INBusHeaderFile = [  ];

user_data = '';
if ( exist( fullfile( pwd, outBusHeader ), 'file' ) == 2 )
fileHandler = fopen( outBusHeader, 'r' );
if ( fileHandler ==  - 1 )
DAStudio.error( 'Simulink:SFunctionBuilder:ErrorOpenForRead', outBusHeader );
end 
OUTBusHeaderFile = fread( fileHandler, '*char' )';
fclose( fileHandler );

user_data = [ user_data, regexp( OUTBusHeaderFile, '(?m)(?<=Read only - ENDS.*?$\n)(.*)', 'match', 'once' ) ];
delete( outBusHeader );
word = '#endif';
[ idxL, idxR ] = regexp( user_data, word, 'start', 'end' );
if ( ~isempty( idxL ) )
user_data( idxL( end  ):idxR( end  ) ) = '';
end 
user_data = strtrim( user_data );
end 

fileHandler = fopen( outBusHeader, 'w' );
if ( fileHandler ==  - 1 )
DAStudio.error( 'Simulink:SFunctionBuilder:ErrorOpenForWrite', outBusHeader );
end 
fwrite( fileHandler, [ tempLines1, tempLines0, tempLines2, user_data, sprintf( '\n\n#endif\n' ) ] );
fclose( fileHandler );
end 
end 

function PaddingUsed = GetPaddingUsedIf(  )
PaddingUsed = 'IsModelReferenceSimTarget() || CodeFormat == "S-Function" || ::isRAccel';
end 

function template = tmplCondtlPreProc( template, testTemplateCondition )






maxNestDepth = 10;
template = iterativelyResolveNestedTemplateConditions( template, testTemplateCondition, maxNestDepth );
end 

function template = iterativelyResolveNestedTemplateConditions( template, testTemplateCondition, remainingIters )
assert( remainingIters > 0, message( 'Simulink:SFunctionBuilder:InternalError' ) );
[ CTPair, idxCondStart, idxCondEnd ] = regexp( template, '(?m)^\h*--CONDITIONAL:(?<condition>[^\n]+?)--START--\s*$\n+?(?<template>.*?)^\h*--CONDITIONAL:\1--END--\s*$\n?', 'names', 'start', 'end' );
if ( ~isempty( CTPair ) )
for j = numel( idxCondStart ): - 1:1
try 
FlagKeepTemplate = testTemplateCondition( CTPair( j ).condition );
catch Ex
DAStudio.error( 'Simulink:SFunctionBuilder:InternalError' );
end 
if ( FlagKeepTemplate )
template = [ template( 1:idxCondStart( j ) - 1 ), CTPair( j ).template, template( idxCondEnd( j ) + 1:end  ) ];
else 
template( idxCondStart( j ):idxCondEnd( j ) ) = [  ];
end 
end 
template = iterativelyResolveNestedTemplateConditions( template, testTemplateCondition, remainingIters - 1 );
end 
end 


function [ dataType, fixPointScaling, isSigned, wordLength, fractionLength ] = convertInt64ToFixdt( dataType, fixPointScaling, isSigned, wordLength, fractionLength )
for i = 1:length( dataType )
if ( strcmp( dataType{ i }, 'int64_T' ) || strcmp( dataType{ i }, 'cint64_T' ) )
dataType{ i } = 'fixpt';
fixPointScaling( i ) = false;
isSigned( i ) = true;
wordLength( i ) = 64;
fractionLength( i ) = 0;
elseif ( strcmp( dataType{ i }, 'uint64_T' ) || strcmp( dataType{ i }, 'cuint64_T' ) )
dataType{ i } = 'fixpt';
fixPointScaling( i ) = false;
isSigned( i ) = false;
wordLength( i ) = 64;
fractionLength( i ) = 0;
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp67pNLG.p.
% Please follow local copyright laws when handling this file.

