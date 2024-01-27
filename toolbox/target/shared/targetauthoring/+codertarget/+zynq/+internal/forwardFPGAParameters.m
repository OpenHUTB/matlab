function forwardFPGAParameters(hCS,param)

    HardwareBoardFeatureSet=get_param(hCS,'HardwareBoardFeatureSet');

    if codertarget.utils.isSoCInstalled&&strcmp(HardwareBoardFeatureSet,'SoCBlockset')
        soc.internal.forwardFPGAParameters(hCS,param);
    end

end