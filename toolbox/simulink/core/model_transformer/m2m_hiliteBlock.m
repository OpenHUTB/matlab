function m2m_hiliteBlock(aBlk)



    systems=find_system('type','block_diagram');
    for i=1:length(systems)
        set_param(systems{i},'HiliteAncestors','off');
    end

    hilite_system(aBlk);
end
