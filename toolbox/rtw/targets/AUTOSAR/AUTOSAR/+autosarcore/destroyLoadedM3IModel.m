function destroyLoadedM3IModel(model)






    mdlName=get_param(model,'Name');
    m3iModel=[];
    if autosarcore.ModelUtils.isMapped(mdlName)

        mapping=autosarcore.ModelUtils.modelMapping(mdlName);
        m3iModel=mapping.AUTOSAR_ROOT;
    end

    if~isempty(m3iModel)&&m3iModel.isvalid()
        autosarcore.unregisterListenerCB(m3iModel);


        if Simulink.AutosarDictionary.ModelRegistry.hasReferencedModels(m3iModel)
            Simulink.AutosarDictionary.ModelRegistry.removeAllReferencedModels(m3iModel);
        end


        trans=M3I.Transaction(m3iModel);
        m3iModel.destroy();
        trans.commit();
    end

end


