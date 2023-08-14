function out=create(modelName,creationMode,mappingType)




    out=false;





    if nargin<3
        [~,mappingType]=Simulink.CodeMapping.getCurrentMapping(modelName);
    else
        if~any(strcmp(mappingType,{'AutosarTarget','CppModelMapping','CoderDictionary','SimulinkCoderCTarget'}))
            assert(false,'The value of target must be AutosarTarget, CppModelMapping, or CoderDictionary.');
        end
    end
    if nargin<2

        creationMode='init';
    end

    if strcmp(mappingType,'AutosarTarget')

        if~autosarinstalled()
            assert(false,'AUTOSAR Blockset is not installed.');
            return;
        end
        autosar.api.create(modelName,creationMode);
        out=true;
    elseif any(strcmp(mappingType,{'CppModelMapping','CoderDictionary','SimulinkCoderCTarget'}))

        systems=find_system('type','block_diagram','name',modelName);
        if isempty(systems)
            DAStudio.error('RTW:autosar:mdlNotLoaded',modelName);
        end

        switch creationMode
        case{'init','default','testing'}
            coder.mapping.internal.createDefaultMapping(modelName,mappingType);
            out=true;
        otherwise
            DAStudio.error('RTW:autosar:invalidCreationMode',creationMode);
        end
    end
end
