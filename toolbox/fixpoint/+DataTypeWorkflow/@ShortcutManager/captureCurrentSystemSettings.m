function captureCurrentSystemSettings(this,shortcutName)







    originalDirtyFlag=get_param(this.ModelName,'Dirty');

    currentSystem=this.ModelName;

    if~isempty(currentSystem)
        systems=SimulinkFixedPoint.AutoscalerUtils.getMdlRefs(this.ModelName);
        for idx=1:length(systems)
            systemObj=get_param(systems{idx},'Object');
            this.saveSystemSettings(systemObj,shortcutName);
            this.saveGlobalSettings(systemObj,shortcutName);
        end
    end

    this.updateCustomShortcuts(shortcutName,'add');


    set_param(this.ModelName,'Dirty',originalDirtyFlag);

end
