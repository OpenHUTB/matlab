function result=isBlockInModel(modelPath,blockPath)




    findOptions=Simulink.FindOptions('FollowLinks',true,"LookUnderMasks","All","Variants","AllVariants");
    allBlocks=getfullname(Simulink.findBlocks(modelPath,findOptions));

    for idx=1:length(allBlocks)
        if(strcmp(allBlocks{idx},blockPath))
            result=true;
            return;
        end
    end
    result=false;
end

