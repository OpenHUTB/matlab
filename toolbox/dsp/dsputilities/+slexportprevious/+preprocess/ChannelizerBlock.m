function ChannelizerBlock(obj)




    verobj=obj.ver;
    msg='dsp:system:Channelizer:';

    if isR2020bOrEarlier(verobj)

        blks=obj.findBlocksWithMaskType('dsp.simulink.Channelizer');
        for idx=1:numel(blks)
            this_blk=blks{idx};
            decimationFactor=str2double(get_param(this_blk,'DecimationFactor'));
            numFrequencyBands=str2double(get_param(this_blk,'NumFrequencyBands'));
            if~mod(numFrequencyBands,decimationFactor)




                if~isR2019bOrEarlier(verobj)



                    identifyBlock=slexportprevious.rulefactory.identifyBlockBySID(blks{idx});
                    obj.appendRule(slexportprevious.rulefactory.addParameterToBlock(...
                    identifyBlock,'OversamplingRatio',num2str(numFrequencyBands/decimationFactor)));
                end
            else




                subsys_msg=DAStudio.message([msg,'EmptySubsystem_DecimationFactor']);
                subsys_err=DAStudio.message([msg,'NewFeaturesNotAvailable']);
                obj.replaceWithEmptySubsystem(this_blk,subsys_msg,subsys_err);
            end
        end
    end

    if isR2019bOrEarlier(verobj)



        blks=obj.findBlocksWithMaskType('dsp.simulink.Channelizer');
        for idx=1:numel(blks)
            this_blk=blks{idx};
            decimationFactor=str2double(get_param(this_blk,'DecimationFactor'));
            numFrequencyBands=str2double(get_param(this_blk,'NumFrequencyBands'));
            if(numFrequencyBands~=decimationFactor)


                subsys_msg=DAStudio.message([msg,'EmptySubsystem_DecimationFactor']);
                subsys_err=DAStudio.message([msg,'NewFeaturesNotAvailable']);
                obj.replaceWithEmptySubsystem(this_blk,subsys_msg,subsys_err);
            end
        end
    end

