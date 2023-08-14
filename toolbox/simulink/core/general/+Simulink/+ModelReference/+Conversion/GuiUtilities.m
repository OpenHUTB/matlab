classdef GuiUtilities<handle
    properties(Constant)
        AddLineOpts={'autorouting','on'};
        FindOptions={'SearchDepth',1,'LookUnderMasks','all','MatchFilter',@Simulink.match.allVariants,'IncludeCommented','on'}
    end

    methods(Static,Access=public)
        function blks=findTopLevelBlocks(subsys)
            blks=find_system(subsys,'SearchDepth',1,'LookUnderMasks','all',...
            'MatchFilter',@Simulink.match.allVariants,'IncludeCommented','on');
            blks=blks(2:end);
        end

        function aBlk=findModelBlock(subsys)
            aBlk=find_system(subsys,'SearchDepth',1,'LookUnderMasks','all',...
            'MatchFilter',@Simulink.match.allVariants,'BlockType','ModelReference');
        end
    end
end
