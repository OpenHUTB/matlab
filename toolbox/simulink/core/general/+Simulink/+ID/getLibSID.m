function out=getLibSID(h)







    import Simulink.ID.internal.getStateflowSID_helper

    out='';
    if isa(h,'Stateflow.Object')
        [ssid,~,blockH]=getStateflowSID_helper(h);
        if~isempty(blockH)
            out=strcat(get_param(blockH,'SIDFullString'),ssid);
        end
    else
        if isa(h,'Simulink.Object')
            h=h.handle;
        else
            h=get_param(h,'Handle');
        end

        out=Simulink.ID.internal.getLibSID(h);
    end
