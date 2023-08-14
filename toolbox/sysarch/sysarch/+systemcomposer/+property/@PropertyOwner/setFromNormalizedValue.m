function setFromNormalizedValue(this,propertyName,value)






    if this.isPropValDefault(propertyName)

        localValue=value;
    else
        parts=split(propertyName,'.');
        propSetName=[parts{1},'.',parts{2}];
        propName=parts{3};

        propSet=this.getPropertySet(propSetName);
        propUsage=propSet.properties.getByKey(propName);

        propVal=this.getPropValObject(propertyName);

        localUnits=propVal.units;
        definitionUnits=propUsage.propertyDef.getUnit();

        if isempty(localUnits)||isempty(definitionUnits)
            localValue=value;
        else
            Info=propVal.type.unitChecker.getConversionInfo(definitionUnits,localUnits);
            if~Info.isInverted
                localValue=value*Info.scaling+Info.offset;
            else
                localValue=Info.scaling/value;
            end
        end
    end
    this.setPropVal(propertyName,mat2str(localValue));
end

