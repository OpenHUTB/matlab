function[wasSuccess,editNamePayLoad]=updateSignalName(appInstanceID,baseMsg,sigID,sigFullName,newSignalName,namesCantBeUsed,varargin)





    eng=sdi.Repository(true);

    wasSuccess=false;

    if isStringScalar(sigID)
        sigID=char(sigID);
    end

    if ischar(sigID)
        sigID=str2num(sigID);
    end

    if isStringScalar(sigFullName)
        sigFullName=char(sigFullName);
    end

    if isStringScalar(newSignalName)
        newSignalName=char(newSignalName);
    end

    shadowID=[];
    if~isempty(varargin)
        shadowID=varargin{1};

        if isStringScalar(shadowID)
            shadowID=char(shadowID);
        end

        if ischar(shadowID)
            shadowID=str2num(shadowID);
        end

    end

    aFactory=starepository.repositorysignal.Factory;
    concreteExtractor=aFactory.getSupportedExtractor(sigID);

    editNamePayLoad=updateSignalName(concreteExtractor,sigID,sigFullName,newSignalName,namesCantBeUsed);

    if~isempty(shadowID)
        updateSignalName(concreteExtractor,shadowID,sigFullName,newSignalName,{});
    end


    msgTopics=Simulink.sta.EditorTopics();
    fullChannel=sprintf('%s%s/%s',baseMsg,appInstanceID,msgTopics.ITEM_PROP_UPDATE);

    message.publish(fullChannel,editNamePayLoad);

    wasSuccess=true;

end

