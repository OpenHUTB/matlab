function removeConnectors(this,connectors)






    for n=1:length(connectors)
        connector=connectors(n);
        modelConnectorObj=this.getModelObj(connector);
        uuid=modelConnectorObj.UUID;
        modelMarkupObj=modelConnectorObj.markup;
        if~isempty(modelMarkupObj)
            if modelMarkupObj.connectors.Size==1

                modelMarkupObj.destroy;
            elseif modelMarkupObj.connectors.Size>1


                modelMarkupObj.connectors.remove(modelConnectorObj);
            end
            modelConnectorObj.destroy;
        end
        connector.delete;
    end
end
