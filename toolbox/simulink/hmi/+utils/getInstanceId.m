function instanceId=getInstanceId(blockObj)




    webBlockId=get(blockObj,'webBlockId');
    if isempty(get(blockObj,'ReferenceBlock'))
        instanceId=webBlockId;
    else
        handle=get(blockObj,'handle');
        instanceId=SLM3I.SLDomain.getInstanceWebBlockID(handle);
    end
end

