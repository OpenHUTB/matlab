


classdef ConnectorAPI<handle


    methods(Static)


        function ret=getAPI()

            persistent connectorAPI;
            mlock;
            if isempty(connectorAPI)
                connectorAPI=Simulink.HMI.ConnectorAPI;
            end


            ret=connectorAPI;
        end

    end


    methods


        function url=getURL(this,pagePath)
            if isempty(this.Port)
                hostInfo=connector.ensureServiceOn;
                this.Port=hostInfo.securePort;
            end
            url=connector.getUrl(pagePath);
        end

    end


    properties(Access=private)
        Port=[];
    end
end


