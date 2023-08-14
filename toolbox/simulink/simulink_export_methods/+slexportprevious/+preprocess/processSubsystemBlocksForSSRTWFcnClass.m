function processSubsystemBlocksForSSRTWFcnClass(obj)





    if isR2006bOrEarlier(obj.ver)

        subSysBlocks=find_system(obj.modelName,'AllBlocks','on',...
        'MatchFilter',@Simulink.match.allVariants,...
        'LookUnderMasks','on',...
        'BlockType','SubSystem');

        for i=1:length(subSysBlocks)
            blk=subSysBlocks{i};

            try
                obj=get_param(blk,'SSRTWFcnClass');
                if~isempty(obj)
                    set_param(blk,'SSRTWFcnClass',[]);
                end
            catch %#ok<CTCH>
            end
        end
    elseif isR2007bOrEarlier(obj.ver)

        subSysBlocks=find_system(obj.modelName,'AllBlocks','on',...
        'MatchFilter',@Simulink.match.allVariants,...
        'LookUnderMasks','on',...
        'BlockType','SubSystem');

        for i=1:length(subSysBlocks)
            blk=subSysBlocks{i};


            try
                obj=get_param(blk,'SSRTWFcnClass');
                if~isempty(obj)&&isa(obj,'RTW.AutosarInterface')
                    set_param(blk,'SSRTWFcnClass',[]);
                end
            catch %#ok<CTCH>
            end
        end

    end

end
