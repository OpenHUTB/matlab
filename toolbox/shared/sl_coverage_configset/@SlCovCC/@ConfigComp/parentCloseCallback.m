function parentCloseCallback(this)


    cs=this.getConfigSet;
    controller=cs.getDialogController;
    subsysDlg=controller.covSubSysTreeDlg;
    if isa(subsysDlg,'DAStudio.Dialog')
        delete(subsysDlg);
    end

    covMdlRefSelUIH=this.getCovMdlRefSelUIH;
    if~isempty(covMdlRefSelUIH)&&isvalid(covMdlRefSelUIH)&&ishandle(covMdlRefSelUIH.m_editor.getDialog)
        covMdlRefSelUIH.closeCallback([Simulink.ModelReference.HierarchyExplorerUI.UI.getUITagBase,'Hidden_Destroy']);
    end