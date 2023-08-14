function blkCellH=i_getOutportBlockHandles(model)









    blocks=find_system(model,...
    'LookUnderMasks','on',...
    'MatchFilter',@Simulink.match.allVariants,...
    'FollowLinks','on',...
    'SearchDepth',1,...
    'BlockType','Outport');
    blkHandles=get_param(blocks,'Handle');
    blkH=Simulink.variant.utils.i_cell2mat(blkHandles);
    blkCellH=i_getAllPortBlockHandles(blkH);
end
