function ret=getAPI()

    persistent connectorAPI;
    mlock;
    if isempty(connectorAPI)||~isvalid(connectorAPI)
        connectorAPI=Simulink.sdi.internal.ConnectorAPI;
    end


    ret=connectorAPI;
end
