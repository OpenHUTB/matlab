function out=hasModelRefBlocks(mdl)





    if Simulink.internal.useFindSystemVariantsMatchFilter()
        mdls=find_mdlrefs(mdl,'AllLevels',false,...
        'MatchFilter',@Simulink.match.activeVariants);
    else
        mdls=find_mdlrefs(mdl,'AllLevels',false,'Variants','ActiveVariants');
    end
    out=numel(mdls)>1;
end

