function out=getSID(h)




    import Simulink.ID.internal.getStateflowSID_helper

    narginchk(1,1);
    if isa(h,'Stateflow.Machine')
        out=h.Name;
    elseif isa(h,'Stateflow.Object')||isa(h,'Stateflow.DDObject')
        [ssid,blockH]=getStateflowSID_helper(h);
        out=strcat(get_param(blockH,'SIDFullString'),ssid);
    elseif isa(h,'Simulink.Object')
        out=get_param(h.handle,'SIDFullString');
    else
        out=get_param(h,'SIDFullString');
    end
