function syncUnit(paramDef,slVar,~)

    if isa(slVar,'Simulink.Parameter')
        if systemcomposer.internal.arch.internal.isUnitSupportedOnDataType(paramDef.Type)
            paramDef.getImpl.setUnit(slVar.Unit);
        end
    end
end
