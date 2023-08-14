function checkSupportPackage(simTargetLib,simTargetLang,gpuAcceleration)

    persistent calledCpu;
    persistent calledGpu;

    isCpp=strcmpi(simTargetLang,'c++');
    noCpuSupprtPackage=~gpuAcceleration&&~dlcoder_base.internal.isMATLABCoderDLTargetsInstalled;
    noGpuSupportPackage=gpuAcceleration&&~dlcoder_base.internal.isGpuCoderDLTargetsInstalled;


    if isempty(calledCpu)&&isCpp&&noCpuSupprtPackage
        spkgName='MATLAB Coder Interface for Deep Learning Libraries';
        spkgBaseCode='ML_DEEPLEARNING_LIB';
        throwSupportPackageWarning(simTargetLib,spkgName,spkgBaseCode);
        calledCpu=true;
    end


    if isempty(calledGpu)&&isCpp&&noGpuSupportPackage
        spkgName='GPU Coder Interface for Deep Learning Libraries';
        spkgBaseCode='GPU_DEEPLEARNING_LIB';
        throwSupportPackageWarning(simTargetLib,spkgName,spkgBaseCode);
        calledGpu=true;
    end

end

function throwSupportPackageWarning(simTargetLib,spkgName,spkgBaseCode)
    warning(message('deep_blocks:common:MissingSupportPackage',simTargetLib,spkgName,spkgBaseCode));
end