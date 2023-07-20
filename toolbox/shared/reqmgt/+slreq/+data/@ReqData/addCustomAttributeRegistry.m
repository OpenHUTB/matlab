function addCustomAttributeRegistry(this,dataReqSet,name,typeName,description,defaultValue,isReadOnly)







    mfReqSet=this.getModelObj(dataReqSet);
    [tf,invalidChars]=slreq.internal.isValidCustomAttributeName(name);
    if~tf
        invalidListStr=strrep(strjoin(invalidChars),' ','');
        error(message('Slvnv:slreq:AttributeNameIsInvalid',invalidListStr));
    end

    existingRegistries=mfReqSet.attributeRegistry;
    existingAttrReg=existingRegistries.getByKey(name);
    if~isempty(existingAttrReg)
        error(message('Slvnv:slreq:AttributeNameExists',name))
    end


    if slreq.custom.AttributeHandler.isReservedName(name)

        error(message('Slvnv:slreq:AttributeNameIsReserved',name))
    end

    switch typeName
    case slreq.datamodel.AttributeRegType.Edit
        customAttr=slreq.datamodel.StrAttrReg(this.model);
        customAttr.default='';
    case slreq.datamodel.AttributeRegType.Checkbox
        customAttr=slreq.datamodel.BoolAttrReg(this.model);
        customAttr.default=defaultValue;




    case slreq.datamodel.AttributeRegType.Combobox
        if numel(defaultValue)~=numel(unique(defaultValue))
            error(message('Slvnv:slreq:AttributeComboboxNameShouldBeUnique'));
        elseif numel(defaultValue)==0
            error(message('Slvnv:slreq:AttributeComboboxNameCannotBeEmpty'))
        elseif~strcmp(defaultValue{1},'Unset')
            error(message('Slvnv:slreq:AttributeComboboxName1stElementMustBeUnset'))
        end
        customAttr=slreq.datamodel.EnumAttrReg(this.model);
        for n=1:length(defaultValue)
            customAttr.entries.add(defaultValue{n});
        end







    case slreq.datamodel.AttributeRegType.DateTime
        customAttr=slreq.datamodel.DateTimeAttrReg(this.model);
    otherwise
        error('Invalid type is specified');
    end
    customAttr.name=name;
    customAttr.typeName=typeName;
    customAttr.description=description;
    customAttr.isReadOnly=isReadOnly;
    existingRegistries.add(customAttr);

    if~mfReqSet.dirty

        dataReqSet.setDirty(true);
    end
end
