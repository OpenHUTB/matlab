function MovingStatistics(obj)




    verobj=obj.ver;
    msg='dsp:system:MovingStatistic:';

    if isR2022aOrEarlier(verobj)







        maskMovStats={'dsp.simulink.MovingAverage',...
        'dsp.simulink.MovingVariance',...
        'dsp.simulink.MovingRMS',...
        'dsp.simulink.MovingStandardDeviation',...
        'dsp.simulink.PowerMeter'};
        for i=1:numel(maskMovStats)
            blks=obj.findBlocksWithMaskType(maskMovStats{i});
            for idx=1:numel(blks)
                this_block=blks{idx};
                this_block_handle=getSimulinkBlockHandle(this_block);
                OL=str2double(get_param(this_block_handle,'OverlapLength'));
                WL=str2double(get_param(this_block_handle,'WindowLength'));

                subsys_msg=DAStudio.message([msg,'EmptySubsystem_OverlapLength']);
                subsys_err=DAStudio.message([msg,'NewFeaturesNotAvailable']);

                if(WL-OL~=1)

                    obj.replaceWithEmptySubsystem(this_block,subsys_msg,subsys_err);
                end
            end
        end
    end

