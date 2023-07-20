function harnessObjSid=getOwnerObjectSIDInHarness(obj)

    harnessObjSid='';

    [isOwnedByActiveOwner,~,harnessInfo]=Simulink.harness.internal.sidmap.isObjectOwnedByActiveCUT(obj);
    if~isOwnedByActiveOwner||isempty(harnessInfo)||harnessInfo.verificationMode~=0
        return;
    end

    systemObjSid=Simulink.ID.getSID(obj);
    ownerSid=Simulink.ID.getSID(harnessInfo.ownerFullPath);
    cutSid=[harnessInfo.name,':1'];

    if strcmp(systemObjSid,ownerSid)

        harnessObjSid=cutSid;
    elseif hasSIDSpace(harnessInfo.ownerFullPath)

        sid=strrep(systemObjSid,ownerSid,'');
        harnessObjSid=[cutSid,sid];
    else

        harnessObjSid=[cutSid,strrep(systemObjSid,stripLastSIDNumber(ownerSid),'')];
    end
end

function result=hasSIDSpace(objPath)
    result=false;
    if~strcmp(get_param(objPath,'LinkStatus'),'none')
        result=true;
        return;
    end
    if strcmpi(get_param(objPath,'BlockType'),'SubSystem')&&~isempty(get_param(objPath,'ReferencedSubsystem'))
        result=true;
        return;
    end
    if slprivate('is_stateflow_based_block',get_param(objPath,'Handle'))
        result=true;
        return;
    end
end

function result=stripLastSIDNumber(sid)
    result=regexprep(sid,':\d+$','');
end

