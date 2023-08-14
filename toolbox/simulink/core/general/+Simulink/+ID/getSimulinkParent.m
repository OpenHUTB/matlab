function[out,varargout]=getSimulinkParent(sid)




    import Simulink.ID.internal.getStateflowSID_helper

    nargoutchk(0,2);
    h=Simulink.ID.getHandle(sid);
    if isa(h,'Stateflow.Object')
        [~,p]=getStateflowSID_helper(h);
        out=Simulink.ID.getSID(p);
    else
        p=get_param(h,'Parent');
        if p==""
            out='';
        else
            out=Simulink.ID.getSID(p);
        end
    end
    if nargout>1
        varargout{1}=h;
    end
