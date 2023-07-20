
function saveTemplateCB(cbinfo,~)
    sysHandle=SLStudio.Utils.getModelName(cbinfo);
    metadata=get_param(sysHandle,'TemplateMetadata');

    if metadata.template.isBuiltin
        sltemplate.ui.ExportTemplate(sysHandle,'DialogType',"SaveAs");
        return;
    end

    blocker=SLM3I.ScopedStudioBlocker(sysHandle);
    cleanup=onCleanup(@()delete(blocker));

    Simulink.saveTemplate(sysHandle,metadata.template.fullFilePath);

    delete(cleanup);
end
