



function stateflowSettingsCB(userdata,cbinfo)
    model=cbinfo.studio.App.blockDiagramHandle;
    if~isempty(model)
        cs=getActiveConfigSet(model);
        cs.view;
        slCfgPrmDlg(cs,'TurnToPage',userdata);
    end
end
