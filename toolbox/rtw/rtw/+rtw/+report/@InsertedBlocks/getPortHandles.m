function out=getPortHandles(obj,sid)
    if obj.getLinkManager().isTempModelSID(sid)
        sid=obj.getLinkManager().getSubsystemBuildSID(sid);
    end
    out=get_param(sid,'PortHandles');
end
