function bindableMetaData=processForSelectionInCtxModel(bindableMetaData,topMdlName)






    if~isfield(bindableMetaData,'hierarchicalPathArr')||numel(bindableMetaData.hierarchicalPathArr)<2





        return;
    end
    topPathStr=bindableMetaData.hierarchicalPathArr{2};
    try
        csRefBlk=get_param(bdroot(topPathStr),'CoSimContext');
    catch
        return;
    end
    if~isempty(csRefBlk)&&strcmp(bdroot(csRefBlk),topMdlName)
        bindableMetaData.hierarchicalPathArr{1}=[csRefBlk,'|',bindableMetaData.hierarchicalPathArr{1}];
        bindableMetaData.hierarchicalPathArr=[bindableMetaData.hierarchicalPathArr(1);{csRefBlk};bindableMetaData.hierarchicalPathArr(2:end)];
        idx=strfind(bindableMetaData.id,':');
        assert(~isempty(idx));
        idx=idx(1);
        bindableMetaData.id=[bindableMetaData.id(1:idx),csRefBlk,'|',bindableMetaData.id(idx+1:end)];
        if isfield(bindableMetaData,'tooltip')
            bindableMetaData.tooltip=[csRefBlk,'|',bindableMetaData.tooltip];
        end
    end

end