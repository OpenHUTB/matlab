function m2m_hiliteCandidateGroup(aBlkGroup)




    systems=find_system('type','block_diagram');
    for i=1:length(systems)
        set_param(systems{i},'HiliteAncestors','off');
    end
    blks=split(aBlkGroup,' ');


    blks=blks(2:end);
    for bIdx=1:numel(blks)
        hilite_system(blks(bIdx));
    end
end


