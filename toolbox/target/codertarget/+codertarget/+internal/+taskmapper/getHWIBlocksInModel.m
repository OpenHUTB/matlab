function hwiBlk=getHWIBlocksInModel(modelName)




    hwiBlk={};%#ok<NASGU> % store all task manager blocks in the model

    hwiBlk=find_system(modelName,'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.allVariants,...
    'FollowLinks','on','MaskType','HardwareInterrupt');

end