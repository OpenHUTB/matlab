function FarrowRateConverterBlock(obj)




    verobj=obj.ver;
    msg='dsp:system:FarrowRateConverter:';

    if isRelease(verobj,'R2022a')





        blks=obj.findBlocksWithMaskType('dsp.simulink.FarrowRateConverter');

        for idx=1:numel(blks)
            this_blk=blks{idx};
            identifyBlock=slexportprevious.rulefactory.identifyBlockBySID(blks{idx});
            specMode=get_param(this_blk,'AllowArbitraryInputLength');
            addParamRule=slexportprevious.rulefactory.addParameterToBlock(identifyBlock,'EnableVarSize',specMode);
            obj.appendRule(addParamRule);
        end
    end

    if isR2021bOrEarlier(verobj)


        blks=obj.findBlocksWithMaskType('dsp.simulink.FarrowRateConverter');

        for idx=1:numel(blks)
            this_blk=blks{idx};
            specMode=get_param(this_blk,'AllowArbitraryInputLength');
            if strcmp(specMode,'on')


                subsys_msg=DAStudio.message([msg,'EmptySubsystem_VarsizeSignal']);
                subsys_err=DAStudio.message([msg,'NewFeaturesNotAvailable']);
                obj.replaceWithEmptySubsystem(this_blk,subsys_msg,subsys_err);
            end
        end
    end


    if isR2016aOrEarlier(verobj)



        blks=obj.findBlocksWithMaskType('dsp.simulink.FarrowRateConverter');

        for idx=1:numel(blks)
            this_blk=blks{idx};
            specMode=get_param(this_blk,'Specification');
            if~strcmp(specMode,'Polynomial order')


                subsys_msg=DAStudio.message([msg,'EmptySubsystem_SpecCoef']);
                subsys_err=DAStudio.message([msg,'NewFeaturesNotAvailable']);
                obj.replaceWithEmptySubsystem(this_blk,subsys_msg,subsys_err);
            end
        end







    end
