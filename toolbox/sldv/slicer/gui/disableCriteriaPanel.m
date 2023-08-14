function disableCriteriaPanel(dlg)




    dlgSrc=dlg.getSource;
    dlgSrc.criteriaListPanel.lockedForDebug=1;
    dlgSrc.sigListPanel.lockName=1;
    dlgSrc.sigListPanel.lockClearSimData=1;
    dlgSrc.criteriaListPanel.lockLoadSlms=1;
    dlg.refresh();

end
