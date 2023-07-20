function propList=getPropertyGroupsForDictionary(obj)





    if strcmp(obj.getConfigurationType,'ServiceInterface')
        propList='';
    else
        propList=struct('StorageClasses',obj.getSection('StorageClasses'),...
        'MemorySections',obj.getSection('MemorySections'),...
        'FunctionCustomizationTemplates',obj.getSection('FunctionCustomizationTemplates'));
    end

end
