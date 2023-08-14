function hsubsystem=utilAddSubsystem(system,subsystemName,subsystemPos,backgroundColor)



    if isempty(subsystemPos)

        allBlks=find_system(system,'SearchDepth',1,...
        'FollowLinks','on',...
        'LookUnderMasks','all',...
        'IncludeCommented','on');
        allBlks=setdiff(allBlks,system);


        allBlkPos=get_param(allBlks,'Position');
        topLeftPos=[Inf,Inf];
        for ii=1:numel(allBlkPos)
            blkPos=allBlkPos{ii};
            if topLeftPos(1)>blkPos(1)
                topLeftPos(1)=blkPos(1);
            end
            if topLeftPos(2)>blkPos(2)
                topLeftPos(2)=blkPos(2);
            end
        end
        subsystemPos=[topLeftPos(1),topLeftPos(2)-100,topLeftPos(1)+50,topLeftPos(2)-50];
    end

    hsubsystem=add_block('built-in/Subsystem',strcat(system,'/',subsystemName),...
    'MakeNameUnique','on',...
    'Position',subsystemPos,...
    'BackgroundColor',backgroundColor);
end