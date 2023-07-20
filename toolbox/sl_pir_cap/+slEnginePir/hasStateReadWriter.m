function flag=hasStateReadWriter(mdls)
    flag=false;
    for i=1:length(mdls)
        mdlname=mdls{i};

        C=textscan(mdlname,'%s','Delimiter','/');
        modelName=C{1}{1};
        if~bdIsLoaded(modelName)
            continue;
        end

        statereadwriteblks=find_system(mdlname,'MatchFilter',@Simulink.match.allVariants,...
        'LookUnderMasks','all','FindAll','on','IncludeCommented','on',...
        'BlockType','SubSystem','SystemType','EventFunction');
        if~isempty(statereadwriteblks)
            flag=true;
            return;
        end
    end
end