function res=getSystemOutputPorts(sys)




    res=find_system(sys,'FollowLinks','on','SearchDepth',1,...
    'LookUnderMasks','on','BlockType','Outport');
end