function flag=hasSimscapeBlock(mdls)
    flag=false;
    for i=1:length(mdls)
        mdlname=mdls{i};

        C=textscan(mdlname,'%s','Delimiter','/');
        modelName=C{1}{1};
        if~bdIsLoaded(modelName)
            continue;
        end


        simscapeblocks=find_system(mdlname,'MatchFilter',@Simulink.match.allVariants,'LookUnderMasks','all',...
        'FindAll','on','IncludeCommented','on','BlockType','SimscapeBlock');
        if~isempty(simscapeblocks)
            flag=true;
            return;
        end
    end
end