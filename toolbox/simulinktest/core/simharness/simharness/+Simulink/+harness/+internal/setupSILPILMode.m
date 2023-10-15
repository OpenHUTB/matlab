function [ checkSum1, checkSum2, checkSum3, checkSum4 ] = setupSILPILMode( command, sut, harnessVerificationModeEnum, silBlock )

arguments
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


