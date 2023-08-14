function[baseEnumName]=getBaseEnumName(modelName,enumName)






    enumName=autosar.utils.StripPrefix(enumName);
    mprops=meta.class.fromName(enumName);
    if~isempty(mprops)
        if coder.internal.isSupportedEnumClass(mprops)
            baseEnumName=enumName;
        end
    else
        [objExists,slObj]=autosar.utils.Workspace.objectExistsInModelScope(modelName,enumName);
        assert(objExists,'Variable name does not exist.');
        assert(isa(slObj,'Simulink.AliasType'),...
        'Variable is neither enum nor alias to enum.');
        baseEnumName=autosar.mm.util.getBaseEnumName(modelName,slObj.BaseType);

    end
end
