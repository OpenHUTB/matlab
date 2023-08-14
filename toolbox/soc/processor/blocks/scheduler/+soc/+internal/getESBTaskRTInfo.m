function info=getESBTaskRTInfo(topMdl)






    tskBlks=find_system(topMdl,'LookUnderMasks','all','FollowLinks','on',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'MaskType','ESB Task');
    info=containers.Map;
    data=getTaskInformation;
    if isempty(data),return;end
    for idx=1:numel(tskBlks)
        blk=tskBlks{idx};
        taskName=get_param(blk,'TaskName');
        [offset,numDataCachingBlocks]=...
        getTaskDataCachingBlocksInfo(topMdl,data,taskName);
        for idx2=1:numDataCachingBlocks
            rtName=['socdcb',num2str(offset),'_',num2str(idx2)];
            if~info.isKey(taskName)
                rt{1}=rtName;
                info(taskName)=rt;
            else
                rt=info(taskName);
                rt{end+1}=rtName;%#ok<AGROW>
                info(taskName)=rt;
            end
        end
    end
end


function[offset,count]=getTaskDataCachingBlocksInfo(topMdl,data,taskName)
    import soc.internal.connectivity.*
    handles=data{1};
    offsets=data{2};
    counts=data{3};
    numDataCachingBlocks=length(data{1});
    offset=0;
    count=0;
    for idx=1:numDataCachingBlocks
        blockHandle=handles(idx);
        name=getTaskNameForFcnCallInportBlock(topMdl,blockHandle);
        if isequal(name,taskName)
            offset=offsets(idx);
            count=counts(idx);
            break
        end
    end
end


function data=getTaskInformation
    data=[];
    try
        fid=fopen('soc_RTBRateInfo.txt','r');
        if~isequal(fid,-1)
            data=textscan(fid,'%f64 %d %d');
            fclose(fid);
        end
    catch
        fclose(fid);
    end
end
