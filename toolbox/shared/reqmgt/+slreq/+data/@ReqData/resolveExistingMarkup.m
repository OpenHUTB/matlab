function tf=resolveExistingMarkup(this,linkSetData,connectorData,viewOwenerId,sourceObjId)








    tf=false;
    modelLinkSet=this.getModelObj(linkSetData);
    modelConnector=this.getModelObj(connectorData);
    modelMarkups=modelLinkSet.markups.toArray;
    for i=1:length(modelMarkups)
        if strcmp(viewOwenerId,modelMarkups(i).viewOwnerId)...
            &&strcmp(sourceObjId,modelMarkups(i).sourceObjId)
            tf=true;
            modelConnector.markup=modelMarkups(i);
            break;
        end
    end
end
