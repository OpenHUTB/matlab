function errSig=setDSMTempLogging(obj,dsmInfo,cutInd)









    errSig='';
    dsmBlks=dsmInfo.dsmBlks;
    numDsmBlks=length(dsmBlks);
    for j=1:numDsmBlks
        dsmBlk=dsmBlks(j);

        isLoggingEnabled=get_param(dsmBlk.Handle,'DataLogging')=="on";
        if~isLoggingEnabled
            obj.portHandlesToRevert=[obj.portHandlesToRevert,dsmBlk.Handle];
            set_param(dsmBlk.Handle,'DataLogging','on');
        end








        dStoreLoggingName=get_param(dsmBlk.Handle,'DataLoggingName');
        wasAlreadyLoggedByUs=obj.dataStoreLoggingInfo.isKey(dStoreLoggingName);
        if~wasAlreadyLoggedByUs
            obj.customSigNameMap(dsmBlk.Handle)=dStoreLoggingName;
            obj.customSigNameModeMap(dsmBlk.Handle)=get_param(dsmBlk.Handle,'DataLoggingNameMode');
            set_param(dsmBlk.Handle,'DataLoggingNameMode','Custom');
            dsmName=get_param(dsmBlk.Handle,'DataStoreName');

            set_param(dsmBlk.Handle,'DataLoggingName',['stm_',dsmName,'_DSM_',num2str(j),'_',num2str(cutInd)]);
        end
        dStoreLoggingName=get_param(dsmBlk.Handle,'DataLoggingName');
        dsmName=get_param(dsmBlk.Handle,'DataStoreName');


        obj.cacheDsmConnectivityInfo(dStoreLoggingName,dsmBlk.UserType,cutInd,dsmName);
    end


    sigObjs=dsmInfo.sigObjs;
    numSigObjs=numel(sigObjs);
    for j=1:numSigObjs
        sigObj=sigObjs(j);

        if strcmp(sigObj.SourceType,'base workspace')
            wkSpc='base';
        else

            wkSpc=get_param(obj.topModel,'ModelWorkspace');
        end



        currErrSig='';
        dType=evalin(wkSpc,[sigObj.Name,'.DataType;']);
        dTypeStr=strsplit(dType,':');
        if length(dTypeStr)>1
            if strcmp(dTypeStr{1},'Bus')
                errSig=sigObj.Name;
                currErrSig=errSig;
            end
        end
        if isempty(currErrSig)

            lg=evalin(wkSpc,[sigObj.Name,'.LoggingInfo.DataLogging;']);
            if~lg
                evalin(wkSpc,[sigObj.Name,'.LoggingInfo.DataLogging = 1;']);
                obj.sigObjToRevert=[obj.sigObjToRevert,sigObj];
            end

            dStoreLoggingName=evalin(wkSpc,[sigObj.Name,'.LoggingInfo.LoggingName;']);
            wasAlreadyLoggedByUs=obj.dataStoreLoggingInfo.isKey(dStoreLoggingName);
            if~wasAlreadyLoggedByUs
                dsmLoggingMode=evalin(wkSpc,[sigObj.Name,'.LoggingInfo.NameMode;']);
                obj.sigObjLoggingNameRevert=[obj.sigObjLoggingNameRevert,struct('signalObject',sigObj,'loggingName',dStoreLoggingName,'loggingNameMode',dsmLoggingMode)];
                uniqueLoggingName=['stm_',sigObj.Name,'_GDSM_',num2str(j),'_',num2str(cutInd)];
                evalin(wkSpc,[sigObj.Name,'.LoggingInfo.LoggingName = ''',uniqueLoggingName,''';']);
                evalin(wkSpc,[sigObj.Name,'.LoggingInfo.NameMode = 1;'])
            end
            dStoreLoggingName=evalin(wkSpc,[sigObj.Name,'.LoggingInfo.LoggingName;']);
            obj.cacheDsmConnectivityInfo(dStoreLoggingName,sigObj.UserType,cutInd,sigObj.Name);
        end
    end
end
