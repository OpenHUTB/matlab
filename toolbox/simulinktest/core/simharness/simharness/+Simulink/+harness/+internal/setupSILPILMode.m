function [ checkSum1, checkSum2, checkSum3, checkSum4 ] = setupSILPILMode( command, sut, harnessVerificationModeEnum, silBlock )

R36
command
sut
harnessVerificationModeEnum
silBlock = [  ];
end 
persistent sutsOrigCreateSILBlkParamValue;
[ sutsOrigCreateSILBlkParamValue, checkSum1, checkSum2, checkSum3, checkSum4 ] =  ...
Simulink.harness.internal.setupSILPILModeHelper(  ...
command, sut, harnessVerificationModeEnum, silBlock, sutsOrigCreateSILBlkParamValue );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpLOLD7X.p.
% Please follow local copyright laws when handling this file.

