function[mfModel,templateMetadata]=extractTemplateMetadata(sys)


    mfModel=mf.zero.Model;

    pathToTemplate=get_param(sys,"TemplateFilePath");

    templateMetadata=Simulink.internal.packaging.datamodel.modelTemplate.ModelTemplate(mfModel);
    templateMetadata.createIntoCore();
    templateMetadata.createIntoTemplate();

    tInfo=sltemplate.TemplateInfo(pathToTemplate);
    templateMetadata.core.title=tInfo.Title;
    templateMetadata.core.author=tInfo.Creator;
    templateMetadata.core.group=tInfo.Group;
    templateMetadata.core.description=tInfo.Description;
    templateMetadata.core.releaseName=tInfo.ReleaseName;
    templateMetadata.core.type=tInfo.Type;
    templateMetadata.template.fullFilePath=tInfo.FileName;
    templateMetadata.template.isBuiltin=tInfo.IsBuiltin;
    if tInfo.HasThumbnail

        templateMetadata.template.thumbnail=tInfo.FileName;
    end
end
