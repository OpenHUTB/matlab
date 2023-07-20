



function doMigrationFromGUI(modelName,migrateDictionaryOnly,varargin)
    wState=[warning;warning('query','RTW:configSet:migratedToCoderDictionary')];
    warning('off','RTW:configSet:migratedToCoderDictionary');
    wCleanup=onCleanup(@()warning(wState));

    p=inputParser;
    addParameter(p,'noSharedDictionary',false,@islogical);
    parse(p,varargin{:});

    activeCS=getActiveConfigSet(modelName);
    isShared=isa(activeCS,'Simulink.ConfigSetRef');
    isCSinBaseWS=isa(activeCS,'Simulink.ConfigSetRef')&&strcmp(activeCS.getSourceLocation,'Base Workspace');
    if isShared


        editor=GLUE2.Util.findAllEditors(modelName);
        if~isempty(editor)
            editor.deliverInfoNotification('MigratingConfigParamInfo',...
            DAStudio.message('coderdictionary:mapping:MigrateFromCSRef',activeCS.getRefConfigSet.Name));
        end
    end
    cleaner=Simulink.PreserveDirtyFlag(modelName,'blockDiagram');
    Simulink.CodeMapping.createAndMigrate(modelName,activeCS,isShared,isCSinBaseWS,migrateDictionaryOnly,...
    'noSharedDictionary',p.Results.noSharedDictionary);
    delete(cleaner);
end
