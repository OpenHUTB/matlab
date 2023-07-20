function linkString=exploreListNodeLink(resultData)
    if strcmp(resultData.DetailedInfo.SlVarSourceType,'model workspace')
        linkString=['matlab: slprivate(''exploreListNode'',''',resultData.DetailedInfo.SlVarSource,''',''model'',''',resultData.Data,''')'];
    elseif strcmp(resultData.DetailedInfo.SlVarSourceType,'base workspace')
        linkString=['matlab: slprivate(''exploreListNode'',''',resultData.DetailedInfo.SlVarSource,''',''base'',''',resultData.Data,''')'];
    elseif strcmp(resultData.DetailedInfo.SlVarSourceType,'data dictionary')
        linkString=['matlab: slprivate(''exploreListNode'',''',resultData.DetailedInfo.SlVarSource,''',''dictionary'',''',resultData.Data,''')'];
    elseif strcmp(resultData.DetailedInfo.SlVarSourceType,'unknown source')
        linkString=[];
    elseif strcmp(resultData.DetailedInfo.SlVarSourceType,'MATLAB file')
        linkString=[];
    elseif strcmp(resultData.DetailedInfo.SlVarSourceType,'mask workspace')
        linkString=['matlab: hOpenMaskEditor(''',resultData.DetailedInfo.SlVarSource,''')'];
    else
        error(message...
        ('ModelAdvisor:engine:MAUnknownSourceType'));
    end
end