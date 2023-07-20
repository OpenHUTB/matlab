function clearHighlightingForStateAccess(chartH)


    hilitedBlks=find_system(chartH,'LookUnderMasks','on','FollowLinks','on',...
    'MatchFilter',@Simulink.match.allVariants,'HiliteAncestors','find');
    for idx=1:numel(hilitedBlks)
        blk=hilitedBlks(idx);
        set_param(blk,'HiliteAncestors','none');
    end
end