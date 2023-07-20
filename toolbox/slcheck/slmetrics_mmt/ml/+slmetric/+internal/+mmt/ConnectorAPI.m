classdef ConnectorAPI<handle







    properties(Access=private)
    end




    methods



        function url=getURL(this,relPath)

            connector.ensureServiceOn;
            url=connector.getUrl(relPath);
            uri=matlab.net.URI(url,'websocket','on');
            url=char(uri.EncodedURI);
        end
    end




    methods(Static)



        function ret=getAPI()


            persistent connectorAPI;

            if isempty(connectorAPI)||~isvalid(connectorAPI)
                connectorAPI=slmetric.internal.mmt.ConnectorAPI;
            end


            ret=connectorAPI;
        end
    end
end

