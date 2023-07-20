function CrossSpectrumEstimator(obj)





    modelNameNoPath=obj.modelName;
    verobj=obj.ver;

    msg='dsp:SpectrumEstimation_BlockDialog:';
    if isR2018bOrEarlier(verobj)

        blks=obj.findBlocksWithMaskType('Cross-Spectrum Estimator');

        for idx=1:numel(blks)
            this_blk=blks{idx};
            avgMode=get_param(this_blk,'AveragingMethod');
            if strcmp(avgMode,'Exponential')


                subsys_msg=DAStudio.message([msg,'EmptySubsystem_ExpAvg']);
                subsys_err=DAStudio.message([msg,'NewFeaturesNotAvailable']);
                obj.replaceWithEmptySubsystem(this_blk,subsys_msg,subsys_err);
            end
        end

    end

    if isR2015aOrEarlier(verobj)
        blocks=obj.findBlocksWithMaskType('Cross-Spectrum Estimator');
        rep_blocks={};
        for index=1:length(blocks)
            blk=blocks{index};
            WindowMode=get_param(blk,'WindowMode');
            [Overlap,~]=slResolve(get_param(blk,'Overlap'),blk);
            if(isempty(Overlap)||(Overlap~=0))||~strcmp(WindowMode,'Same as input frame length')
                rep_blocks{end+1}=blk;%#ok
            end
        end

        n2bReplaced=length(rep_blocks);
        for i=1:n2bReplaced
            blk=blocks{i};
            subsys_msg=DAStudio.message('dsp:system:SpectrumEstimatorBase:EmptySubsystem_CSE_NewFeatures');
            subsys_err=DAStudio.message('dsp:system:SpectrumEstimatorBase:New15bFeaturesNotAvailable');
            obj.replaceWithEmptySubsystem(blk,subsys_msg,subsys_err);
        end
    end

end