function propValues=getPropAllowedValues(this,propName)





    propValues={};
    if isempty(this.object)
        return;
    end

    if length(propName)>1&&strcmp(propName(1:2),'In')
        propValues=getentries(this,'Tfldesigner_ConceptualDatatype');
    elseif length(propName)>6&&strcmp(propName(1:6),'ImplIn')
        propValues=getentries(this,'Tfldesigner_ImplDatatype');
    else
        switch propName
        case 'SaturationMode'
            propValues=getentries(this,'Tfldesigner_SaturationMode');
        case 'RoundingMode'
            propValues=getentries(this,'Tfldesigner_RoundingMode');
        case 'ImplReturnType'
            propValues=getentries(this,'Tfldesigner_ImplDatatype');
        case{'Out1Type','Out2Type'}
            propValues=getentries(this,'Tfldesigner_ConceptualDatatype');
        case 'SupportNonFinite'
            propValues=getentries(this,'Tfldesigner_SupportNonFinite');
        case 'ArrayLayout'
            propValues=getentries(this,'Tfldesigner_ArrayLayout');
        end
    end
