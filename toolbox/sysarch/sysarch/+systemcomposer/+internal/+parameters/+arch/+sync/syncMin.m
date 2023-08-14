function syncMin(paramDef,slVar,~)

    if isa(slVar,'Simulink.Parameter')
        paramDef.getImpl.setMin(slVar.Min);
    end
end