function normalizedValueAndUnit=getNormalizedValue(this,propertyName)







    propVal=this.getPropValObject(propertyName);

    parts=split(propertyName,'.');
    propSetName=[parts{1},'.',parts{2}];
    propName=parts{3};

    propSet=this.getPropertySet(propSetName);
    propUsage=propSet.properties.getByKey(propName);

    definitionUnits=propUsage.propertyDef.getUnit();
    heldValue=propVal.getValue();

    if this.isPropValDefault(propertyName)

        normalizedValue=heldValue;
    else
        localUnits=propVal.units;

        if isempty(localUnits)||isempty(definitionUnits)
            normalizedValue=heldValue;
        else
            Info=propVal.type.unitChecker.getConversionInfo(localUnits,definitionUnits);
            if~Info.isInverted
                normalizedValue=heldValue*Info.scaling+Info.offset;
            else
                normalizedValue=Info.scaling/heldValue;
            end
        end
    end

    normalizedValueAndUnit={normalizedValue,definitionUnits};

end
