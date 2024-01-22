function MPCControllerBlock(obj)

    if isInVersionInterval(obj.ver,'R2014b','R2018a')
        AllBlocks=obj.findBlocksWithMaskType('Adaptive MPC');
        if~isempty(AllBlocks)
            for ct=1:length(AllBlocks)
                blk=AllBlocks{ct};
                HasConstraints=strcmp(get_param(blk,'umin_inport'),'on')||...
                strcmp(get_param(blk,'umax_inport'),'on')||...
                strcmp(get_param(blk,'ymin_inport'),'on')||...
                strcmp(get_param(blk,'ymax_inport'),'on');
                if HasConstraints
                    identifyBlock=slexportprevious.rulefactory.identifyBlockBySID(blk);
                    obj.appendRule(slexportprevious.rulefactory.addParameterToBlock(identifyBlock,'lims_inport','on'));
                end
            end
        end
    end

    if isInVersionInterval(obj.ver,'R2008b','R2018a')
        AllBlocks=find_system(obj.modelName,'FollowLinks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all','IncludeCommented','on','MaskType','Multiple MPC');
        if~isempty(AllBlocks)
            for ct=1:length(AllBlocks)
                blk=AllBlocks{ct};
                HasConstraints=strcmp(get_param(blk,'umin_inport_multiple'),'on')||...
                strcmp(get_param(blk,'umax_inport_multiple'),'on')||...
                strcmp(get_param(blk,'ymin_inport_multiple'),'on')||...
                strcmp(get_param(blk,'ymax_inport_multiple'),'on');
                if HasConstraints
                    identifyBlock=slexportprevious.rulefactory.identifyBlockBySID(blk);
                    obj.appendRule(slexportprevious.rulefactory.addParameterToBlock(identifyBlock,'lims_inport_multiple','on'));
                end
            end
        end
    end

    if isInVersionInterval(obj.ver,'R2007b','R2018a')
        AllBlocks=find_system(obj.modelName,'FollowLinks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'LookUnderMasks','all','IncludeCommented','on','MaskType','MPC');
        if~isempty(AllBlocks)
            for ct=1:length(AllBlocks)
                blk=AllBlocks{ct};
                HasConstraints=strcmp(get_param(blk,'umin_inport'),'on')||...
                strcmp(get_param(blk,'umax_inport'),'on')||...
                strcmp(get_param(blk,'ymin_inport'),'on')||...
                strcmp(get_param(blk,'ymax_inport'),'on');
                if HasConstraints
                    identifyBlock=slexportprevious.rulefactory.identifyBlockBySID(blk);
                    obj.appendRule(slexportprevious.rulefactory.addParameterToBlock(identifyBlock,'lims_inport','on'));
                end
            end
        end
    end
