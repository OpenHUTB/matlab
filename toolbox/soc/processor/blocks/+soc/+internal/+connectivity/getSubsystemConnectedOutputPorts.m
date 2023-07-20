function ports=getSubsystemConnectedOutputPorts(sysName)










    import soc.internal.connectivity.*

    ports=getSubsystemPortConnectivity(sysName);
    idx=arrayfun(@(x)(~isempty(x.DstPort)&&...
    ~isnan(str2double(x.Type))),ports);
    ports=ports(idx);
end
