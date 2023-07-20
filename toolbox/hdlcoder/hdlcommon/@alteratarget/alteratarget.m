


classdef alteratarget<handle



    enumeration
        AddSub,Mul,Div,Convert,Relop,Abs,Sqrt,InvSqrt,Recip,Exp,Log,Sin,Cos,MultAdd
    end

    methods(Static)
        [fid,mfparamsTempFile]=generateMegafunctionParamsFile
        ipgArgs=generateMegafunctionParamsFileFPF(baseType,fpFunction,fpSpecificArgs,megafunctionModule,latencyFreq,isFreqDriven,mnemonic,deviceInfo)
        status=generateMegafunction(targetCompInventory,megafunctionName,megafunctionModule,megafunctionParamsFile,latency,num)
        status=generateMegafunctionFPF(targetCompInventory,megafunctionName,ipgArgs,latencyFreq,isFreqDriven,num,dryRun,deviceInfo)
        status=codegenMegafunctionFPF(targetCompInventory,megafunctionName,baseType,fpFunction,fpS,latency,num,dryRun)
        name=generateMegafunctionName(baseType,className,mnemonic)
        name=generateMegafunctionNameFPF(baseType,className,mnemonic)
        resourceUsage=generateResourceUsage(megafunctionModule,megafunctionParamsFile,megafunctionName)
        resourceUsage=generateResourceUsageFPF(megafunctionModule,cmd,deviceFamily)
        [hC,numOfInst]=getTargetSpecificInstantiationCompsWithOneInput(targetCompInventory,hN,hInSignals,hOutSignals,altMegaFunctionName)
        [hC,numOfInst]=getTargetSpecificInstantiationCompsWithOneInputFPF(hN,hInSignals,hOutSignals,altMegaFunctionName,latency)
        hC=getTargetSpecificInstantiationCompsWithOneInputNoClock(targetCompInventory,hN,hInSignals,hOutSignals,altMegaFunctionName)
        [hC,numOfInst]=getTargetSpecificInstantiationCompsWithTwoInputs(targetCompInventory,hN,hInSignals,hOutSignals,altMegaFunctionName,latency)
        [hC,numOfInst]=getTargetSpecificInstantiationCompsWithTwoInputsFPF(hN,hInSignals,hOutSignals,altMegaFunctionName,latency)
        [hC,numOfInst]=getTargetSpecificInstantiationCompsWithThreeInputsFPF(hN,hInSignals,hOutSignals,altMegaFunctionName,latency)
        hC=getVectorMegaFunctionComp(targetCompInventory,hN,hInSignals,hOutSignals,alteraCompName,getScalarMegaFunctionComp,pipeline,num)
        hC=getVectorMegaFunctionCompFPF(hN,hInSignals,hOutSignals,alteraCompName,latency,getScalarMegaFunctionComp)
        hC=getAddSubMegaFunctionComp(targetCompInventory,hN,hInSignals,hOutSignals,className,mnemonic,pipeline)
        [altMegaFunctionName,extraDir,status]=getAddMegaFunctionCompFPF(targetCompInventory,inType,outType,className,latencyFreq,isFreqDriven,dryRun,deviceInfo)
        [altMegaFunctionName,extraDir,status]=getSubMegaFunctionCompFPF(targetCompInventory,inType,outType,className,latencyFreq,isFreqDriven,dryRun,deviceInfo)
        hC=getMulMegaFunctionComp(targetCompInventory,hN,hInSignals,hOutSignals,className,pipeline)
        [altMegaFunctionName,extraDir,status]=getMulMegaFunctionCompFPF(targetCompInventory,inType,outType,className,latencyFreq,isFreqDriven,dryRun,deviceInfo)
        hC=getDivMegaFunctionComp(targetCompInventory,hN,hInSignals,hOutSignals,className,pipeline)
        [altMegaFunctionName,extraDir,status]=getDivMegaFunctionCompFPF(targetCompInventory,inType,outType,className,latencyFreq,isFreqDriven,dryRun,deviceInfo)
        hC=getDTCMegaFunctionComp(targetCompInventory,hN,hInSignals,hOutSignals,className,pipeline)
        [altMegaFunctionName,extraDir,status]=getDTCMegaFunctionCompFPF(targetCompInventory,inType,outType,className,latencyFreq,isFreqDriven,dryRun,deviceInfo)
        hC=getRelopMegaFunctionComp(targetCompInventory,hN,hInSignals,hOutSignals,className,pipeline,relopType)
        [altMegaFunctionName,extraDir,status]=getRelopMegaFunctionCompFPF(targetCompInventory,inType,outType,className,latencyFreq,isFreqDriven,dryRun,deviceInfo,relopType)
        hC=getAbsMegaFunctionComp(targetCompInventory,hN,hInSignals,hOutSignals,className,pipeline)
        [altMegaFunctionName,extraDir,status]=getAbsMegaFunctionCompFPF(targetCompInventory,inType,outType,className,latencyFreq,isFreqDriven,dryRun,deviceInfo)
        hC=getSqrtMegaFunctionComp(targetCompInventory,hN,hInSignals,hOutSignals,className,pipeline)
        [altMegaFunctionName,extraDir,status]=getSqrtMegaFunctionCompFPF(targetCompInventory,inType,outType,className,latencyFreq,isFreqDriven,dryRun,deviceInfo)
        hC=getInvSqrtMegaFunctionComp(targetCompInventory,hN,hInSignals,hOutSignals,className,mnemonic,pipeline)
        [altMegaFunctionName,extraDir,status]=getInvSqrtMegaFunctionCompFPF(targetCompInventory,inType,outType,className,latencyFreq,isFreqDriven,dryRun,deviceInfo)
        hC=getLogMegaFunctionComp(targetCompInventory,hN,hInSignals,hOutSignals,className,mnemonic,pipeline)
        [altMegaFunctionName,extraDir,status]=getLogMegaFunctionCompFPF(targetCompInventory,inType,outType,className,latencyFreq,isFreqDriven,dryRun,deviceInfo)
        hC=getExpMegaFunctionComp(targetCompInventory,hN,hInSignals,hOutSignals,className,mnemonic,pipeline)
        [altMegaFunctionName,extraDir,status]=getExpMegaFunctionCompFPF(targetCompInventory,inType,outType,className,latencyFreq,isFreqDriven,dryRun,deviceInfo)
        hC=getInvMegaFunctionComp(targetCompInventory,hN,hInSignals,hOutSignals,className,mnemonic,pipeline)
        [altMegaFunctionName,extraDir,status]=getInvMegaFunctionCompFPF(targetCompInventory,inType,outType,className,latencyFreq,isFreqDriven,dryRun,deviceInfo)
        hC=getSinCosMegaFunctionComp(targetCompInventory,hN,hInSignals,hOutSignals,className,mnemonic,pipeline)
        [altMegaFunctionName,extraDir,status]=getSinMegaFunctionCompFPF(targetCompInventory,inType,outType,className,latencyFreq,isFreqDriven,dryRun,deviceInfo)
        [altMegaFunctionName,extraDir,status]=getCosMegaFunctionCompFPF(targetCompInventory,inType,outType,className,latencyFreq,isFreqDriven,dryRun,deviceInfo)
        [altMegaFunctionName,extraDir,status]=getMultAddMegaFunctionCompFPF(targetCompInventory,inType,outType,className,latencyFreq,isFreqDriven,dryRun,deviceInfo)
        hC=getVectorRelopMegaFunctionComp(targetCompInventory,hN,hInSignals,hOutSignals,className,getScalarRelopMegaFunctionComp,pipeline,relopType)
        [altMegaFunctionName,extraDir,status]=getMegaFunctionCompWithOneInputFPF(targetCompInventory,baseType,className,mnemonic,latencyFreq,isFreqDriven,fpFunction,dryRun,deviceInfo,fpSpecificArgs,nameSuffix)
        [altMegaFunctionName,extraDir,status]=getMegaFunctionCompWithTwoInputsFPF(targetCompInventory,baseType,className,mnemonic,latencyFreq,isFreqDriven,fpFunction,dryRun,deviceInfo,fpSpecificArgs,nameSuffix)
        [altMegaFunctionName,extraDir,status]=getMegaFunctionCompWithThreeInputsFPF(targetCompInventory,baseType,className,mnemonic,latencyFreq,isFreqDriven,fpFunction,dryRun,deviceInfo,fpSpecificArgs,nameSuffix)
        addPipelineInitialSequenceLogic(hN,hInSignals,hOutSignal,pipeline)
        [hC,status]=getMegaFunctionCompFPF(functor,args)


        fpFunction=getFPFunction(op,mnemonic)


        opInCLI=getOpInCLI(op)

        applyExtraArgs(fid,opInCLI,baseType)

        newFamily=isFamilyArria10OrLater(family)
        isa=isFamilyMax10(family)


        extraDir=getExtraDir(cmd,deviceFamily)

        useIPG=useIPGenerator()
    end
end


