

function externalItem=createMapToCustomAttribute(this,externalName,externalType,slreqName,slreqType,isAutoMapped)






    externalItem=slreq.datamodel.MappedAttribute(this.model);
    externalItem.name=externalName;
    externalItem.type=externalType;
    externalItem.isAutoMapped=isAutoMapped;
    externalItem.mapsTo=slreq.datamodel.MappedAttribute(this.model);
    externalItem.mapsTo.kind=slreq.datamodel.AttributeKindEnum.CustomAttribute;
    externalItem.mapsTo.name=slreqName;
    externalItem.mapsTo.type=slreqType;

end