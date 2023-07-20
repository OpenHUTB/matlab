classdef ConnectorAPI<handle








    properties(Access=private)
    end




    methods



        function url=getURL(this,relPath)

            connector.ensureServiceOn;

            url=connector.getUrl(relPath);
        end
    end




    methods(Static)



        function ret=getAPI()


            persistent connectorAPI;

            if isempty(connectorAPI)||~isvalid(connectorAPI)
                connectorAPI=dashboard.internal.ConnectorAPI;
            end


            ret=connectorAPI;
        end
    end
end

