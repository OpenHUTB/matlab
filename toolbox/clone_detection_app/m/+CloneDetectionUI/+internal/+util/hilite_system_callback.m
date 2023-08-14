function hilite_system_callback(blockSid)



    allSys=find_system('SearchDepth',0);
    for ii=1:length(allSys)
        if~strcmp(allSys{ii},blockSid)
            set_param(allSys{ii},'HiliteAncestors','off');
            set_param(allSys{ii},'HiliteAncestors','fade');
        else
            open(blockSid);
        end
    end

    set_param(0,'HiliteAncestorsData',...
    struct('HiliteType','user2',...
    'ForegroundColor','black',...
    'BackgroundColor','green'));
    try
        if~strcmp(get_param(blockSid,'Type'),'block_diagram')
            hilite_system(blockSid,'user2');
        end
    catch ME
        DAStudio.error(ME.message);
    end

end

