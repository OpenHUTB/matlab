function this=createFromUsage(analysisUsage,usage,instance)

    model=mf.zero.getModel(instance);
    this=systemcomposer.internal.analysis.PropertySetValue(model);
    this.setName(usage.getName);

    properties=analysisUsage.properties.toArray;
    for pui=1:length(properties)
        pu=properties(pui);
        mu=usage.getPropertyUsage(pu.getName);
        if isempty(mu)
            continue;
        end
        pv=systemcomposer.internal.analysis.PropertyValue(model);
        pv.definition=pu;
        pv.usage=mu;
        try
            propFQN=[usage.getName,'.',pu.getName];
            if instance.instanceModel.normalizeUnits
                if instance.getStereotypeOwner.hasPropVal(propFQN)
                    res=instance.getStereotypeOwner.getNormalizedValue(propFQN);
                    specValue=res{1};
                    units=res{2};
                else



                    specPropVal=mu.initialValue;
                    units=specPropVal.units;
                    specValue=specPropVal.getValue;
                end
            else

                if instance.getStereotypeOwner.hasPropVal(propFQN)
                    specPropVal=instance.getStereotypeOwner.getPropValObject(propFQN);
                else



                    specPropVal=mu.initialValue;
                end
                units=specPropVal.units;
                specValue=specPropVal.getValue;
            end
        catch ex


            msgObj=message('SystemArchitecture:Analysis:InvalidInitialValue',pu.getName);
            warning('Analysis:InvalidInitialValue',msgObj.getString);

            specValue=mu.initialValue.type.makeDefaultValue([]);
        end
        pv.setAsMxArray(specValue,units);
        pv.setName(pu.getName);
        pv.isDirty=false;

        switch pu.semantics


























































        case systemcomposer.internal.analysis.ComputationSemantics.DEPENDENT

            pv.readOnly=true;
        case systemcomposer.internal.analysis.ComputationSemantics.INDEPENDENT

            pv.readOnly=false;
        end
        this.values.add(pv);
    end
end

