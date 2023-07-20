function[dataLoggingName,wasAlreadyLoggedByUs]=setTempLoggingNames(obj,sigHdl,indx,tmpName,cutIndex)













    isLoggingEnabled=strcmp(get_param(sigHdl,'DataLogging'),'on');
    if~isLoggingEnabled
        obj.portHandlesToRevert=[obj.portHandlesToRevert,sigHdl];
        set_param(sigHdl,'DataLogging','on');
    end

    dataLoggingName=get_param(sigHdl,'DataLoggingName');
    wasAlreadyLoggedByUs=obj.customSigNameMap.isKey(sigHdl);







    if~wasAlreadyLoggedByUs
        obj.customSigNameMap(sigHdl)=dataLoggingName;
        obj.customSigNameModeMap(sigHdl)=get_param(sigHdl,'DataLoggingNameMode');
        dataLoggingName=tmpName;
        if indx>0
            dataLoggingName=[dataLoggingName,num2str(indx)];
        end
        dataLoggingName=[dataLoggingName,'_',num2str(cutIndex)];
        set_param(sigHdl,'DataLoggingName',dataLoggingName);
        set_param(sigHdl,'DataLoggingNameMode','Custom');


        if~strcmp(tmpName,'sltest_dsm')
            obj.sigHierInfo(dataLoggingName)=get_param(sigHdl,'SignalHierarchy');
        end
    end

end

