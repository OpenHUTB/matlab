




classdef FunctionInterfaceWriter < handle
properties ( Access = protected )
FunctionInterfaces
CodeInfoUtils
ModelInterfaceUtils
FunctionInterfaceUtils
DataInterfaceUtils
DataTypeUtils
VarDimsUtils
Writer
HeaderWriter = coder.internal.modelreference.SimTargetCodeWriter.empty;


ModelInterface
CodeInfo

NumberOfFunctionInterfaces


HasVarDimsInport = false
HasVarDimsOutport = false


InputPortIndexMap


Linkage = coder.internal.modelreference.FunctionLinkage.Internal
end 


methods 
function this = FunctionInterfaceWriter( functionInterfaces, modelInterfaceUtils, codeInfoUtils,  ...
sourceWriter )
this.FunctionInterfaces = functionInterfaces;
this.ModelInterfaceUtils = modelInterfaceUtils;
this.CodeInfoUtils = codeInfoUtils;
this.Writer = sourceWriter;

this.CodeInfo = this.CodeInfoUtils.getCodeInfo;
this.ModelInterface = this.ModelInterfaceUtils.getModelInterface;

this.FunctionInterfaceUtils = coder.internal.modelreference.FunctionInterfaceUtils;
this.DataInterfaceUtils = coder.internal.modelreference.DataInterfaceUtils;
this.DataTypeUtils = coder.internal.modelreference.DataTypeUtils;
this.VarDimsUtils = coder.internal.modelreference.VarDimsUtils( this.Writer );

this.NumberOfFunctionInterfaces = length( this.FunctionInterfaces );

this.HasVarDimsInport = this.ModelInterfaceUtils.HasVarDimsInport;
this.HasVarDimsOutport = this.ModelInterfaceUtils.HasVarDimsOutport;
this.InputPortIndexMap = this.ModelInterfaceUtils.InputPortIndexMap;
end 
end 



methods ( Access = public )
function write( this )
for taskIdx = 1:this.NumberOfFunctionInterfaces
functionInterface = this.FunctionInterfaces( taskIdx );
this.writeFunctionHeader( functionInterface );
this.writeFunctionBody( functionInterface );
this.writeFunctionTrailer;
if ~isempty( this.HeaderWriter )
assert( this.Linkage == coder.internal.modelreference.FunctionLinkage.External )
this.declareInHeader( functionInterface );
end 
end 
end 
end 



methods ( Access = protected, Abstract = true )
p = getFunctionPrototype( this, functionInterface )
end 


methods ( Access = protected )
function writeFunctionHeader( this, functionInterface )
R36
this


functionInterface = RTW.FunctionInterface.empty
end 
prototype = this.getFunctionPrototype( functionInterface );
if this.Linkage ==  ...
coder.internal.modelreference.FunctionLinkage.Internal
linkageString = 'static';
else 
linkageString = '';
end 
this.Writer.writeLine( '%s %s {', linkageString, prototype );
end 

function writeFunctionBody( this, functionInterface )
actualArguments = functionInterface.ActualArgs;
this.declareMultiInstanceVariables;
parameterIndices = this.declareFunctionArguments( actualArguments );
this.writeModelArguments( actualArguments, parameterIndices );
this.initializePorts( actualArguments );
this.writeFunctionCall( functionInterface );
this.updateOutports( actualArguments );
end 

function declareInHeader( this, functionInterface )
this.HeaderWriter.writeLine( '%s;', this.getFunctionPrototype( functionInterface ) );
end 


function writeReturnStatement( this )
this.Writer.writeLine( 'return;' );
end 


function writeFunctionTrailer( this )
this.writeReturnStatement;
this.Writer.writeLine( '}' );
end 


function parameterIndices = declareFunctionArguments( this, actualArguments )
numberOfActualArguments = length( actualArguments );
masks = zeros( numberOfActualArguments, 1 );
for argIdx = 1:numberOfActualArguments
dataInterface = actualArguments( argIdx );
if this.DataInterfaceUtils.isCustomExpression( dataInterface )

if strcmp( dataInterface.GraphicalName, 'localMM' )
this.declareVariable( '', 'real_T', dataInterface.GraphicalName, 'ssGetMassMatrixPr(S)' );
end 
elseif this.CodeInfoUtils.isInport( dataInterface )
this.declareInportVariable( dataInterface );
elseif this.CodeInfoUtils.isOutport( dataInterface )
this.declareOutputVariable( dataInterface );
elseif this.CodeInfoUtils.isInternalData( dataInterface )
this.declareInternalDataVariable( dataInterface );
this.declareVarDimVariable( dataInterface );
elseif this.CodeInfoUtils.isParameter( dataInterface )
isModelArgParam = this.declareParameterVariable( dataInterface );
if isModelArgParam
masks( argIdx ) = 1;
end 
elseif this.DataInterfaceUtils.isGlobalTid( dataInterface )

else 
assert( false, 'Unexpected argument type' );
end 
end 
parameterIndices = find( masks > 0 );
end 


function writeModelArguments( this, actualArguments, parameterIndices )
if ~isempty( parameterIndices )
usedParams = this.CodeInfoUtils.ModelParameters;
numberOfParameters = length( parameterIndices );
parametersIndexes = this.ModelInterfaceUtils.UsedCanonicalParametersIndexes;
for i = 1:numberOfParameters
dataInterface = actualArguments( parameterIndices( i ) );
paramIdx = parametersIndexes( usedParams == dataInterface );
this.Writer.writeLine( 'if (!ssGetModelRefModelArgData(S, %d, (void **)(&%s)))',  ...
paramIdx, dataInterface.Implementation.Identifier );
this.writeReturnStatement;
end 
end 
end 


function initializePorts( this, actualArguments )
this.writeInitializeVarDimsPorts( actualArguments, 'In', 'ssGetCurrentInputPortDimensions' );
this.writeInitializeVarDimsPorts( actualArguments, 'Out', 'ssGetCurrentOutputPortDimensions' );
end 


function writeFunctionCall( this, functionInterface )
this.Writer.writeLine( '%s;', functionInterface.getFunctionCall );
end 


function writeOutputOrUpdateFunctionCall( this )
if ( this.NumberOfFunctionInterfaces > 1 )


numNonParamTasks = sum( arrayfun( @( aFunctionInterface )( aFunctionInterface.Timing.SamplePeriod ~= Inf ), this.FunctionInterfaces ) );

for taskIdx = 1:this.NumberOfFunctionInterfaces
functionInterface = this.FunctionInterfaces( taskIdx );


if functionInterface.Timing.SamplePeriod == Inf
continue ;
end 

if this.FunctionInterfaceUtils.hasContinuousSampleTimes( functionInterface )
this.writeContinuousSampleTimeCondition( taskIdx );
else 
if numNonParamTasks > 1
this.Writer.writeLine( 'if (ssIsSampleHit(S, %d, %s)) {',  ...
taskIdx - 1,  ...
this.ModelInterfaceUtils.getGlobalTidString );
end 
end 


this.Writer.writeLine( [ functionInterface.getFunctionCall, ';' ] );


this.writeUpdateVarDimsOutPorts( functionInterface.ActualArgs );

if numNonParamTasks > 1 || this.FunctionInterfaceUtils.hasContinuousSampleTimes( functionInterface )
this.Writer.writeLine( '}' );
end 
end 
elseif this.FunctionInterfaces.Timing.SamplePeriod ~= Inf

this.Writer.writeLine( [ this.FunctionInterfaces.getFunctionCall, ';' ] );
this.writeUpdateVarDimsOutPorts( this.FunctionInterfaces.ActualArgs );
end 
end 


function updateOutports( this, actualArguments )%#ok
end 


function writeCoverageNotify( this, covrtFcnName )
modelName = this.ModelInterface.Name;
if SlCov.CoverageAPI.isEnabledForAccelCoverage( modelName )
this.Writer.writeLine( [ covrtFcnName, '("', modelName, '");' ] );
end 
end 
end 



methods ( Access = protected )
function declareNonPtrVariable( this, constString, dataTypeString, argumentString, functionCallString )
this.Writer.writeLine( '%s %s %s = (%s) %s;',  ...
dataTypeString,  ...
constString,  ...
argumentString,  ...
dataTypeString,  ...
functionCallString );
end 

function declareVariable( this, constString, dataTypeString, argumentString, functionCallString )
this.Writer.writeLine( '%s %s * %s = (%s*) %s;',  ...
dataTypeString,  ...
constString,  ...
argumentString,  ...
dataTypeString,  ...
functionCallString );
end 


function declareInportVariable( this, dataInterface )
dataType = this.DataTypeUtils.getBaseType( dataInterface.Implementation.Type );
portIdx = this.InputPortIndexMap( this.CodeInfoUtils.getInportIndex( dataInterface ) ) - 1;
if ( isa( dataInterface.Type, "coder.types.Matrix" ) && any( isinf( dataInterface.Type.Dimensions ) ) )
functionCallString = sprintf( 'ssGetInputPortDynamicArrayData(S, %d)', portIdx );
else 
functionCallString = sprintf( 'ssGetInputPortSignal(S, %d)', portIdx );
end 
constString = 'const';
this.declareVariable( constString, dataType.Identifier, dataInterface.Implementation.Identifier, functionCallString );
end 

function declareOutputVariable( this, dataInterface )
dataType = this.DataTypeUtils.getBaseType( dataInterface.Implementation.Type );
if ( isa( dataInterface.Type, "coder.types.Matrix" ) && any( isinf( dataInterface.Type.Dimensions ) ) )
functionCallString = sprintf( 'ssGetOutputPortDynamicArrayData(S, %d)', this.CodeInfoUtils.getOutportIndex( dataInterface ) - 1 );
else 
functionCallString = sprintf( 'ssGetOutputPortSignal(S, %d)', this.CodeInfoUtils.getOutportIndex( dataInterface ) - 1 );
end 
constString = '';
this.declareVariable( constString, dataType.Identifier, dataInterface.Implementation.Identifier, functionCallString );
end 

function writeInitializeVarDimsPorts( this, actualArguments, portType, functionCallString )
numberOfActualArguments = length( actualArguments );
for argIdx = 1:numberOfActualArguments
dataInterface = actualArguments( argIdx );
if ~this.DataInterfaceUtils.isCustomExpression( dataInterface )
regExpression = sprintf( '^%sVarDims%s', portType, '(\d+)' );
if this.VarDimsUtils.isVarDimsPort( dataInterface, regExpression )
varName = dataInterface.Implementation.Identifier;
varIndex = this.DataInterfaceUtils.getVariableIndexesFromIdentifier( dataInterface, regExpression );
this.VarDimsUtils.resetBusElementIndex;
this.VarDimsUtils.writeInitializationForVarDims( dataInterface.Implementation.Type, varName, varIndex, functionCallString );
end 
end 
end 
end 

function result = calledFromSetupRTROrHasNoParamWrite( this, calledFromSetupRTR, prm )
result = calledFromSetupRTR || ~( prm.HasParamWrite || prm.HasDescendantParamWrite );
end 

function declareTestpointedParameters( this, calledFromSetupRTR )
testpointedParameters = this.ModelInterfaceUtils.TestpointedParameters;
numberOfTestpointedParameters = length( testpointedParameters );
for i = 1:numberOfTestpointedParameters
prm = testpointedParameters{ i };
if calledFromSetupRTROrHasNoParamWrite( this, calledFromSetupRTR, prm )
dataType = prm.DataTypeName;
this.Writer.writeLine( '%s * rtp_%d = (%s*) NULL;', dataType, i, dataType );
end 
end 
canonicalParameters = this.ModelInterfaceUtils.CanonicalParameters;
numberOfCanonicalParameters = length( canonicalParameters );
dataIndex = numberOfTestpointedParameters;
for i = 1:numberOfCanonicalParameters
dataIndex = dataIndex + 1;
prm = canonicalParameters{ i };
if calledFromSetupRTROrHasNoParamWrite( this, calledFromSetupRTR, prm )
if prm.TestpointIndex >= 0
dataType = prm.DataTypeName;
this.Writer.writeLine( '%s * rtp_%d = (%s*) NULL;', dataType, dataIndex, dataType );
end 
end 
end 
end 

function writeTestpointedParameters( this, calledFromSetupRTR )
testpointedParameters = this.ModelInterfaceUtils.TestpointedParameters;
numberOfTestpointedParameters = length( testpointedParameters );
for i = 1:numberOfTestpointedParameters
prm = testpointedParameters{ i };
if calledFromSetupRTROrHasNoParamWrite( this, calledFromSetupRTR, prm )
this.Writer.writeLine( 'if (!ssGetModelRefBlockArgData(S, %d, (void **)(&rtp_%d)))',  ...
i - 1, i );
this.writeReturnStatement;
end 
end 
canonicalParameters = this.ModelInterfaceUtils.CanonicalParameters;
numberOfCanonicalParameters = length( canonicalParameters );
dataIndex = numberOfTestpointedParameters;
for i = 1:numberOfCanonicalParameters
dataIndex = dataIndex + 1;
prm = canonicalParameters{ i };
if calledFromSetupRTROrHasNoParamWrite( this, calledFromSetupRTR, prm )
if prm.TestpointIndex >= 0
this.Writer.writeLine( 'if (!ssGetModelRefModelArgData(S, %d, (void **)(&rtp_%d)))',  ...
i - 1, dataIndex );
this.writeReturnStatement;
end 
end 
end 
initInLoop = isfield( this.ModelInterface, 'CoderDataGroupsInitLoop' );
if isfield( this.ModelInterface, 'CoderDataGroups' )
coderDataGroups = this.ModelInterface.CoderDataGroups;
numCoderDataGroups = numel( coderDataGroups.CoderDataGroup );
for i = 1:numCoderDataGroups
if numCoderDataGroups == 1
coderDataGroup = coderDataGroups.CoderDataGroup;
else 
coderDataGroup = coderDataGroups.CoderDataGroup{ i };
end 
dynamicInit = coderDataGroup.DynamicInitializer;
dynamicInitFieldNames = fieldnames( dynamicInit );
if initInLoop
if numCoderDataGroups == 1
initLoopRecord = this.ModelInterface.CoderDataGroupsInitLoop.CoderDataGroupInitLoop;
else 
initLoopRecord = this.ModelInterface.CoderDataGroupsInitLoop.CoderDataGroupInitLoop{ i };
end 
this.Writer.writeLine( '%s', initLoopRecord.LoopStart );
end 
for j = 1:numel( dynamicInitFieldNames )
fieldName = dynamicInitFieldNames{ j };
path = dynamicInit.( fieldName );
tpIdx = sscanf( fieldName, 'TP%f' );
if tpIdx < numberOfTestpointedParameters
prm = testpointedParameters{ tpIdx + 1 };
else 
prm = canonicalParameters{ tpIdx + 1 - numberOfTestpointedParameters };
end 



if calledFromSetupRTROrHasNoParamWrite( this, calledFromSetupRTR, prm )
numEl = prod( prm.Dims );
if numEl == 1
dataSize = sprintf( 'sizeof(%s)', prm.DataTypeName );
else 
dataSize = sprintf( 'sizeof(%s) * %d', prm.DataTypeName, numEl );
end 
if this.ModelInterfaceUtils.isMultiInstance



if this.ModelInterface.rtmAllocateInParent
this.Writer.writeLine( 'memcpy(&(dw->rtm.%s), rtp_%d, %s);', path, tpIdx + 1, dataSize );
else 
this.Writer.writeLine( 'memcpy(&(dw->%s), rtp_%d, %s);', path, tpIdx + 1, dataSize );
end 
else 
this.Writer.writeLine( 'memcpy(&(%s), rtp_%d, %s);', path, tpIdx + 1, dataSize );
end 
end 
end 
if initInLoop
this.Writer.writeLine( '%s', initLoopRecord.LoopEnd );
end 
end 
end 
end 


function declareMultiInstanceVariables( this )
if this.ModelInterfaceUtils.isMultiInstance
dworkType = this.ModelInterface.DWorkType;
this.declareVariable( '', dworkType, 'dw', 'ssGetDWork(S, 0)' );
end 
end 


function writeUpdateVarDimsOutPorts( this, actualArguments )

if this.ModelInterfaceUtils.isModelOutputSizeDependOnlyInputSize
return ;
end 

numberOfActualArguments = length( actualArguments );
for argIdx = 1:numberOfActualArguments
dataInterface = actualArguments( argIdx );
if ~this.DataInterfaceUtils.isCustomExpression( dataInterface )
rtwVariable = actualArguments( argIdx ).Implementation;
if ~isa( rtwVariable, 'RTW.Literal' )
varName = rtwVariable.Identifier;
regExpression = '^OutVarDims(\d+)';
if this.VarDimsUtils.isVarDimsPort( dataInterface, regExpression )
this.VarDimsUtils.resetBusElementIndex;
varIndex = this.DataInterfaceUtils.getVariableIndexesFromIdentifier( dataInterface, regExpression );
this.VarDimsUtils.writeUpdateForVarDims( rtwVariable.Type, varName, varIndex, 'ssSetCurrentOutputPortDimensions' );
end 
end 
end 
end 
end 


function writeContinuousSampleTimeCondition( this, taskIdx )
this.Writer.writeLine( 'if (ssIsSampleHit(S, %d, %s) || ssIsMinorTimeStep(S)) {',  ...
taskIdx - 1, this.ModelInterfaceUtils.getGlobalTidString );
end 
end 



methods ( Access = private )

function declareInternalDataVariable( this, dataInterface )
switch dataInterface.GraphicalName
case { 'localX', 'localX_' }
this.declareVariable( '', this.ModelInterface.xDataType, dataInterface.GraphicalName, 'ssGetContStates(S)' );
case { 'localXdot', 'localXdot_' }
this.declareVariable( '', this.ModelInterface.xDotDataType, dataInterface.GraphicalName, 'ssGetdX(S)' );
case { 'localXdis', 'localXdis_' }
this.declareVariable( '', this.ModelInterface.xDisDataType, dataInterface.GraphicalName, 'ssGetContStateDisabled(S)' );
case { 'localXAbsTollocalXAbsTol', 'localXAbsTollocalXAbsTol_' }
this.declareVariable( '', this.ModelInterface.xAbsTolDataType, dataInterface.GraphicalName, 'ssGetAbsTolVector(S)' );

case { 'localXPerturbMin', 'localXPerturbMin_' }
this.declareVariable( '', this.ModelInterface.xPerturbMinDataType, dataInterface.GraphicalName, 'ssGetJacobianPerturbationBoundsMinVec(S)' );
case { 'localXPerturbMax', 'localXPerturbMax_' }
this.declareVariable( '', this.ModelInterface.xPerturbMaxDataType, dataInterface.GraphicalName, 'ssGetJacobianPerturbationBoundsMaxVec(S)' );

case { 'localZCSV', 'localZCSV_' }
this.declareVariable( '', this.ModelInterface.zcDataType, dataInterface.GraphicalName, 'ssGetNonsampledZCs(S)' );
case { 'localSolverInputCompensationMode' }
this.declareNonPtrVariable( '', dataInterface.Implementation.Type.Identifier,  ...
dataInterface.GraphicalName, 'slmrGetLocalSolverInputCompensationMethod(S)' );
case { 'localSolverOutputCompensationMode' }
this.declareNonPtrVariable( '', dataInterface.Implementation.Type.Identifier,  ...
dataInterface.GraphicalName, 'slmrGetLocalSolverOutputCompensationMethod(S)' );
end 
end 

function declareVarDimVariable( this, dataInterface )
if this.HasVarDimsInport || this.HasVarDimsOutport
if this.VarDimsUtils.isVarDimsPort( dataInterface, '^(In|Out)VarDims(\d+)$' )
this.VarDimsUtils.writeDeclarationForVarDims( dataInterface );
end 
end 
end 

function isModelArgParam = declareParameterVariable( this, dataInterface )
if this.CodeInfoUtils.isModelArgumentParameter( dataInterface )
dataType = this.DataTypeUtils.getBaseType( dataInterface.Implementation.Type );
this.declareVariable( '', dataType.Identifier, dataInterface.Implementation.Identifier, 'NULL' );
isModelArgParam = true;
end 
end 
end 
end 






% Decoded using De-pcode utility v1.2 from file /tmp/tmpZLtSqI.p.
% Please follow local copyright laws when handling this file.

