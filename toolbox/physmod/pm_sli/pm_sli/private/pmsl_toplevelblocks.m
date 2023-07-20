function topLevelBlocks=pmsl_toplevelblocks(mdl,includeInactive)













    if nargin==1
        includeInactive=false;
    end

    if~isa(mdl,'Simulink.BlockDiagram')
        mdl=get_param(mdl,'Object');
    end

    if includeInactive
        variantFilter=@Simulink.match.allVariants;
    else


        variantFilter=@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices;
    end
    topLevelBlocks=find_system(mdl.Handle,'LookUnderMasks','on',...
    'MatchFilter',variantFilter,...
    'Type','block','LinkStatus','resolved');
    if~isempty(topLevelBlocks)
        blklen=length(topLevelBlocks);
        maskTypes=cell(blklen,1);
        for idx=1:blklen
            maskTypes{idx,1}=get(topLevelBlocks(idx),'MaskType');
        end
        isPSB=strcmp(maskTypes,'PSB option menu block');
        topLevelBlocks=topLevelBlocks(~isPSB);
    end

end


