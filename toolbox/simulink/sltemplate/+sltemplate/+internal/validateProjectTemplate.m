function validateProjectTemplate(pathToTemplate)





    templateInfo=sltemplate.internal.Registrar.getTemplateInfo(pathToTemplate);

    if isempty(templateInfo)||~strcmp(templateInfo.Type,'Project')
        DAStudio.error('sltemplate:Registry:InvalidTemplate',pathToTemplate);
    end

    if~simulink_version(templateInfo.ReleaseName).valid

        DAStudio.error('sltemplate:Registry:TemplateCreatedInNewerRelease',...
        templateInfo.ReleaseName,pathToTemplate);
    end
end
