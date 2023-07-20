function editTemplateCB(cbinfo,~)
    sysHandle=SLStudio.Utils.getModelName(cbinfo);
    sltemplate.ui.ExportTemplate(sysHandle,'DialogType',"Edit");
end
