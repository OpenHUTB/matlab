function[handle,grpInfo,mdlName]=rmiIdToHandle(doc,locationStr)
    handle=[];
    grpInfo='';
    [~,mdlName,mdlExt]=fileparts(doc);
    if~isempty(mdlExt)
        load_system(doc);
    else
        load_system(mdlName);
    end
    if~isempty(locationStr)
        if locationStr(1)=='@'
            locationStr=locationStr(2:end);
        end
        if strcmp(locationStr,':')
            locationStr='';
        elseif rmisl.isHarnessIdString(locationStr)
            mdlH=get_param(mdlName,'Handle');
            [harnessName,harnessId,localSid]=rmisl.resolveHarnessObjRef(mdlH,locationStr,false);
            if~isempty(harnessName)


                [handle,grpInfo,mdlName]=rmisl.rmiIdToHandle(harnessName,localSid);
            else



                harnessInfo=Simulink.harness.find(mdlName,'UUID',harnessId);
                if~isempty(harnessInfo)
                    mdlName=harnessInfo.name;
                end
            end
            return;
        elseif any(locationStr=='.')
            [locationStr,grpInfo]=strtok(locationStr,'.');
        end
    end
    sid=[mdlName,locationStr];
    handle=Simulink.ID.getHandle(sid);
end
