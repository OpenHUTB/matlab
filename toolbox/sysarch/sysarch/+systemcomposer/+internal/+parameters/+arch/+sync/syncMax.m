function syncMax(paramDef,slVar,~)

    if isa(slVar,'Simulink.Parameter')
        paramDef.getImpl.setMax(slVar.Max);
    end
end
