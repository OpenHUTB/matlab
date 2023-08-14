


function doPostModelLoadMigration(modelName)
    activeCS=getActiveConfigSet(modelName);
    isShared=isa(activeCS,'Simulink.ConfigSetRef');
    if isShared


        editor=GLUE2.Util.findAllEditors(modelName);
        if~isempty(editor)
            editor.deliverInfoNotification('MigratingConfigParamInfo',...
            DAStudio.message('coderdictionary:mapping:MigrateCPPFromCSRef',activeCS.getRefConfigSet.Name));
        end
    end
    cleaner=Simulink.PreserveDirtyFlag(modelName,'blockDiagram');


    Simulink.CodeMapping.migrateCPPCS(modelName,activeCS);
    delete(cleaner);
end
