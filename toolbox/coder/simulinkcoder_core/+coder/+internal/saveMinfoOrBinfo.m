function saveMinfoOrBinfo(cache,fullMatFileName)




    infoStruct=cache;
    infoStruct.configSet=[];
    infoStructConfigSet=cache.configSet;
    save(fullMatFileName,'infoStruct','infoStructConfigSet')
