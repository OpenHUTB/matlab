function arrayOfProps=updateChildFullName(sourceID,parentFullName)






    repoUtil=starepository.RepositoryUtility();

    arrayOfProps=[];


    signalChildrenIDs=getChildrenIDsInSiblingOrder(repoUtil,sourceID);
    arrayIDX=1;

    signalType=getMetaDataByName(repoUtil,sourceID,'SignalType');
    IS_COMPLEX=strcmp(signalType,getString(message('sl_sta_general:common:Complex')));

    if IS_COMPLEX
        idxDot=strfind(parentFullName,'.');
        if~isempty(idxDot)
            parentFullName=parentFullName(1:idxDot(end)-1);
        end
    end

    if~IS_COMPLEX
        for kChild=1:length(signalChildrenIDs)
            idForDisplays=resolveSignalIdForProperties(repoUtil,signalChildrenIDs(kChild));
            arrayOfProps(arrayIDX).id=idForDisplays;
            arrayOfProps(arrayIDX).propertyname='FullName';
            arrayOfProps(arrayIDX).newValue=[parentFullName,'.',getSignalLabel(repoUtil,idForDisplays)];

            grandChildrenIDs=getChildrenIDsInSiblingOrder(repoUtil,signalChildrenIDs(kChild));

            if~isempty(grandChildrenIDs)
                grandKidArrayOfProps=Simulink.sta.signaltree.updateChildFullName(signalChildrenIDs(kChild),arrayOfProps(arrayIDX).newValue);
                arrayOfProps=[arrayOfProps,grandKidArrayOfProps];
            end

            arrayIDX=length(arrayOfProps)+1;

        end
    end
