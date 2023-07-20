function checkForSupportPackages(targetlib,buildWorkflow)




    if nargin==1
        buildWorkflow='unknown';
    end

    switch targetlib
    case{'cudnn','tensorrt','arm-compute-mali'}
        if~dlcoder_base.internal.isGpuCoderDLTargetsInstalled
            spkgname='GPU Coder Interface for Deep Learning Libraries';
            spkgbasecode='GPU_DEEPLEARNING_LIB';
            throwSupportPackageError(buildWorkflow,targetlib,spkgname,spkgbasecode);
        end
    case{'mkldnn','onednn','arm-compute','none','cmsis-nn'}
        if~dlcoder_base.internal.isMATLABCoderDLTargetsInstalled
            spkgname='MATLAB Coder Interface for Deep Learning Libraries';
            spkgbasecode='ML_DEEPLEARNING_LIB';
            throwSupportPackageError(buildWorkflow,targetlib,spkgname,spkgbasecode);
        end
    end
end

function throwSupportPackageError(buildWorkflow,targetlib,spkgname,spkgbasecode)



    switch buildWorkflow
    case 'simulink'
        error(message('gpucoder:cnncodegen:missing_support_package_simulink',targetlib,spkgname,spkgbasecode));
    case 'simulation'
        error(message('gpucoder:cnncodegen:missing_support_package_simulation',targetlib,spkgname,spkgbasecode));
    otherwise
        error(message('gpucoder:cnncodegen:missing_support_package',targetlib,spkgname,spkgbasecode));
    end
end
