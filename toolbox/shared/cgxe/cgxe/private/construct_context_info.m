function[ctxInfo,nonChecksumFields]=construct_context_info(modelName)








    nonChecksumFields={'modelHandle','usedTargetFunctionLibH'};

    ctxInfo.modelHandle=get_param(modelName,'Handle');
    ctxInfo.usedTargetFunctionLibH=get_param(modelName,'SimTargetFcnLibHandle');
    ctxInfo.maxStackUsage=sfc('coder_options','maxStackUsage');
    ctxInfo.constantFoldingTimeOut=sf('feature','EML ConstantFoldingTimeOut');
    ctxInfo.enableCtrlC=isequal(get_param(modelName,'SimCtrlC'),'on');
    ctxInfo.nonFinitesSupport=isequal(get_param(modelName,'SupportNonFinite'),'on');
    ctxInfo.useBLAS=cgxeCodingBlas;
    ctxInfo.echoExpressions=isequal(get_param(modelName,'SFSimEcho'),'on');
    ctxInfo.checkRuntimeErrors=~sfc('coder_options','forceDebugOff');
    ctxInfo.genImportedTypeDefs=strcmp(get_param(modelName,'SimGenImportedTypeDefs'),'on');
    ctxInfo.codingOverflow=~isequal(get_param(modelName,'IntegerOverflowMsg'),'none');
    ctxInfo.codingFasterRun=CGXE.Utils.isSimOptimizationsOn(modelName);
    ctxInfo.gencpp=strcmpi(get_param(modelName,'SimTargetLang'),'C++');

    [algorithmWordsizes,targetWordsizes,algorithmHwInfo,targetHwInfo,rtwSettingsInfo]=...
    get_word_sizes(modelName);

    ctxInfo.algorithmWordsizes=algorithmWordsizes;
    ctxInfo.targetWordsizes=targetWordsizes;
    ctxInfo.algorithmHwInfo=algorithmHwInfo;
    ctxInfo.targetHwInfo=targetHwInfo;
    ctxInfo.rtwSettingsInfo=rtwSettingsInfo;
    ctxInfo.enableRuntimeRecursion=strcmp(get_param(modelName,'EnableRuntimeRecursion'),'on');
    ctxInfo.compileTimeRecursionLimit=get_param(modelName,'CompileTimeRecursionLimit');
    ctxInfo.enableImplicitExpansion=strcmp(get_param(modelName,'EnableImplicitExpansion'),'on');
    ctxInfo.MATLABDynamicMemAlloc=strcmp(get_param(modelName,'MATLABDynamicMemAlloc'),'on');
    ctxInfo.MATLABDynamicMemAllocThreshold=get_param(modelName,'MATLABDynamicMemAllocThreshold');
    ctxInfo.MemcpyThreshold=64;

    ctxInfo.simHardwareAcceleration=get_param(modelName,'SimHardwareAcceleration');
    ctxInfo.SIMDSupport=simdVersion(ctxInfo.simHardwareAcceleration);

    if strcmp(get_param(modelName,'MulticoreDesignerActive'),'on')
        ctxInfo.DataflowProfilingChecksum=get_param(modelName,'DataflowProfileChecksum');
    end
end

function version=simdVersion(simHardwareAccel)



    cpuInfo=private_sl_CPUInfo;
    shaNative=strcmpi(simHardwareAccel,"native");
    if cpuInfo.AVX512&&shaNative
        version="AVX512";
    elseif cpuInfo.AVX2&&shaNative
        version="AVX2";
    else
        version='';
    end
end


