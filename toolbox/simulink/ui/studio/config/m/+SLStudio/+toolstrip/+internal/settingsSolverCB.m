function settingsSolverCB(cbinfo)
    model=cbinfo.studio.App.blockDiagramHandle;

    if~isempty(model)
        cs=getActiveConfigSet(model);
        cs.view;
        slCfgPrmDlg(cs,'TurnToPage','Solver');
    end
end
