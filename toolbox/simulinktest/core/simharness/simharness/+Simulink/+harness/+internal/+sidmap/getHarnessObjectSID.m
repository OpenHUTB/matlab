function sid=getHarnessObjectSID(obj)
    sid=[];
    [isOwnedBySUT,objHandle,harnessInfo]=Simulink.harness.internal.sidmap.isObjectOwnedByCUT(obj);
    if isempty(objHandle)||isempty(harnessInfo)
        return;
    end

    harnessObjSid=Simulink.ID.getSID(obj);

    harnessBDName=Simulink.ID.getModel(harnessObjSid);

    if isOwnedBySUT
        ownerSid=Simulink.ID.getSID(harnessInfo.ownerFullPath);
        sid=strrep(harnessObjSid,[harnessBDName,':1'],'');
        if strcmp(sid,'')

            sid=ownerSid;
        elseif strcmp(harnessInfo.ownerType,'Simulink.BlockDiagram')||...
            hasSIDSpace(harnessInfo.ownerFullPath)

            sid=[ownerSid,sid];
        else

            if contains(sid,':')
                sid=[stripLastSIDNumber(ownerSid),sid];
            else

                sid=[stripLastSIDNumber(ownerSid),':',sid];
            end
        end
    else

        harnessObjSid=strrep(harnessObjSid,harnessBDName,'');


        sid=[bdroot(harnessInfo.ownerFullPath),':',harnessInfo.uuid,harnessObjSid];
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

