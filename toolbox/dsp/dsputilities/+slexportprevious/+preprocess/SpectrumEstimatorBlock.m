function SpectrumEstimatorBlock(obj)




    verobj=obj.ver;
    msg='dsp:SpectrumEstimation_BlockDialog:';

    if isR2018bOrEarlier(verobj)

        blks=obj.findBlocksWithMaskType('Spectrum Estimator');

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

    if isR2016bOrEarlier(verobj)

        blks=obj.findBlocksWithMaskType('Spectrum Estimator');

        for idx=1:numel(blks)
            this_blk=blks{idx};
            specMode=get_param(this_blk,'Method');
            if strcmp(specMode,'Filter bank')


                subsys_msg=DAStudio.message([msg,'EmptySubsystem_SpecCoef']);
                subsys_err=DAStudio.message([msg,'NewFeaturesNotAvailable']);
                obj.replaceWithEmptySubsystem(this_blk,subsys_msg,subsys_err);
            end
        end

    end
