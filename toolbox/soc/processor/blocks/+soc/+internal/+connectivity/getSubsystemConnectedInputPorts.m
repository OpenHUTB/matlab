function ports=getSubsystemConnectedInputPorts(sysName)










    import soc.internal.connectivity.*

    ports=getSubsystemPortConnectivity(sysName);
    idx=arrayfun(@(x)(~isempty(x.SrcPort)&&...
    ~isnan(str2double(x.Type))),ports);
    ports=ports(idx);
end
