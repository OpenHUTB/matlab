function connectorData=addConnector(this,linkData,isDiagram)






    modelLink=this.getModelObj(linkData);

    modelConnector=slreq.datamodel.Connector(this.model);


    if isDiagram
        modelLink.diagramConnector=modelConnector;
    else
        modelLink.connector=modelConnector;
    end

    linkData.getLinkSet.setDirty(true);
    connectorData=this.wrap(modelConnector);
end
