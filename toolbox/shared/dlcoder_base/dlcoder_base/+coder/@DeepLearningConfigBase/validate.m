


function validate(this,codeConfig,isdlcodegen)

    if nargin<3
        isdlcodegen=false;
    end


    switch(lower(this.TargetLibrary))

    case 'cudnn'
        dlcoder_base.internal.checkCuDNNParams(codeConfig,this);
    case 'tensorrt'
        dlcoder_base.internal.checkTensorrtParams(codeConfig,this);
    case{'mkldnn','onednn'}
        dlcoder_base.internal.checkOneDNNParams(codeConfig);
    case 'arm-compute'
        dlcoder_base.internal.checkArmComputeParams(codeConfig,this);
    case 'arm-compute-mali'
        dlcoder_base.internal.checkArmComputeMALIParams(codeConfig,this,isdlcodegen);
    case 'none'
        dlcoder_base.internal.checkCCodeParams(codeConfig,this);
    case 'cmsis-nn'
        dlcoder_base.internal.checkCMSISNNParams(codeConfig,this);
    otherwise
        error(message('dnn_core:cnncodegen:InvalidDeepLearningConfigParameter',...
        'TargetLib',...
        this.TargetLibrary,...
        'cudnn, tensorrt, mkldnn and arm-compute'));
    end

end


