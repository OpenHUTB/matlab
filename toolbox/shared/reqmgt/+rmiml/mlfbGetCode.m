

function content=mlfbGetCode(sid)
    if rmisl.isHarnessIdString(sid)

        sid=rmisl.harnessIdToEditorName(sid);
    end
    eml=Simulink.ID.getHandle(sid);
    if isa(eml,'double')

        sfId=sfprivate('block2chart',eml);
        sfRt=Stateflow.Root;
        sfObj=sfRt.idToHandle(sfId);
    else

        sfObj=eml;
    end
    content=sfObj.Script;
end

