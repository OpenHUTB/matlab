function blockTypes=summ_getSplitPropTypes(~,objectList,~)









    blockTypes=rptgen.safeGet(objectList,'MaskType','get_param');

    for i=1:length(objectList)
        thisBlk=objectList(i);
        if slprivate('is_stateflow_based_block',thisBlk)
            blockTypes(i)=get_param(thisBlk,'SFBlockType');
        end
    end

    unfilled=find(cellfun('isempty',blockTypes));
    blockTypes(unfilled)=rptgen.safeGet(objectList(unfilled),'BlockType','get_param');

    badTypes={'SubSystem','Scope',''};


    for i=1:length(badTypes)
        badIdx=find(strcmp(blockTypes,badTypes{i}));
        if~isempty(badIdx)
            [blockTypes{badIdx}]=deal('N/A');
        end
    end
