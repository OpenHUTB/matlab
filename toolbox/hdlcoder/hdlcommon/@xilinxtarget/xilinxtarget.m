


classdef xilinxtarget<handle



    methods(Static)
        [fid,paramsTempFile]=generateCoregenParamsFile(targetCompInventory,latency)
        extraArgs=generateStandardCoregenParams(fid,opInCLI,dataType)
        status=generateCoregenBlk(targetCompInventory,coregenBlkName,coregenModule,coregenParamsFile,extraArgs,latency,num)
        name=generateCoregenBlkName(baseType,className,mnemonic)
        resourceUsage=generateResourceUsage(coregenModule,coregenParamsFile,coregenBlkName)
        [hC,num]=getTargetSpecificInstantiationCompsWithOneInput(targetCompInventory,hN,hInSignals,hOutSignals,coregenBlkName)
        [hC,num]=getTargetSpecificInstantiationCompsWithTwoInputs(targetCompInventory,hN,hInSignals,hOutSignals,coregenBlkName)
        hC=getVectorCoreGenComp(targetCompInventory,hN,hInSignals,hOutSignals,xilinxCompName,getScalarCoreGenComp,pipeline)
        hC=getAddSubCoreGenComp(targetCompInventory,hN,hInSignals,hOutSignals,className,mnemonic,pipeline)
        hC=getMulCoreGenComp(targetCompInventory,hN,hInSignals,hOutSignals,className,pipeline)
        hC=getDivCoreGenComp(targetCompInventory,hN,hInSignals,hOutSignals,className,pipeline)
        hC=getSqrtCoreGenComp(targetCompInventory,hN,hInSignals,hOutSignals,className,pipeline)
        hC=getRelopCoreGenComp(targetCompInventory,hN,hInSignals,hOutSignals,className,pipeline,relopType)
        [hC,num]=getTargetSpecificRelopInstantiationComp(targetCompInventory,hN,hInSignals,hOutSignals,coregenBlkName)
        hC=getDTCCoreGenComp(targetCompInventory,hN,hInSignals,hOutSignals,className,pipeline)
    end
end

