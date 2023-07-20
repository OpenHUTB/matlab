classdef BootstrapWorkflow
    properties(Access=private)
        coSimPort;
        apiPort;
    end

    methods
        function obj=BootstrapWorkflow(apiPort,coSimPort,requsted_client_id)
            Simulink.ScenarioSimulation('localhost',apiPort,coSimPort,'requestedClientID',requsted_client_id);
        end

    end
end
