function[wasSuccess,change_summary]=updateSignalInterpolation(sigID,newInterpVal,baseMsg,appInstanceID,varargin)




    if isStringScalar(sigID)
        sigID=char(sigID);
    end

    if ischar(sigID)
        sigID=str2double(sigID);
    end

    repoUtil=starepository.RepositoryUtility;
    oldInterpVal="";
    try
        oldInterpVal=repoUtil.getInterpMethod(sigID);
        setInterpMethod(repoUtil,sigID,newInterpVal);


        aFactory=starepository.repositorysignal.Factory;
        concreteExtractor=aFactory.getSupportedExtractor(sigID);
        allIds=concreteExtractor.getIDsForPropertyUpdates(sigID);


        allIds(allIds==sigID)=[];

        if~isempty(allIds)
            for kID=1:length(allIds)
                setInterpMethod(repoUtil,allIds(kID),newInterpVal);
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
                setInterpMethod(repoUtil,shadowID,newInterpVal);


                aFactory=starepository.repositorysignal.Factory;
                concreteExtractor=aFactory.getSupportedExtractor(shadowID);
                allShadowIds=concreteExtractor.getIDsForPropertyUpdates(shadowID);


                allShadowIds(allShadowIds==sigID)=[];

                if~isempty(allShadowIds)
                    for kID=1:length(allShadowIds)
                        setInterpMethod(repoUtil,allShadowIds(kID),newInterpVal);
                    end
                end
            end
        end


        msgTopics=Simulink.sta.EditorTopics();
        change_summary=struct;
        change_summary.id=sigID;
        change_summary.propertyname='Interpolation';
        change_summary.oldValue=oldInterpVal;
        change_summary.newValue=newInterpVal;
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

        wasSuccess=true;

    catch
        change_summary=struct;
        change_summary.id=sigID;
        change_summary.propertyname='Interpolation';
        change_summary.oldValue=oldInterpVal;
        change_summary.newValue=newInterpVal;
        wasSuccess=false;
    end




