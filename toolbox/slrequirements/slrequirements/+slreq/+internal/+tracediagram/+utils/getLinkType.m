function[linkType,linkSubType]=getLinkType(dataLink)




    isStereotype=slreq.internal.ProfileLinkType.isProfileStereotype(...
    dataLink.getLinkSet(),dataLink.type);

    if isStereotype

        baseBehavior=slreq.internal.ProfileTypeBase.getMetaAttrValue(dataLink,'BaseBehavior');
        if isempty(baseBehavior)

            linkType=dataLink.type;
            linkSubType='#Stereotype#';
        else
            linkType=baseBehavior;
            linkSubType=dataLink.type;
        end
        return;
    end


    mfLinkType=slreq.data.ReqData.getInstance.getLinkType(dataLink.type);
    if mfLinkType.isBuiltin
        linkType=dataLink.type;
        linkSubType='#Other#';
    else
        linkSubType=dataLink.type;
        linkType=mfLinkType.superType.typeName;
    end
end