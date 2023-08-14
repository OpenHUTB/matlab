function startConnector




    if signal.analyzer.WebGUI.includeLabeler()
        obj=signal.labeler.ConnectorAPI.getAPI();
        start(obj,false);
    end
    obj=signal.analyzer.ConnectorAPI.getAPI();
    start(obj);

end

