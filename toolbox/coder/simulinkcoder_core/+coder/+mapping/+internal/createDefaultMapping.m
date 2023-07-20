function mapping=createDefaultMapping(modelName,varargin)







    modelName=get_param(modelName,'Name');
    mmgr=get_param(modelName,'MappingManager');
    Simulink.CoderDictionary.ModelMapping;
    Simulink.CppModelMapping.ModelMapping;

    if~isempty(varargin)
        mappingType=varargin{:};
    else
        mappingType='';
    end

    if isempty(mappingType)
        [mapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(modelName);
    else
        mapping=Simulink.CodeMapping.get(modelName,mappingType);
    end

    msgArg='C/C++';

    if~(strcmp(mappingType,'CppModelMapping')||strcmp(mappingType,'CoderDictionary')||strcmp(mappingType,'SimulinkCoderCTarget'))
        DAStudio.error('coderdictionary:api:supportedForErtCppTarget',msgArg);
    end

    if~isempty(mapping)
        mapping.unmap();
        mmgr.deleteMapping(mapping);
    end
    if strcmp(mappingType,'CoderDictionary')
        mappingName=[modelName,'_c'];
    elseif strcmp(mappingType,'CppModelMapping')
        mappingName=[modelName,'_cpp'];
    else
        mappingName=[modelName,'_SLC'];
    end


    existingMappingNames=mmgr.getMappingNames();
    mappingName=matlab.lang.makeUniqueStrings(...
    matlab.lang.makeValidName(mappingName),existingMappingNames,...
    namelengthmax);

    mapping=mmgr.createMapping(mappingName,mappingType);
    mmgr.activateMapping(mappingName);
    mapping.sync();
end


