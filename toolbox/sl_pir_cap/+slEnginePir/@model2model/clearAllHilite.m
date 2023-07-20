function clearAllHilite(this)%#ok



    systems=find_system('type','block_diagram');
    for i=1:length(systems)
        set_param(systems{i},'HiliteAncestors','off');
    end
end
