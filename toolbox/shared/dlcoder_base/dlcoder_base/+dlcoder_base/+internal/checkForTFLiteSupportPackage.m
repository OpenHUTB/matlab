function checkForTFLiteSupportPackage(buildWorkflow)




    if nargin==0
        buildWorkflow='unknown';
    end

    if~dlcoder_base.internal.isDLInterfaceForTFLiteInstalled
        spkgname='Deep Learning Toolbox Interface for TensorFlow Lite';
        spkgbasecode='DL_TENSORFLOW_LITE';
        throwSupportPackageError(buildWorkflow,spkgname,spkgbasecode);
    end

end

function throwSupportPackageError(buildWorkflow,spkgname,spkgbasecode)



    switch buildWorkflow
    case 'simulink'
        error(message('gpucoder:cnncodegen:missing_tflite_support_package_simulink',spkgname,spkgbasecode));
    case 'simulation'
        error(message('gpucoder:cnncodegen:missing_tflite_support_package_simulation',spkgname,spkgbasecode));
    case 'default'
        error(message('gpucoder:cnncodegen:missing_tflite_support_package_fordefault',spkgname));
    otherwise
        error(message('gpucoder:cnncodegen:missing_tflite_support_package',spkgname,spkgbasecode));
    end
end
