function grandfatherAdaptiveSchemaVersion(modelH)





    if get_param(modelH,'VersionLoaded')<10&&...
        Simulink.CodeMapping.isAutosarAdaptiveSTF(modelH)
        set_param(modelH,'AutosarSchemaVersion','R18-10');
    end
end
