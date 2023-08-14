function delete(modelName)





















    autosar.api.Utils.autosarlicensed(true);

    if nargin>0
        modelName=convertStringsToChars(modelName);
    end


    systems=find_system('type','block_diagram','name',modelName);
    if isempty(systems)
        DAStudio.error('RTW:autosar:mdlNotLoaded',modelName);
    end


    isCompliant=strcmp(get_param(modelName,'AutosarCompliant'),'on');
    if~isCompliant
        DAStudio.error('RTW:autosar:nonAutosarCompliant');
    end





    if autosar.api.Utils.isMappedToComposition(modelName)
        DAStudio.error('autosarstandard:api:CapabilityNotSupportForAUTOSARArchitectureModel',...
        'autosar.api.delete');
    end



    try

        cleanupObj=autosar.mm.util.MessageReporter.suppressWarningTrace();%#ok<NASGU>


        autosar_ui_close(modelName);
        cp=simulinkcoder.internal.CodePerspective.getInstance;
        if cp.isInPerspective(modelName)
            editors=GLUE2.Util.findAllEditors(modelName);
            for ii=1:numel(editors)
                simulinkcoder.internal.CodePerspective.getInstance.togglePerspective(editors(ii));
            end
        end

        [isMapped,mapping]=autosar.api.Utils.isMapped(modelName);
        if isMapped
            mapping.unmap();
            mmgr=get_param(modelName,'MappingManager');
            mmgr.deleteMapping(mapping);
        end
    catch Me

        autosar.mm.util.MessageReporter.throwException(Me);
    end


    modelObj=get_param(modelName,'Object');
    if modelObj.hasCallback('PreSave','AutosarSaveAsMdl')
        modelObj.removeCallback('PreSave','AutosarSaveAsMdl');
    end


