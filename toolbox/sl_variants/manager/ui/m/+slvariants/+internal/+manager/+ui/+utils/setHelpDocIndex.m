function setHelpDocIndex(vmStudioHandle,helpDocIdx)



    import slvariants.internal.manager.ui.config.VMgrConstants;
    helpDocComp=vmStudioHandle.getComponent('GLUE2:DDG Component',VMgrConstants.Help);
    helpDocDlg=helpDocComp.getDialog();
    if~isempty(helpDocDlg)
        helpDocDlg.getDialogSource.ActiveTab=helpDocIdx;
        helpDocDlg.refresh();
    end
end