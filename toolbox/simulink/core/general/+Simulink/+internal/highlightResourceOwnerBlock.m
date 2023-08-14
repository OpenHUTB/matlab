function highlightResourceOwnerBlock(blk)




    blkHandle=get_param(blk,'Handle');



    hilitedBlks=find_system(...
    bdroot(blkHandle),'LookUnderMasks','on','FollowLinks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'HiliteAncestors','find');
    for idx=1:numel(hilitedBlks)
        blk=hilitedBlks(idx);
        set_param(blk,'HiliteAncestors','none');
    end


    parent=get_param(blkHandle,'Parent');
    selectedBlks=find_system(parent,'SearchDepth',1,'Selected','on');
    selectedBlks=setdiff(selectedBlks,{parent});
    for idx=1:numel(selectedBlks)
        blk=selectedBlks{idx};
        set_param(blk,'Selected','off');
    end


    set_param(blkHandle,'Selected','on');
    hilite_system(blkHandle,'find');

end
