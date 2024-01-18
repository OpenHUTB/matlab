function[modelUri,objId]=correctSimulinkUriAndId(modelUri,objId)
    [modelUri,subId]=fixSimulinkModelUri(modelUri);
    if~isempty(subId)
        objId=fixSimulinkId(objId,subId);
    end
end


function[fileName,subId]=fixSimulinkModelUri(storedName)
    if rmisl.isHarnessIdString(storedName)
        [mdlName,remainder]=strtok(storedName,':');
        subId=[':',rmisl.harnessTargetIdToSID(remainder)];
    elseif rmisl.isSidString(storedName)
        [mdlName,subId]=strtok(storedName,':');
    else
        mdlName=storedName;
        subId='';
    end
    fileName=getSimulinkFileName(mdlName);
end


function fileName=getSimulinkFileName(mdlName)
    if dig.isProductInstalled('Simulink')&&is_simulink_loaded()
        try
            fullFileName=get_param(mdlName,'FileName');
        catch

            fullFileName=which(mdlName);
        end
    else
        fullFileName=which(mdlName);
    end
    if isempty(fullFileName)
        fileName=[mdlName,'.slx'];
    else
        fileName=slreq.uri.getShortNameExt(fullFileName);
    end
end


function longId=fixSimulinkId(localId,parentId)

    if contains(parentId,':urn')
        longId=[parentId,localId];
    else
        longId=slreq.utils.getLongIdFromShortId(parentId,localId);
    end
end
