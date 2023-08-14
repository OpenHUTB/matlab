function[wasSuccess,change_summary]=updateSignalUnits(sigID,newUnitValue,baseMsg,appInstanceID,varargin)




    try
        if isStringScalar(sigID)
            sigID=char(sigID);
        end

        if ischar(sigID)
            sigID=str2double(sigID);
        end

        if isStringScalar(newUnitValue)
            newUnitValue=char(newUnitValue);
        end

        newUnitValue=replace(newUnitValue,' ','');

        repoUtil=starepository.RepositoryUtility;
        oldValue=repoUtil.getUnit(sigID);
        setUnit(repoUtil,sigID,newUnitValue);


        aFactory=starepository.repositorysignal.Factory;
        concreteExtractor=aFactory.getSupportedExtractor(sigID);
        allIds=concreteExtractor.getIDsForPropertyUpdates(sigID);


        allIds(allIds==sigID)=[];

        if~isempty(allIds)
            for kID=1:length(allIds)
                setUnit(repoUtil,allIds(kID),newUnitValue);
            end
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

            if~isempty(shadowID)
                setUnit(repoUtil,shadowID,newUnitValue);


                aFactory=starepository.repositorysignal.Factory;
                concreteExtractor=aFactory.getSupportedExtractor(shadowID);
                allShadowIds=concreteExtractor.getIDsForPropertyUpdates(shadowID);


                allShadowIds(allShadowIds==sigID)=[];

                if~isempty(allShadowIds)
                    for kID=1:length(allShadowIds)
                        setUnit(repoUtil,allShadowIds(kID),newUnitValue);
                    end
                end
            end
        end



        change_summary=struct;
        change_summary.id=sigID;
        change_summary.propertyname='Units';
        change_summary.oldValue=oldValue;
        change_summary.newValue=newUnitValue;

        wasSuccess=true;


        msgTopics=Simulink.sta.EditorTopics();
        fullChannel=sprintf('%s%s/%s',baseMsg,appInstanceID,msgTopics.ITEM_PROP_UPDATE);
        payload=cell(1,1+length(allIds));
        payload{1}=change_summary;
        if~isempty(allIds)
            for kID=1:length(allIds)
                tempSummary=change_summary;
                tempSummary.id=allIds(kID);
                payload{kID+1}=tempSummary;

            end
        end

        message.publish(fullChannel,payload);

    catch
        wasSuccess=false;

        change_summary=struct;
        change_summary.id=sigID;
        change_summary.propertyname='Units';
        change_summary.oldValue=oldValue;
        change_summary.newValue=newUnitValue;
    end





