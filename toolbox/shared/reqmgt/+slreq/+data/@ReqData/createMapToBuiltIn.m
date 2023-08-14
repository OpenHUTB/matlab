

function externalItem=createMapToBuiltIn(this,externalName,externalType,slreqName,slreqType)






    externalItem=slreq.datamodel.MappedAttribute(this.model);
    externalItem.name=externalName;
    externalItem.type=externalType;
    externalItem.mapsTo=slreq.datamodel.MappedAttribute(this.model);
    externalItem.mapsTo.kind=slreq.datamodel.AttributeKindEnum.BuiltinAttribute;
    externalItem.mapsTo.name=slreqName;
    externalItem.mapsTo.type=slreqType;
end
