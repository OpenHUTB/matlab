function req=makeReq(target)












    req=rmi.createEmptyReqs(1);
    req.reqsys='linktype_rmi_simulink';
    if strncmp(class(target),'Simulink.',length('Simulink.'))
        target=target.Handle;
        sfRoot=[];
    elseif strncmp(class(target),'Stateflow.',length('Stateflow.'))
        target=target.Id;
        sfRoot=Stateflow.Root;
    elseif ischar(target)||isstruct(target)


        [req.doc,req.id,req.description]=parseCodeRangeIds(target);
        return;
    else
        if ceil(target(1))==target(1)
            sfRoot=Stateflow.Root;
        else
            sfRoot=[];
        end
    end
    if length(target)>1










        req=[];
    else
        [req.doc,req.id]=getNavIDs(target,sfRoot);
        [~,labelInfo]=rmi.objinfo(target);

        my_chars=double(labelInfo);
        labelInfo(my_chars<32|my_chars==127)=' ';
        req.description=labelInfo;
    end
end

function[modelName,localSID]=getNavIDs(obj,sfRoot)
    if isempty(sfRoot)
        if sysarch.isZCPort(obj)
            localSID=sysarch.getIdForLinking(obj);
            modelName=get_param(bdroot(obj),'Name');
        else
            sid=Simulink.ID.getSID(obj);
            [modelName,localSID]=strtok(sid,':');
        end
    else
        sid=Simulink.ID.getSID(sfRoot.idToHandle(obj));
        [modelName,localSID]=strtok(sid,':');
    end





    if rmisl.isComponentHarness(modelName)
        [~,hostName]=Simulink.harness.internal.sidmap.getHarnessModelUniqueName(modelName);


        [modelName,harnessID]=strtok(hostName,':');
        localSID=[harnessID,localSID];
    end
end

function[modelName,localId,label]=parseCodeRangeIds(targetInfo)
    if isstruct(targetInfo)
        mfSID=targetInfo.srcKey;
        [~,rangeId]=rmiml.ensureBookmark(mfSID,targetInfo.selectedRange);
    else
        [mfSID,rangeId]=strtok(targetInfo,'|');
        if~isempty(rangeId)
            rangeId(1)=[];
        end
        if any(rangeId=='-')

            [mfSID,rangeId]=rmiml.ensureBookmark(mfSID,rangeId);
        end
    end
    [modelName,sid]=strtok(mfSID,':');
    localId=slreq.utils.getLongIdFromShortId(sid,rangeId);
    if isstruct(targetInfo)
        text=rmiut.filterChars(targetInfo.selectedText);
        if length(text)>30
            text=[text(1:20),'..'];
        end
        label=getString(message('Slvnv:reqmgt:LinkSet:updateContents:LocationInDoc',text,modelName));
    else
        label=getString(message('Slvnv:reqmgt:LinkSet:updateContents:LocationInDoc',rangeId,modelName));
    end
end

