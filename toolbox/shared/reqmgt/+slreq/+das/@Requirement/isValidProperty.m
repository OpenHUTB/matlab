function[bIsValid]=isValidProperty(this,propName)






    bIsValid=false;

    switch propName
    case 'Name'
        bIsValid=true;
    case 'Index'
        bIsValid=true;
    case{'Id','ID'}
        bIsValid=true;
    case 'SID'
        bIsValid=true;
    case 'CustomID'
        bIsValid=true;
    case 'Summary'
        bIsValid=true;
    case 'Description'
        bIsValid=true;
    case 'Rationale'
        bIsValid=true;
    case 'Keywords'
        bIsValid=true;
    case 'isHierarchicalJustification'
        bIsValid=true;
    case 'CreatedOn'
        bIsValid=true;
    case 'CreatedBy'
        bIsValid=true;
    case 'ModifiedOn'
        bIsValid=true;
    case 'SynchronizedOn'
        bIsValid=true;
    case 'ModifiedBy'
        bIsValid=true;
    case 'Revision'
        bIsValid=true;
    case 'Implemented'
        bIsValid=true;
    case 'Verified'
        bIsValid=true;
    case 'Type'
        bIsValid=true;

    otherwise



        propName=slreq.utils.customAttributeNamesHash('lookup',propName);

        bIsValid=this.dataModelObj.hasRegisteredAttribute(propName);

        if~bIsValid

            bIsValid=slreq.internal.ProfileReqType.isProfileStereotype(this.RequirementSet.dataModelObj,propName);
        end
    end
