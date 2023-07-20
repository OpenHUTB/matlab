classdef(Hidden)EngineService<handle

    methods(Static)

        function setEnabled(enabled)
            connector.ensureServiceOn;
            connector.internal.loadServices('','(classifier=matlabEngine)');

            if connector.isRunning
                connector.internal.configurationSet('connector.engine.enabled',enabled).get();
            else
                warning('Connector:MissingConfiguration','The configuration service was not loaded.');
            end

            connector.internal.EngineService.setApiKey();
        end


        function enabled=getEnabled()
            connector.internal.loadServices('','(classifier=matlabEngine)');
            enabled=false;

            if connector.isRunning
                enabled=connector.internal.configurationGet('connector.engine.enabled').get().value;
            end
        end


        function setApiKey(newKey)
            connector.ensureServiceOn;

            if nargin>0
                connector.internal.configurationSet('connector.engine.apiKey',newKey).get();
            else
                connector.internal.configurationSet('connector.engine.apiKey','').get();
            end
        end


        function apiKey=getApiKey()
            apiKey=connector.internal.configurationGet('connector.engine.apiKey').get();
        end


        function endpoint=getEndpoint()
            connector.ensureServiceOn;
            endpoint=connector.getUrl('/engine');
        end
    end
end
