classdef ConnectorAPI<handle

    properties(Access=private)
    end

    methods



        function url=getURL(~,relPath)

            connector.ensureServiceOn;

            url=connector.getUrl(relPath);
        end
    end


    methods(Static)



        function ret=getAPI()


            persistent connectorAPI;

            if isempty(connectorAPI)||~isvalid(connectorAPI)
                connectorAPI=soc.ui.internal.ConnectorAPI;
            end


            ret=connectorAPI;
        end
    end
end