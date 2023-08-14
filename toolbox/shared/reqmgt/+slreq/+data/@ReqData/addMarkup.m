function markupData=addMarkup(this,connector)






    modelConnector=this.getModelObj(connector);
    modelMarkup=slreq.datamodel.Markup(this.model);

    modelMarkup.connectors.add(modelConnector);



    if~isempty(modelConnector.link)
        modelLink=modelConnector.link;
    else
        modelLink=modelConnector.diagramLink;
    end
    modelLinkSet=modelLink.source.artifact;
    modelLinkSet.markups.add(modelMarkup);

    markupData=this.wrap(modelMarkup);
end
