function retBlocks=findTargetBlocks(mdl,targetBlockTypes,topicFieldNames)









    retBlocks={};
    allBlks=find_system(mdl,'Type','Block');


    targetBlks={};
    for idx=1:length(allBlks)
        blkType=get_param(allBlks{idx},'BlockType');
        if any(strcmpi(targetBlockTypes,blkType))
            targetBlks{end+1}=allBlks(idx);%#ok
        end
    end


    for idx=length(targetBlks):-1:1


        blkpath=targetBlks{idx};
        blkType=get_param(blkpath,'BlockType');
        DlgPm=get_param(blkpath,'DialogParameters');
        DlgParams=fields(DlgPm{1});


        structBlock=struct('BlockPath',blkpath,'BlockType',blkType);
        for idy=1:length(DlgParams)


            strField=DlgParams{idy};
            strValue=get_param(blkpath,strField);
            structBlock.(strField)=strValue{:};


            if any(strcmpi(topicFieldNames,strField))
                structBlock.BlockTopicName=strValue{:};
            end
        end
        retBlocks{idx}=structBlock;
    end
end
