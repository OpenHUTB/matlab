
function numBlk=getNumberOfBlocks(model)





    allblks=find_system(model,'MatchFilter',@Simulink.match.allVariants,...
    'IncludeCommented','on','LookUnderMasks','all','FollowLinks','on');
    allblksIn=find_system(model,'MatchFilter',@Simulink.match.allVariants,...
    'IncludeCommented','on','LookUnderMasks','all','FollowLinks',...
    'on','blocktype','Inport');
    allblksOut=find_system(model,'MatchFilter',@Simulink.match.allVariants,...
    'IncludeCommented','on','LookUnderMasks','all','FollowLinks',...
    'on','blocktype','Outport');
    numBlk=length(allblks)-1-length(allblksIn)-length(allblksOut);
end


