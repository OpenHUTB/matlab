






function addCustomAttributes(dataReqLinkSet,mfMapping)

    reqData=slreq.data.ReqData.getInstance();

    if isa(dataReqLinkSet,'slreq.data.RequirementSet')
        mfMappedType=mfMapping.types{'RequirementItem'};
    else
        mfMappedType=mfMapping.types{'Link'};
    end
    if isempty(mfMappedType)

        return;
    end

    attrRegistry=reqData.getCustomAttributeRegistries(dataReqLinkSet);

    mfMappedAttribs=mfMappedType.attributes;

    attrRegistries=attrRegistry.toArray();
    for n=1:length(attrRegistries)
        attrReg=attrRegistries(n);

        slreqName=attrReg.name;

        if attrReg.isReadOnly


            continue;
        end

        mfMappedAttrib=mfMappedAttribs{slreqName};
        if~isempty(mfMappedAttrib)

            continue;
        end











        slreqType=slreq.datamodel.AttributeTypeEnum.Any;
        switch attrReg.typeName
        case 'Edit'

            slreqType=slreq.datamodel.AttributeTypeEnum.String;

        case 'DateTime'
            slreqType=slreq.datamodel.AttributeTypeEnum.Date;

        case 'Combobox'
            slreqType=slreq.datamodel.AttributeTypeEnum.Enumeration;

        case 'Checkbox'
            slreqType=slreq.datamodel.AttributeTypeEnum.Boolean;

        otherwise


            continue;
        end


        newAttrib=reqData.createMapToCustomAttribute(slreqName,slreqType,slreqName,slreqType,true);
        mfMappedType.attributes.add(newAttrib);
    end
end
