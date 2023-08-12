function sfunwiz_gensfunctionwrappertlc( sfunNameWrapperTLC, INWrapperTLC, sFName, NumberOfInputPorts, NumberOfOutputPorts, InDataType, OutDataType, NumParams, ParameterName, ParameterComplexity, ParameterDataType,  ...
NumDiscStates, NumContStates, DStatesIC, CStatesIC, NumUserPWorks, FlagDynSizedInput, idxDynSizedInput, FlagDynSizedOutput, idxDynSizedOutput, FlagBusUsed, timeString, sfunName, fcnCallStartTLC, fcnCallOutputTLC, fcnCallUpdateTLC, fcnCallDerivativesTLC, fcnCallTerminateTLC,  ...
fcnProtoTypeStartTLC, fcnProtoTypeOutputTLC, wrapperExternDeclarationOutputTLCForBus, fcnProtoTypeUpdateTLC, fcnProtoTypeDerivativesTLC, fcnProtoTypeTerminateTLC, UseSimStruct, IsSFunctionInC, idxForExtern )






sfNameWrapperTLC = [ sFName, '_wrapper' ];

lines = regexp( INWrapperTLC, '\n', 'split' );
lines( 17:18 ) = [  ];
clear INWrapperTLC

fileHandler = fopen( sfunNameWrapperTLC, 'W' );
if ( fileHandler ==  - 1 )
DAStudio.error( 'Simulink:SFunctionBuilder:ErrorOpenForWrite', sfunNameWrapperTLC );
end 

for lineCell = lines
line = lineCell{ : };

printInfoTag = regexp( line, '^\s*--(\<.+\>)--\s*$', 'tokens', 'once' );

if ( isempty( printInfoTag ) )
fprintf( fileHandler, '%s\n', line );
continue ;
end 

switch printInfoTag{ : }
case 'PrintFileName'
fprintf( fileHandler, '%%%% File : %s\n', sfunNameWrapperTLC );

case 'PrintTimeInfo'
fprintf( fileHandler, '%%%% Created : %s\n', timeString );

case 'SFunctionInfo'
fprintf( fileHandler, '%%%%   S-function "%s".\n', sfunName );

case 'ImplementsBlkDef'
fprintf( fileHandler, '%%implements  %s "C"\n', sFName );

case 'ExternDeclarationBusTLC'
inputSignalFixPtDataInfo = '';
msk = strcmp( InDataType, 'fixpt' ) | strcmp( InDataType, 'cfixpt' );
portIdNum = num2cell( 0:NumberOfInputPorts - 1 );
tempCellToPrint = [ portIdNum( msk );portIdNum( msk ) ];
if ( ~isempty( tempCellToPrint ) )
inputSignalFixPtDataInfo = sprintf( '  %%assign u%dDT = FixPt_GetInputDataType(%d)\n', tempCellToPrint{ : } );
end 
outputSignalFixPtDataInfo = '';
msk = strcmp( OutDataType, 'fixpt' ) | strcmp( OutDataType, 'cfixpt' );
portIdNum = num2cell( 0:NumberOfOutputPorts - 1 );
tempCellToPrint = [ portIdNum( msk );portIdNum( msk ) ];
if ( ~isempty( tempCellToPrint ) )
outputSignalFixPtDataInfo = sprintf( '  %%assign y%dDT = FixPt_GetOutputDataType(%d)\n', tempCellToPrint{ : } );
end 
fprintf( fileHandler, '\n' );
fprintf( fileHandler, '%s', inputSignalFixPtDataInfo );
fprintf( fileHandler, '%s', outputSignalFixPtDataInfo );
sHalfOutputTLC = wrapperExternDeclarationOutputTLCForBus( idxForExtern + 1:end  );
wrapperExternDeclarationOutputTLCForBus = [  ...
wrapperExternDeclarationOutputTLCForBus( 1:idxForExtern ) ...
, sprintf( [ '\n' ...
, '    extern %s;\n' ...
, '    extern %s;\n' ...
, '    extern %s;\n' ...
 ], fcnProtoTypeStartTLC, fcnProtoTypeOutputTLC, fcnProtoTypeTerminateTLC ) ];
if NumContStates > 0
wrapperExternDeclarationOutputTLCForBus = [  ...
wrapperExternDeclarationOutputTLCForBus ...
, sprintf( [ '\n' ...
, '    extern %s;\n' ...
 ], fcnProtoTypeDerivativesTLC ) ...
 ];
end 
if NumDiscStates > 0
wrapperExternDeclarationOutputTLCForBus = [  ...
wrapperExternDeclarationOutputTLCForBus ...
, sprintf( [ '\n' ...
, '    extern %s;\n' ...
 ], fcnProtoTypeUpdateTLC ) ...
 ];
end 
wrapperExternDeclarationOutputTLCForBus = [  ...
wrapperExternDeclarationOutputTLCForBus ...
, sHalfOutputTLC ];
fprintf( fileHandler, '%s', wrapperExternDeclarationOutputTLCForBus );

case 'InOutSignalFixPointDataInfo'
inputSignalFixPtDataInfo = '';
msk = strcmp( InDataType, 'fixpt' ) | strcmp( InDataType, 'cfixpt' );
portIdNum = num2cell( 0:NumberOfInputPorts - 1 );
tempCellToPrint = [ portIdNum( msk );portIdNum( msk ) ];
if ( ~isempty( tempCellToPrint ) )
inputSignalFixPtDataInfo = sprintf( '    %%assign u%dDT = FixPt_GetInputDataType(%d)\n', tempCellToPrint{ : } );
end 
outputSignalFixPtDataInfo = '';
msk = strcmp( OutDataType, 'fixpt' ) | strcmp( OutDataType, 'cfixpt' );
portIdNum = num2cell( 0:NumberOfOutputPorts - 1 );
tempCellToPrint = [ portIdNum( msk );portIdNum( msk ) ];
if ( ~isempty( tempCellToPrint ) )
outputSignalFixPtDataInfo = sprintf( '    %%assign y%dDT = FixPt_GetOutputDataType(%d)\n', tempCellToPrint{ : } );
end 
fprintf( fileHandler, '\n' );
fprintf( fileHandler, '%s', inputSignalFixPtDataInfo );
fprintf( fileHandler, '%s', outputSignalFixPtDataInfo );

case 'ExternCSyntaxStart'

externPrefix = sprintf( [ '    #ifdef __cplusplus\n' ...
, '    #define SFB_EXTERN_C extern "C"\n' ...
, '    #else\n' ...
, '    #define SFB_EXTERN_C extern\n' ...
, '    #endif\n' ] );
fprintf( fileHandler, externPrefix );


case 'ExternDeclarationStartTLC'
fprintf( fileHandler, '    SFB_EXTERN_C %s;\n', fcnProtoTypeStartTLC );

case 'ExternDeclarationOutputTLC'
fprintf( fileHandler, '    SFB_EXTERN_C %s;\n', fcnProtoTypeOutputTLC );

case 'ExternDeclarationUpdateTLC'
if ( NumDiscStates > 0 )
fprintf( fileHandler, '    SFB_EXTERN_C %s;\n', fcnProtoTypeUpdateTLC );
end 

case 'ExternDeclarationDerivativesTLC'
if ( NumContStates > 0 )
fprintf( fileHandler, '    SFB_EXTERN_C %s;\n', fcnProtoTypeDerivativesTLC );
end 

case 'ExternDeclarationTerminateTLC'
fprintf( fileHandler, '    SFB_EXTERN_C %s;\n', fcnProtoTypeTerminateTLC );

case 'ExternCSyntaxEnd'
fprintf( fileHandler, '    #undef SFB_EXTERN_C\n' );

case 'ExternDeclarationEndBusTLC'
fprintf( fileHandler, '\n  %%endif\n' );

case 'mdlInitializeConditionsTLC'
if ( NumDiscStates > 0 || NumContStates > 0 )
methodInitTLC = get_mdlInitializeConditionsTLC_method( NumParams, ParameterName, ParameterComplexity, ParameterDataType, NumDiscStates, NumContStates, DStatesIC, CStatesIC );
fprintf( fileHandler, '%s', methodInitTLC );
end 

case 'DeclareInputPortsAddrTLC'
portIdNum = num2cell( 0:NumberOfInputPorts - 1 );
tempCellToPrint = [ portIdNum;portIdNum ];
if ( ~isempty( tempCellToPrint ) )
fprintf( fileHandler, '  %%assign pu%d = LibBlockInputSignalAddr(%d, "", "", 0)\n', tempCellToPrint{ : } );
end 

case 'DeclareOutputPortsAddrTLC'
portIdNum = num2cell( 0:NumberOfOutputPorts - 1 );
tempCellToPrint = [ portIdNum;portIdNum ];
if ( ~isempty( tempCellToPrint ) )
fprintf( fileHandler, '  %%assign py%d = LibBlockOutputSignalAddr(%d, "", "", 0)\n', tempCellToPrint{ : } );
end 

case 'DeclareNumPWorksTLC'
if ( NumUserPWorks > 0 )
fprintf( fileHandler, '  %%assign ppw = LibBlockDWorkAddr(PWORK, "", "", 0)\n' );
end 

case 'DeclareNumDiscStatesTLC'
if ( NumDiscStates > 0 )
fprintf( fileHandler, '  %%assign pxd = LibBlockDWorkAddr(DSTATE, "", "", 0)\n' );
end 

case 'DeclareNumParamsTLC'

paramIdNum = num2cell( 1:NumParams );
tempCellToPrint = repmat( paramIdNum, [ 10, 1 ] );
if ( ~isempty( tempCellToPrint ) )
fprintf( fileHandler,  ...
[ '  %%assign nelements%d = LibBlockParameterSize(P%d)\n' ...
, '  %%assign param_width%d = nelements%d[0] * nelements%d[1]\n' ...
, '  %%if (param_width%d) > 1\n' ...
, '    %%assign pp%d = LibBlockMatrixParameterBaseAddr(P%d)\n' ...
, '  %%else\n' ...
, '    %%assign pp%d = LibBlockParameterAddr(P%d, "", "", 0)\n' ...
, '  %%endif\n' ...
 ], tempCellToPrint{ : } );
end 

case 'DeclareOutputPortWidthsTLC'
if ( NumberOfOutputPorts > 0 && FlagDynSizedOutput )
tempCellToPrint = [ num2cell( idxDynSizedOutput( : ) - 1 );num2cell( idxDynSizedOutput( : ) - 1 ) ];
fprintf( fileHandler, '  %%assign py_%d_width = LibBlockOutputSignalWidth(%d)\n', tempCellToPrint{ : } );
end 

case 'DeclareInputPortWidthsTLC'
if ( NumberOfInputPorts > 0 && FlagDynSizedInput )
tempCellToPrint = [ num2cell( idxDynSizedInput( : ) - 1 );num2cell( idxDynSizedInput( : ) - 1 ) ];
fprintf( fileHandler, '  %%assign pu_%d_width = LibBlockInputSignalWidth(%d)\n', tempCellToPrint{ : } );
end 

case 'PrintBlockInfo'
fprintf( fileHandler, '    /* S-Function "%s" Block: %%<Name> */\n', sfNameWrapperTLC );

case 'StartCodeAndNumContStatesTLC'
SimStructAccessCodeTLC = '';
SimStructDeclarationCodeTLC = '';
if ( UseSimStruct )
SimStructAccessCodeTLC = getSimStructAccessTLC_Code(  );
SimStructDeclarationCodeTLC = getSimStructDec(  );
end 
if ( NumContStates > 0 )
ContStateDecl = 'real_T *pxc = &%<LibBlockContinuousState("", "", 0)>;';
end 
if ( UseSimStruct || NumContStates > 0 )
fprintf( fileHandler, '%s', [ SimStructAccessCodeTLC ...
, '  {', newline ...
, '    ', SimStructDeclarationCodeTLC, newline ...
, '    ', ContStateDecl, newline ...
, '    ', fcnCallStartTLC, newline ...
, '  }', newline ...
 ] );
else 
fprintf( fileHandler, '  %s\n', fcnCallStartTLC );
end 

case 'OutputsCodeAndNumContStatesTLC'
SimStructAccessCodeTLC = '';
SimStructDeclarationCodeTLC = '';
if ( UseSimStruct )
SimStructAccessCodeTLC = getSimStructAccessTLC_Code(  );
SimStructDeclarationCodeTLC = getSimStructDec(  );
end 
if ( NumContStates > 0 )
ContStateDecl = 'real_T *pxc = &%<LibBlockContinuousState("", "", 0)>;';
end 
if ( UseSimStruct || NumContStates > 0 )
fprintf( fileHandler, '%s', [ SimStructAccessCodeTLC ...
, '  {', newline ...
, '    ', SimStructDeclarationCodeTLC, newline ...
, '    ', ContStateDecl, newline ...
, '    ', fcnCallOutputTLC, newline ...
, '  }', newline ...
 ] );
else 
fprintf( fileHandler, '  %s\n', fcnCallOutputTLC );
end 

case 'UpdatesCodeTLC'
if ( UseSimStruct )
SimStructAccessCodeTLC = getSimStructAccessTLC_Code(  );
SimStructDeclarationCodeTLC = getSimStructDec(  );
fprintf( fileHandler, '%s', [ SimStructAccessCodeTLC ...
, '  {', newline ...
, '    ', SimStructDeclarationCodeTLC, newline ...
, '    ', fcnCallUpdateTLC, newline ...
, '  }', newline ...
 ] );
else 
fprintf( fileHandler, '  %s\n', fcnCallUpdateTLC );
end 

case 'DerivativesCodeAndNumContStatesTLC'
SimStructAccessCodeTLC = '';
SimStructDeclarationCodeTLC = '';
if ( UseSimStruct )
SimStructAccessCodeTLC = getSimStructAccessTLC_Code(  );
SimStructDeclarationCodeTLC = getSimStructDec(  );
end 
fprintf( fileHandler, '%s', [ SimStructAccessCodeTLC ...
, '  {', newline ...
, '    ', SimStructDeclarationCodeTLC, newline ...
, '    real_T *pxc = &%<LibBlockContinuousState("", "", 0)>;', newline ...
, '    real_T *dx  = &%<LibBlockContinuousStateDerivative("", "", 0)>;', newline ...
, '    ', fcnCallDerivativesTLC, newline ...
, '  }', newline ...
 ] );

case 'TerminateCodeAndNumContStatesTLC'
SimStructAccessCodeTLC = '';
SimStructDeclarationCodeTLC = '';
if ( UseSimStruct )
SimStructAccessCodeTLC = getSimStructAccessTLC_Code(  );
SimStructDeclarationCodeTLC = getSimStructDec(  );
end 
if ( NumContStates > 0 )
ContStateDecl = 'real_T *pxc = &%<LibBlockContinuousState("", "", 0)>;';
end 
if ( UseSimStruct || NumContStates > 0 )
fprintf( fileHandler, '%s', [ SimStructAccessCodeTLC ...
, '  {', newline ...
, '    ', SimStructDeclarationCodeTLC, newline ...
, '    ', ContStateDecl, newline ...
, '    ', fcnCallTerminateTLC, newline ...
, '  }', newline ...
 ] );
else 
fprintf( fileHandler, '  %s\n', fcnCallTerminateTLC );
end 

case 'EOF'
fprintf( fileHandler, '\n%%%% [EOF] %s\n', sfunNameWrapperTLC );
end 
end 

fclose( fileHandler );








coder.updateTlcForLanguageStandardTypes( sfunNameWrapperTLC, Interactive = false );

end 

function SimStructAccessTLCCode = getSimStructAccessTLC_Code(  )
SimStructAccessTLCCode = [ '  %if EXISTS("block.SFunctionIdx") == 0', ( newline ) ...
, '     %% Register S-function in the Model S-function list', ( newline ) ...
, '     %assign SFunctionIdx = NumChildSFunctions', ( newline ) ...
, '     %assign block = block + SFunctionIdx', ( newline ) ...
, '     %assign ::CompiledModel.ChildSFunctionList = ...', ( newline ) ...
, '       ::CompiledModel.ChildSFunctionList + block\n' ...
, '      ', ( newline ) ...
, '  %endif', ( newline ) ...
, '  %assign s = tChildSimStruct', ( newline ) ...
 ];
end 

function SimStructDec = getSimStructDec(  )
SimStructDec = 'SimStruct *%<s> = %<RTMGetIdxed("SFunction", block.SFunctionIdx)>;';
end 

function mdlInitCondTLC = get_mdlInitializeConditionsTLC_method( NumParams, ParameterName, ParameterComplexity, ParameterDataType, NumDStates, NumCStates, dIC, cIC )
vectordIC = regexp( dIC, '\s*,\s*', 'split' );
vectorcIC = regexp( cIC, '\s*,\s*', 'split' );

discStatesCode = '';
contStatesCode = '';
if ( NumDStates > 0 )

paramIdNum = num2cell( 1:NumParams );
paramStrToMatch = cellfun( @( x )[ '\<', x, '\>' ], ParameterName, 'UniformOutput', false );
mskParamUsedAsIC = cellfun( @( y )any( cellfun( @( x )~isempty( x ), regexp( vectordIC, y, 'end', 'once' ) ) ), paramStrToMatch );
mskParamIsDouble = strcmp( ParameterComplexity, 'COMPLEX_NO' ) & strcmp( ParameterDataType, 'real_T' );
tempCellToPrint = repmat( paramIdNum( mskParamUsedAsIC & mskParamIsDouble ), [ 10, 1 ] );
paramNeeded = '';
if ( ~isempty( tempCellToPrint ) )
paramInit = cellfun( @( x )sprintf( '%%<pp%d>', x ), paramIdNum( mskParamUsedAsIC & mskParamIsDouble ), 'UniformOutput', false );
dIC = regexprep( dIC, paramStrToMatch( mskParamUsedAsIC & mskParamIsDouble ), paramInit );
paramNeeded = sprintf( [ '\n  %%assign nelements%d = LibBlockParameterSize(P%d)\n' ...
, '  %%assign param_width%d = nelements%d[0] * nelements%d[1]\n' ...
, '  %%if (param_width%d) > 1\n' ...
, '    %%assign pp%d = LibBlockMatrixParameter(P%d)\n' ...
, '  %%else\n' ...
, '    %%assign pp%d = LibBlockParameter(P%d, "", "", 0)\n' ...
, '  %%endif\n' ...
 ], tempCellToPrint{ : } );
end 
discreteInitCondDec = sprintf( '  real_T initVector[%d] = {%s};\n', NumDStates, dIC );
discStatesCode = [ '{', ( newline ) ...
, paramNeeded ...
, discreteInitCondDec ...
, '  %assign rollVars = ["<dwork>/DSTATE"]', ( newline ) ...
, '  %assign rollRegions = [0:%<LibBlockDWorkWidth(DSTATE)-1>]', ( newline ) ...
, '  %roll sigIdx = rollRegions, lcv = 1, block, "Roller", rollVars', ( newline ) ...
, '    %if %<LibBlockDWorkWidth(DSTATE)> == 1', ( newline ) ...
, '      %<LibBlockDWork(DSTATE, "", lcv, sigIdx)> = initVector[0];', ( newline ) ...
, '    %else', ( newline ) ...
, '      %<LibBlockDWork(DSTATE, "", lcv, sigIdx)> = initVector[%<lcv>];', ( newline ) ...
, '    %endif', ( newline ) ...
, '  %endroll', ( newline ) ...
, '}', ( newline ) ...
 ];
end 


if ( NumCStates > 0 )

contStatesCode = sprintf( '  real_T *xC = &%%<LibBlockContinuousState("", "", 0)>;\n' );
paramIdNum = num2cell( 1:NumParams );
paramStrToMatch = cellfun( @( x )[ '\<', x, '\>' ], ParameterName, 'UniformOutput', false );
mskParamUsedAsIC = cellfun( @( y )any( cellfun( @( x )~isempty( x ), regexp( vectorcIC, y, 'end', 'once' ) ) ), paramStrToMatch );
mskParamIsDouble = strcmp( ParameterComplexity, 'COMPLEX_NO' ) & strcmp( ParameterDataType, 'real_T' );
tempCellToPrint = repmat( paramIdNum( mskParamUsedAsIC & mskParamIsDouble ), [ 10, 1 ] );
paramNeeded = '';
if ( ~isempty( tempCellToPrint ) )
paramInit = cellfun( @( x )sprintf( '%%<p_c%d>', x ), paramIdNum( mskParamUsedAsIC & mskParamIsDouble ), 'UniformOutput', false );

vectorcIC = regexprep( vectorcIC, paramStrToMatch( mskParamUsedAsIC & mskParamIsDouble ), paramInit );
paramNeeded = sprintf( [ '\n    %%assign pnelements%d = LibBlockParameterSize(P%d)\n' ...
, '  %%assign cparam_width%d = pnelements%d[0] * pnelements%d[1]\n' ...
, '  %%if (cparam_width%d) > 1\n' ...
, '    %%assign p_c%d = LibBlockMatrixParameter(P%d)\n' ...
, '  %%else\n' ...
, '    %%assign p_c%d = LibBlockParameter(P%d, "", "", 0)\n' ...
, '  %%endif\n' ...
 ], tempCellToPrint{ : } );
end 
continuousInitCondDec = '';
if ( ~isempty( vectorcIC ) )
tempCellToPrint = [ num2cell( 0:numel( vectorcIC ) - 1 );vectorcIC ];
continuousInitCondDec = [ ( newline ) ...
, sprintf( '  xC[%d] = %s;\n', tempCellToPrint{ : } ) ...
 ];
end 
contStatesCode = [ '{', ( newline ) ...
, contStatesCode ...
, paramNeeded ...
, continuousInitCondDec ...
, '}', ( newline ) ...
 ];
end 

mdlInitCondTLC = [ '%% InitializeConditions =========================================================', ( newline ) ...
, '%%', ( newline ) ...
, '%function InitializeConditions(block, system) Output', ( newline ) ...
, '  /* %<Type> Block: %<Name> */', ( newline ) ...
, discStatesCode ...
, ( newline ) ...
, contStatesCode ...
, ( newline ) ...
, '%endfunction', ( newline ) ...
 ];

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpNQsQ3e.p.
% Please follow local copyright laws when handling this file.

