function out=remapAttribute(this,dataReqSet,importNode,oldMapsTo,newMapsTo)

    mfReqSet=dataReqSet.getModelObj();
    mfRootItem=importNode.getModelObj();

    remapper=slreq.datamodel.AttributeMapper(this.model);
    remapper.remapAttribute(mfReqSet,mfRootItem,oldMapsTo,newMapsTo);

    out=true;
end
