function IIRHalfband(obj)







    decimMsg='dsp:system:IIRHalfbandDecimator:';
    interpMsg='dsp:system:IIRHalfbandInterpolator:';

    if isR2015bOrEarlier(obj.ver)
        decimBlocks=obj.findBlocksWithMaskType('dsp.simulink.IIRHalfbandDecimator');
        interpBlocks=obj.findBlocksWithMaskType('dsp.simulink.IIRHalfbandInterpolator');
        blocks=[decimBlocks;interpBlocks];

        isDecim=[true(size(decimBlocks));false(size(interpBlocks))];
        for ii=1:numel(blocks)
            blk=blocks{ii};
            specMode=get_param(blk,'Specification');
            isInCoefMode=strcmp(specMode,'Coefficients');
            if isInCoefMode
                if isDecim(ii)
                    msg=decimMsg;
                else
                    msg=interpMsg;
                end
                subsys_msg=DAStudio.message([msg,'EmptySubsystem_IIR_NewFeatures']);
                subsys_err=DAStudio.message([msg,'New16aFeaturesNotAvailable']);
                obj.replaceWithEmptySubsystem(blk,subsys_msg,subsys_err);
            end
        end
    end

end

