function createAndMigrate(modelName,activeCS,isShared,isCSInBaseWS,migrateDictionaryOnly,varargin)





    mdlH=get_param(modelName,'Handle');
    guiEntry=true;

    p=inputParser;
    addParameter(p,'noSharedDictionary',false,@islogical);
    parse(p,varargin{:});


    sharedMappingMigrated=false;
    if isShared&&~p.Results.noSharedDictionary
        ddName='';
        if isa(activeCS,'Simulink.ConfigSetRef')

            ddName=activeCS.DDName;
        end
        if~isempty(ddName)
            Simulink.CodeMapping.migrateToSharedDictionary(ddName,activeCS,guiEntry);
            sharedMappingMigrated=true;
        end
    end

    if~coder.internal.CoderDataStaticAPI.migratedToCoderDictionary(mdlH)
        Simulink.CodeMapping.migrateDictionary(mdlH,activeCS,guiEntry,'noSharedDictionary',p.Results.noSharedDictionary);
    end

    if migrateDictionaryOnly
        return;
    end


    if isShared&&~p.Results.noSharedDictionary
        if~isCSInBaseWS






            Simulink.CodeMapping.migrateFromShared(modelName,~sharedMappingMigrated);
        else
            Simulink.CodeMapping.migrate(modelName);
        end
    else
        Simulink.CodeMapping.migrate(modelName);
    end
end
