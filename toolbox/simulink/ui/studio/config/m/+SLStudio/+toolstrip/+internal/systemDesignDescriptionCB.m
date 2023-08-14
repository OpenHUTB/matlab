



function systemDesignDescriptionCB(cbinfo,~)
    modelName=SLStudio.Utils.getModelName(cbinfo);
    if~isempty(modelName)
        DAStudio.Dialog(StdRptDlg.SDD(get_param(modelName,'Object')));
    end
end
