function setPropValue(this,propName,propValue)





    try
        if isequal(this.getPropValue(propName),propValue)

            return;
        end
    catch ex %#ok<NASGU>
    end

    if this.RequirementSet.isBackedBySlx()
        slxFile=this.RequirementSet.dataModelObj.parent;
        parts=strsplit(slxFile,'.');
        mdlHandle=get_param(parts{1},'handle');
        set_param(mdlHandle,'Dirty','on');
    end

    switch propName
    case 'CustomID'
        this.CustomID=propValue;
    case 'Description'
        this.Description=propValue;
    case 'Rationale'
        this.Rationale=propValue;
    case 'Summary'
        this.Summary=propValue;
    case 'Keywords'
        this.Keywords=propValue;
    case 'isHierarchicalJustification'
        this.isHierarchicalJustification=logical(str2double(propValue));
    case 'Type'
        this.Type=propValue;
    otherwise


        propName=slreq.utils.customAttributeNamesHash('lookup',propName);

        isProfileStereotype=slreq.internal.ProfileReqType.isProfileStereotype(this.RequirementSet.dataModelObj,propName);
        if isProfileStereotype
            this.dataModelObj.setStereotypeAttr(propName,propValue);
        else
            this.dataModelObj.setAttributeByChar(propName,propValue);
        end
    end

    this.updateMimeData(this);






    this.view.getCurrentView.updateToolbar();

end
