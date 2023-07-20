function subSysBrowseCallback(slcovcc,parentDialog)



    cs=slcovcc.getConfigSet;
    slcovcc.modelH=cs.getModel;

    controller=cs.getDialogController;
    dlg=DAStudio.Dialog(SlCov.CovSubSysTree(slcovcc,parentDialog));
    controller.covSubSysTreeDlg=dlg;
