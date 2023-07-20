function browserWebBlockId=getBrowserWebBlockId(blockObj)


    handle=get(blockObj,'handle');
    browserWebBlockId=SLM3I.SLDomain.getBrowserWebBlockID(handle);
end

