function setRowFilter(moduleIdStr,filterString)













    dxlCmd=filterStringToDXL(strtok(moduleIdStr),strtrim(filterString));

    hDoors=rmidoors.comApp();
    rmidoors.invoke(hDoors,dxlCmd);
    commandResult=hDoors.Result;

    if~isempty(commandResult)
        error(message('Slvnv:reqmgt:DoorsApiError',commandResult));
    end
end

function cmd=filterStringToDXL(moduleId,filterString)
    if isempty(filterString)
        cmd=['disableRowFilter("',moduleId,'")'];
    elseif contains(filterString,'==')
        cmd=makeAttrValueFilterCmd(moduleId,filterString);
    elseif startsWith(lower(filterString),'contains')
        cmd=makeRowContentFilterCmd(moduleId,filterString);
    elseif startsWith(lower(filterString),'attribute')
        cmd=makeAttrContentFilter(moduleId,filterString);
    else
        error(message('Slvnv:slreq_import:DoorsRowFilterUnsupported',filterString));
    end
end

function cmd=makeAttrValueFilterCmd(moduleId,filterString)
    tokens=regexp(filterString,'^(.+)==(.+)$','tokens');
    attrName=strtrim(tokens{1}{1});
    attrValue=strtrim(tokens{1}{2});
    cmd=['setAttributeValueFilter("',moduleId,'","',attrName,'","',attrValue,'")'];
end

function cmd=makeRowContentFilterCmd(moduleId,filterString)
    singleQuoteIdx=find(double(filterString)==39);
    pattern=filterString(singleQuoteIdx(1)+1:singleQuoteIdx(2)-1);
    if contains(filterString,'regexp')
        cmd=['setRowContentFilter("',moduleId,'","',pattern,'",true)'];
    else
        cmd=['setRowContentFilter("',moduleId,'","',pattern,'",false)'];
    end
end

function cmd=makeAttrContentFilter(moduleId,filterString)
    singleQuoteIdx=find(double(filterString)==39);
    attrName=filterString(singleQuoteIdx(1)+1:singleQuoteIdx(2)-1);
    pattern=filterString(singleQuoteIdx(3)+1:singleQuoteIdx(4)-1);
    if contains(filterString,'regexp')
        cmd=['setAttributeContentFilter("',moduleId,'","',attrName,'","',pattern,'",true)'];
    else
        cmd=['setAttributeContentFilter("',moduleId,'","',attrName,'","',pattern,'",false)'];
    end
end
