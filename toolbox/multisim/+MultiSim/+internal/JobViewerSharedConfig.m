classdef JobViewerSharedConfig<handle
    properties
        DebugMode=false
        WindowCreator=MultiSim.internal.WebWindowCreator
        ExitCommand=@exit
        ConnectorConstructor=@MultiSim.internal.JobViewerConnector;
    end
end