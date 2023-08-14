function settingsRefModelCB(cbinfo)
    model=cbinfo.studio.App.blockDiagramHandle;

    if~isempty(model)
        cs=getActiveConfigSet(model);
        cs.view;
        slCfgPrmDlg(cs,'TurnToPage','Model Referencing');
    end
end
