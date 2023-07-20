function supportedTargets=getTargetsSupportedForINT8()





    supportedTargets={'cudnn','arm-compute','cmsis-nn'};
    if dlcoderfeature('EnableINT8ForC')
        supportedTargets{end+1}='none';
    end

end
