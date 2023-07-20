function availToolList=getAvailableToolForBoard(obj,boardName)




    availableToolList=obj.hAvailableToolList.getToolNameList;
    requiredToolList=obj.getRequiredTool(boardName);

    if isempty(requiredToolList)
        availToolList={obj.EmptyToolStr};
        return
    end
    availToolList=intersect(requiredToolList,availableToolList,'stable');

    if isempty(availToolList)
        requiredToolVersionList=obj.getRequiredToolVersion(boardName);
        for ii=1:length(requiredToolList)
            requiredTool=requiredToolList{ii};
            if~isempty(requiredToolVersionList)
                requiredToolVersion=sprintf(' %s',requiredToolVersionList{ii});
            else
                requiredToolVersion='';
            end
            if ii==1
                requiredToolStr=sprintf('%s%s',requiredTool,requiredToolVersion);
            else
                requiredToolStr=sprintf('%s, %s%s',requiredToolStr,requiredTool,requiredToolVersion);
            end
        end
        setupToolMsg=obj.printSetupToolMsg;
        error(message('hdlcommon:workflow:ToolNotAvailableForBoard',boardName,requiredToolStr,setupToolMsg));
    end
end
