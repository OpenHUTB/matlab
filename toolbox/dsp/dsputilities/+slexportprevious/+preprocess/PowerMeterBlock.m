function PowerMeterBlock(obj)




    verobj=obj.ver;
    if isR2022aOrEarlier(verobj)

        blks=obj.findBlocksWithMaskType('dsp.simulink.PowerMeter');
        for idx=1:numel(blks)
            this_blk=blks{idx};
            computeCCDF=strcmpi(get_param(this_blk,'ComputeCCDF'),'On');
            if computeCCDF

                subsys_msg=DAStudio.message('dsp:system:powermeter:EmptySubsystem_ComputeCCDF');
                subsys_err=DAStudio.message('dsp:system:powermeter:NewFeaturesNotAvailable');
                obj.replaceWithEmptySubsystem(this_blk,subsys_msg,subsys_err);
            end
        end
    end

    if isR2021bOrEarlier(verobj)

        blks=obj.findBlocksWithMaskType('dsp.simulink.PowerMeter');
        for idx=1:numel(blks)
            this_blk=blks{idx};
            powerUnits=get_param(this_blk,'OutputPowerUnits');
            identifyBlock=slexportprevious.rulefactory.identifyBlockBySID(blks{idx});
            obj.appendRule(slexportprevious.rulefactory.addParameterToBlock(...
            identifyBlock,'PowerUnits',powerUnits));
        end
    end