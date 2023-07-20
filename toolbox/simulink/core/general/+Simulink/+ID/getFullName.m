function[out,ssId,auxInfo]=getFullName(sid)




    import Simulink.ID.internal.getStateflowSID_helper

    ssId='';
    if ishandle(sid)
        h=sid;
        auxInfo='';
    else
        [h,auxInfo]=Simulink.ID.getHandle(sid);
        if auxInfo~=""
            auxInfo=strcat(':',auxInfo);
        end
    end
    if isa(h,'Stateflow.Object')
        if nargout<=1
            out=h.getFullName;
        else
            [ssId,blockH]=getStateflowSID_helper(h);
            out=getfullname(blockH);
        end
    elseif isa(h,'Simulink.Object')
        out=getfullname(h.handle);
    else
        out=getfullname(h);
    end
