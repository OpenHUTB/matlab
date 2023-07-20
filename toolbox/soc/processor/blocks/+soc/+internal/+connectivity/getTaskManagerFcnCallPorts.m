function ports=getTaskManagerFcnCallPorts(taskMgr)




    import soc.internal.connectivity.*

    ports=getSubsystemConnectedOutputPorts(taskMgr);
end
