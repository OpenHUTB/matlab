function saveAsTemplateCB(cbinfo,~)
    sysHandle=SLStudio.Utils.getModelName(cbinfo);
    sltemplate.ui.ExportTemplate(sysHandle,'DialogType',"SaveAs");
end
