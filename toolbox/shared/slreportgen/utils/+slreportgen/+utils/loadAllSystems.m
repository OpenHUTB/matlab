function loadAllSystems(obj)










    modelH=slreportgen.utils.getModelHandle(obj);
    libdata=libinfo(modelH,...
    'MatchFilter',@Simulink.match.allVariants,...
    'FollowLinks','on',...
    'LookUnderMasks','all');

    n=numel(libdata);
    for i=1:n
        try
            load_system(libdata(i).Library);
        catch ME
            warning(ME.identifier,'%s',ME.message);
        end
    end
end