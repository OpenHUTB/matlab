function[numBlocksDeleted,sopts]=removeFromGotoBlocks(FullPath,mdlName,conditionFunction,sopts,numBlocksDeleted)
    gotoBlocks=find_system(FullPath,'SearchDepth',1,'LookUnderMasks','all','BlockType','Goto');
    fromBlocks=find_system(FullPath,'SearchDepth',1,'LookUnderMasks','all','BlockType','From');
    deleteFromList={};
    deletedGotoList={};

    for i=1:length(gotoBlocks)
        for j=1:length(fromBlocks)
            if~ismember(fromBlocks{j},deleteFromList)&&~ismember(gotoBlocks{i},deletedGotoList)...
                &&strcmp(get_param(fromBlocks{j},'Parent'),get_param(gotoBlocks{i},'Parent'))&&strcmp(get_param(fromBlocks{j},'GotoTag'),get_param(gotoBlocks{i},'GotoTag'))
                [srcPortList]=Simulink.SimplifyModel.getSrcDstList(gotoBlocks{i},false);
                [~,dstPortList]=Simulink.SimplifyModel.getSrcDstList(fromBlocks{j},true);

                for k=1:length(dstPortList)
                    if~isempty(srcPortList)
                        add_line(FullPath,srcPortList,dstPortList(k));
                    end
                end
                deleteFromList{end+1}=fromBlocks{j};%#ok<AGROW>
                delete_block(fromBlocks{j});
            end
        end
    end

    deletedList=[deleteFromList,deletedGotoList];

    [~,numBlocksDeleted,sopts]=Simulink.SimplifyModel.checkCondition(mdlName,conditionFunction,sopts,deletedList,numBlocksDeleted,'Deleted block ');
