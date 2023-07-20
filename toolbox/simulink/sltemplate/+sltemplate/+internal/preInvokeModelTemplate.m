function extractedSLX=preInvokeModelTemplate(pathToTemplate)




    templateInfo=sltemplate.internal.Registrar.getTemplateInfo(pathToTemplate);

    if isempty(templateInfo)||~slcellmember(templateInfo.Type,{'Model','Library','Subsystem'})
        if isempty(Simulink.loadsave.resolveFile(pathToTemplate))
            DAStudio.error('sltemplate:Registry:TemplateFileNotFound',pathToTemplate);
        else
            DAStudio.error('sltemplate:Registry:InvalidTemplate',pathToTemplate);
        end
    end

    if~simulink_version(templateInfo.ReleaseName).valid

        DAStudio.error('sltemplate:Registry:TemplateCreatedInNewerRelease',...
        templateInfo.ReleaseName,pathToTemplate);
    end

    extractedSLX=[tempname,'.slx'];
    templateInfo.extract(templateInfo.ContainedFiles{1},extractedSLX);

end