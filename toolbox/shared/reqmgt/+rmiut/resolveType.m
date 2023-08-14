function[domainName,mwItem]=resolveType(obj)


















    if ischar(obj)
        [artifact,suffix]=strtok(obj,'|');
        mwItem.artifact=artifact;
        mwItem.id=suffix(2:end);
        if rmisl.isHarnessIdString(artifact)||rmisl.isSidString(artifact)
            domainName='simulink';
            [sModelName,textNodeId]=strtok(artifact,':');
            mwItem.id=slreq.utils.getLongIdFromShortId(textNodeId,mwItem.id);
            try
                mwItem.artifact=get_param(sModelName,'FileName');
            catch
                mwItem.artifact=sModelName;
            end
        elseif exist(artifact,'file')==2&&rmitm.isTest(obj)
            domainName='testmgr';
        elseif rmide.isDataEntry(obj)
            domainName='data';
        elseif rmiml.canLink(obj)
            domainName='matlab';
        else
            domainName='simulink';
        end
    elseif isa(obj,'Simulink.DDEAdapter')
        domainName='data';
        [mwItem.id,mwItem.artifact]=rmide.getGuid(obj);
    elseif isa(obj,'slreq.data.Requirement')
        domainName='slreq';
        mwItem.artifact=obj.getReqSet.filepath;
        mwItem.id=num2str(obj.sid);
    elseif rmifa.isFaultInfoObj(obj)
        domainName='fault';
        mwItem=slreq.utils.getRmiStruct(obj);
        return;
    elseif rmism.isSafetyManagerObj(obj)
        domainName='safetymanager';
        if(nargout>1)
            mwItem=rmism.getRmiStruct(obj,false);
        end
        return;
    else
        domainName='simulink';
        [isSf,objH]=rmi.resolveobj(obj);
        [mdlName,mwItem.id]=rmidata.getRmiKeys(objH,isSf);
        mwItem.artifact=get_param(mdlName,'FileName');
    end

    mwItem.domain=['linktype_rmi_',domainName];

end
