function FourthOrderSectionFilter(obj)




    verobj=obj.ver;
    msg='dsp:system:FourthOrderSectionFilter:';

    if isR2022aOrEarlier(verobj)

        blks=obj.findBlocksWithMaskType('dsp.simulink.FourthOrderSectionFilter');
        for idx=1:numel(blks)
            this_block=blks{idx};
            this_block_handle=getSimulinkBlockHandle(this_block);
            coeffSource=get_param(this_block_handle,'CoefficientSource');
            if strcmpi(coeffSource,'Filter object')

                subsys_msg=DAStudio.message([msg,'EmptySubsystem_CoefficientSource']);
                subsys_err=DAStudio.message([msg,'NewFeaturesNotAvailable']);
                obj.replaceWithEmptySubsystem(this_block,subsys_msg,subsys_err);
            elseif strcmpi(coeffSource,'Input ports')

                identifyBlock=slexportprevious.rulefactory.identifyBlockBySID(blks{idx});
                obj.appendRule(slexportprevious.rulefactory.addParameterToBlock(...
                identifyBlock,'CoefficientsPort','on'));
            else

                identifyBlock=slexportprevious.rulefactory.identifyBlockBySID(blks{idx});
                obj.appendRule(slexportprevious.rulefactory.addParameterToBlock(...
                identifyBlock,'CoefficientsPort','off'));
            end

        end
    end

    if isR2021bOrEarlier(verobj)


        blks=obj.findBlocksWithMaskType('dsp.simulink.FourthOrderSectionFilter');
        for idx=1:numel(blks)
            this_blk=blks{idx};

            subsys_msg=DAStudio.message([msg,'EmptySubsystem_DecimationFactor']);
            subsys_err=DAStudio.message([msg,'NewFeaturesNotAvailable']);
            obj.replaceWithEmptySubsystem(this_blk,subsys_msg,subsys_err);
        end
    end

