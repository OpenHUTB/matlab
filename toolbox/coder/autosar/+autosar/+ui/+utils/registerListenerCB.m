




function registerListenerCB(m3iObject)

    if~isempty(m3iObject)

        try
            M3I.registerObservingListener(m3iObject,...
            'autosar.ui.utils.listenerCallback');
        catch me %#ok<NASGU>

        end

        refModels=Simulink.AutosarDictionary.ModelRegistry.getReferencedModels(m3iObject.modelM3I);
        for mdlIdx=1:refModels.size()
            try
                M3I.registerObservingListener(refModels.at(mdlIdx),...
                'autosar.ui.utils.listenerCallback');
            catch me %#ok<NASGU>

            end
        end
    end
end


