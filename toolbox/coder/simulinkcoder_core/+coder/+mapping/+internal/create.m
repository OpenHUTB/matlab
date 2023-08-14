function create(modelH,configSet,varargin)






    bdType=get_param(modelH,'BlockDiagramType');
    if isequal(bdType,'subsystem')

        DAStudio.error('RTW:autosar:SubsystemReferenceModel',get_param(modelH,'Name'));
    elseif isequal(bdType,'library')

        DAStudio.error('RTW:autosar:LibraryModel',get_param(modelH,'Name'));
    end

    p=inputParser;

    addParameter(p,'noSharedDictionary',false,@islogical);


    addParameter(p,'MappingType','',@ischar);
    parse(p,varargin{:});

    if~isempty(p.Results.MappingType)
        mappingType=p.Results.MappingType;
        mapping=Simulink.CodeMapping.get(modelH,mappingType);
    else
        [mapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(modelH);
    end


    if~(strcmp(mappingType,'CoderDictionary')||...
        strcmp(mappingType,'SimulinkCoderCTarget'))

        if~strcmp(mappingType,'CppModelMapping')
            DAStudio.error('coderdictionary:api:supportedForErtCppTarget',get_param(modelH,'Name'));
        end
    end

    modelName=get_param(modelH,'Name');
    if strcmp(mappingType,'CoderDictionary')&&~isempty(configSet)

        Simulink.CodeMapping.doMigrationFromGUI(modelName,false,'noSharedDictionary',p.Results.noSharedDictionary);
    elseif strcmp(mappingType,'CppModelMapping')&&~isempty(configSet)
        Simulink.CodeMapping.doPostModelLoadMigration(modelName);
    elseif isempty(mapping)

        if strcmp(mappingType,'CoderDictionary')

            Simulink.CodeMapping.addCoderGroups(modelName,'init');
        end
        Simulink.CodeMapping.create(modelName,'default',mappingType);
    elseif strcmp(mappingType,'CoderDictionary')

        mapping.updatePlatform(false);
    end
end


