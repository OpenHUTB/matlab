function isDDSApp=isDDSApp(modelName)





    isDDSApp=false;
    if slfeature('CppIOCustomization')==1&&...
        strcmp(get_param(modelName,'TargetLang'),'C++')
        mapping=Simulink.CodeMapping.getCurrentMapping(modelName);
        if~isempty(mapping)&&strcmp(mapping.DeploymentType,'Application')
            isDDSApp=true;
        end
    end
end

