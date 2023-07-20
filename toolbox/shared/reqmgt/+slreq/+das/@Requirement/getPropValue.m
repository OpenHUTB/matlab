function propValue=getPropValue(this,propName)






    propValue='';

    if isempty(this.dataModelObj)
        return;
    end

    switch propName
    case 'Name'
        propValue='';
    case 'Index'
        propValue=this.Index;
    case{'Id','ID'}
        propValue=this.Id;
    case 'SID'
        propValue=num2str(this.SID);
    case 'CustomID'
        propValue=this.CustomID;
    case 'Summary'
        propValue=this.Summary;
    case 'Description'
        propValue=this.Description;
    case 'Rationale'
        propValue=this.Rationale;
    case 'Keywords'
        propValue=this.Keywords;
    case 'isHierarchicalJustification'
        propValue=num2str(this.isHierarchicalJustification);
    case 'CreatedOn'

        propValue=slreq.utils.getDateStr(this.dataModelObj.createdOn);
    case 'CreatedBy'
        propValue=this.dataModelObj.createdBy;
    case 'ModifiedOn'

        propValue=slreq.utils.getDateStr(this.dataModelObj.modifiedOn);
    case 'SynchronizedOn'

        propValue=slreq.utils.getDateStr(this.dataModelObj.synchronizedOn);
    case 'ModifiedBy'
        propValue=this.dataModelObj.modifiedBy;
    case 'Revision'
        propValue=num2str(this.dataModelObj.revision);
    case 'Implemented'
        propValue='';
    case 'Verified'
        propValue='';
    case 'Type'
        propValue=this.Type;
    otherwise



        propName=slreq.utils.customAttributeNamesHash('lookup',propName);
        isProfileStereotype=slreq.internal.ProfileReqType.isProfileStereotype(this.RequirementSet.dataModelObj,propName);
        if isProfileStereotype
            attrValue=this.dataModelObj.getStereotypeAttr(propName,true);
        else
            attrValue=this.dataModelObj.getAttribute(propName,false);
        end
        if ischar(attrValue)
            propValue=attrValue;
        elseif isdatetime(attrValue)

            propValue=slreq.utils.getDateStr(attrValue);

        elseif isenum(attrValue)
            propValue=string(attrValue);
        elseif isnumeric(attrValue)||islogical(attrValue)
            propValue=num2str(attrValue);
        end
    end
end
