function update(this,instance,usage,reset,normalizeUnits)

    this.usage=usage;
    if~this.isDirty||reset
        propFQN=[usage.propertySet.getName,'.',usage.getName];
        if normalizeUnits
            if instance.getStereotypeOwner.hasPropVal(propFQN)
                propVal=instance.getStereotypeOwner.getNormalizedValue(propFQN);
                units=propVal{2};
                specValue=propVal{1};
            else
                units=usage.initialValue.units;
                specValue=usage.initialValue.getValue;
            end
        else
            if instance.getStereotypeOwner.hasPropVal(propFQN)
                propVal=instance.getStereotypeOwner.getPropValObject(propFQN);
                units=propVal.units;
                specValue=propVal.getValue;
            else
                units=usage.initialValue.units;
                specValue=usage.initialValue.getValue;
            end
        end
        this.setAsMxArray(specValue,units);
        this.isDirty=false;
    end
end

