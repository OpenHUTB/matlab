function res=getSystemTriggerPort(sys)




    res=find_system(sys,'FollowLinks','on','SearchDepth',1,...
    'LookUnderMasks','on','BlockType','TriggerPort');
end