function [ sutsOrigCreateSILBlkParamValue, checkSum1, checkSum2, checkSum3, checkSum4 ] = setupSILPILModeHelper( command, sut, harnessVerificationModeEnum, silBlock, sutsOrigCreateSILBlkParamValue, optArgs )

R36
command
sut
harnessVerificationModeEnum
silBlock
sutsOrigCreateSILBlkParamValue
optArgs.CalculateChecksums logical = true;
end 
checkSum1 = 0;
checkSum2 = 0;
checkSum3 = 0;
checkSum4 = 0;

if strcmp( get_param( sut, 'Type' ), 'block_diagram' )
return ;
end 

if strcmp( get( sut, 'Type' ), 'block' ) && strcmp( get( sut, 'BlockType' ), 'ModelReference' )
if ~strcmp( command, 'setupBD' )
return ;
end 
end 

switch command
case 'setupSS'
if harnessVerificationModeEnum ~= 1 && harnessVerificationModeEnum ~= 2
return ;
end 

if strcmp( get( sut, 'IsSubsystemVirtual' ), 'on' )
DAStudio.error( 'Simulink:Harness:SILPILNotSupportedForVirtualSubsystem' )
end 

systemModel = bdroot( sut );

if strcmp( get_param( systemModel, 'InitializeInteractiveRuns' ), 'on' )
DAStudio.error( 'Simulink:Harness:SILPILNotSupportedForFastRestart' );
end 

if ~strcmp( get_param( systemModel, 'IsERTTarget' ), 'on' )
DAStudio.error( 'Simulink:Harness:InvalidTargetForSILPIL' );
end 

if strcmp( get_param( systemModel, 'GenCodeOnly' ), 'on' )
DAStudio.error( 'Simulink:Harness:GenCodeOnlyNotSupportedForSILPIL' );
end 

if strcmp( get_param( systemModel, 'GenerateMakefile' ), 'off' )
DAStudio.error( 'Simulink:Harness:InvalidGenMakefileForSILPIL' );
end 

if optArgs.CalculateChecksums
checkSumInfo = Simulink.SubSystem.getChecksum( sut );
checkSum1 = checkSumInfo.Value( 1 );
checkSum2 = checkSumInfo.Value( 2 );
checkSum3 = checkSumInfo.Value( 3 );
checkSum4 = checkSumInfo.Value( 4 );
end 

sutsOrigCreateSILBlkParamValue = get_param( systemModel, 'CreateSILPILBlock' );
newVerificationMode = getVerificationModeStr( harnessVerificationModeEnum, false );
if ~strcmp( sutsOrigCreateSILBlkParamValue, newVerificationMode )
cs = getActiveConfigSet( systemModel );
if isa( cs, 'Simulink.ConfigSetRef' )
refCs = cs.getRefConfigSet(  );
cs = refCs;
end 
cs.set_param( 'CreateSILPILBlock', newVerificationMode );
else 
sutsOrigCreateSILBlkParamValue = [  ];
end 

case 'restoreSS'
if harnessVerificationModeEnum ~= 1 && harnessVerificationModeEnum ~= 2
return ;
end 

systemModel = bdroot( sut );

if ~isempty( sutsOrigCreateSILBlkParamValue )
cs = getActiveConfigSet( systemModel );
if isa( cs, 'Simulink.ConfigSetRef' )
refCs = cs.getRefConfigSet(  );
cs = refCs;
end 
cs.set_param( 'CreateSILPILBlock', sutsOrigCreateSILBlkParamValue );
sutsOrigCreateSILBlkParamValue = [  ];
end 

if silBlock < 0

else 
bdclose( bdroot( silBlock ) );
end 

case 'setupBD'

verificationModeStr = getVerificationModeStr( harnessVerificationModeEnum, true );
if strcmp( get_param( sut, 'ProtectedModel' ), 'on' ) && strcmp( verificationModeStr, 'Normal' )

verificationModeStr = 'Accelerator';
end 
set_param( sut, 'SimulationMode', verificationModeStr );


if harnessVerificationModeEnum == 1 || harnessVerificationModeEnum == 2
set_param( sut, 'CodeInterface', 'Top model' );
end 

otherwise 
assert( false, 'Invalid command' );
end 
end 

function result = getVerificationModeStr( harnessVerificationModeEnum, isBDHarness )
switch harnessVerificationModeEnum
case 0
if isBDHarness
result = 'Normal';
else 
result = 'None';
end 
case 1
if isBDHarness
result = 'Software-in-the-loop (SIL)';
else 
result = 'SIL';
end 
case 2
if isBDHarness
result = 'Processor-in-the-loop (PIL)';
else 
result = 'PIL';
end 
otherwise 
throw( MException( 'Simulink:Harness:InvalidVerificationMode', 'Invalid verification mode' ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpLWhffC.p.
% Please follow local copyright laws when handling this file.

