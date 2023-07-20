function dtype=getPropDataType(this,propName)






    dtype='ustring';

    MAP_TO_SAME_TYPE={'double','int32','uint32','uint64'};

    if isempty(this.dataModelObj)
        return;
    end


    switch propName
    case 'Name'
        dtype='ustring';
    case 'Index'
        dtype='ustring';
    case{'Id','ID'}
        dtype='ustring';
    case 'SID'
        dtype='ustring';
    case 'CustomID'
        dtype='ustring';
    case 'Summary'
        dtype='ustring';
    case 'Description'
        dtype='ustring';
    case 'Rationale'
        dtype='ustring';
    case 'Keywords'
        dtype='ustring';
    case 'isHierarchicalJustification'

        dtype='bool';
    case 'CreatedOn'
        dtype='ustring';
    case 'CreatedBy'
        dtype='ustring';
    case 'ModifiedOn'
        dtype='ustring';
    case 'SynchronizedOn'
        dtype='ustring';
    case 'ModifiedBy'
        dtype='ustring';
    case 'Revision'
        dtype='ustring';
    case 'Implemented'
        dtype='ustring';
    case 'Verified'
        dtype='ustring';
    case 'Type'
        dtype='ustring';
    otherwise

        attrRegistries=slreq.data.ReqData.getInstance.getCustomAttributeRegistries(this.dataModelObj.getReqSet);


        propName=slreq.utils.customAttributeNamesHash('lookup',propName);

        attrReg=attrRegistries.getByKey(propName);
        if~isempty(attrReg)
            switch attrReg.typeName
            case slreq.datamodel.AttributeRegType.Combobox
                dtype='string';
            case slreq.datamodel.AttributeRegType.Checkbox
                dtype='bool';

            case{slreq.datamodel.AttributeRegType.Edit,slreq.datamodel.AttributeRegType.DateTime}
                dtype='ustring';
            end
        elseif slreq.internal.ProfileReqType.isProfileStereotype(this.RequirementSet.dataModelObj,propName)
            type=slreq.internal.ProfileReqType.getStereotypeAttrType(propName);
            switch type
            case MAP_TO_SAME_TYPE
                dtype=type;
            case 'boolean'
                dtype='bool';
            otherwise
                dtype='ustring';
            end
        end
    end
end
