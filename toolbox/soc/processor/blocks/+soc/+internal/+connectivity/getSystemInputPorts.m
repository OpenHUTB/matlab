function res=getSystemInputPorts(sys)




    res=find_system(sys,'FollowLinks','on','SearchDepth',1,...
    'LookUnderMasks','on','BlockType','Inport');
end