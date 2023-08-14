function pd=getOrAddParamDef(arch,name)




    pd=arch.getParameterDefinition(name);
    if isempty(pd)
        arch.getImpl.addParameter(name);
        pd=arch.getParameterDefinition(name);
    end

end

