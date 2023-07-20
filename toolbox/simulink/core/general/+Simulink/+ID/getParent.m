function[out,varargout]=getParent(sid)














    import Simulink.ID.internal.getStateflowObjectParentChart
    import Simulink.ID.internal.getStateflowSID_helper

    nargoutchk(0,2);
    [h,aux]=Simulink.ID.getHandle(sid);
    if isa(h,'Stateflow.Object')||isa(h,'Stateflow.DDObject')
        if aux==""
            h=getStateflowObjectParentChart(h);
        end
        [ssid,p]=getStateflowSID_helper(h);
        simulink_parent_sid=Simulink.ID.getSID(p);
        out=strcat(simulink_parent_sid,ssid);
    else
        p=get_param(h,'Parent');
        if p==""
            simulink_parent_sid='';
            out=simulink_parent_sid;
        else
            simulink_parent_sid=Simulink.ID.getSID(p);
            sf_obj=Stateflow.SLUtils.getStateflowUddH(get_param(h,'object'));
            if~isempty(sf_obj)&&isa(sf_obj,'Stateflow.SLFunction')
                h=getStateflowObjectParentChart(sf_obj);
                out=Simulink.ID.getSID(h);
            else
                out=simulink_parent_sid;
            end
        end
    end
    if nargout>1
        varargout{1}=h;
    end


