%#codegen



function registerDependencies()
    coder.allowpcode('plain');

    targetLib=coder.internal.coderNetworkUtils.getTargetLib;

    if strcmpi(targetLib,'cudnn')
        dltargets.cudnn.cudnnApi.register();
    elseif strcmpi(targetLib,'tensorrt')
        dltargets.tensorrt.tensorrtApi.register();
    elseif(strcmpi(targetLib,'mkldnn')||strcmpi(targetLib,'onednn'))
        dltargets.onednn.onednnApi.register();
    elseif strcmpi(targetLib,'arm-compute')
        dltargets.arm_neon.armcomputeApi.register();
    elseif strcmpi(targetLib,'cmsis-nn')
        dltargets.cmsis_nn.cmsisNNApi.register();
    end


end
