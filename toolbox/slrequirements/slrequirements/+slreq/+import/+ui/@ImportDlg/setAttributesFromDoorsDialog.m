function setAttributesFromDoorsDialog(this,childDlgSrc,commit)




    childDlgSrc.caller.setEnabled('SlreqImportDlg_attributeSelector',true);
    if commit
        this.attributeMap=childDlgSrc.attributeMap;

        dlg=slreq.import.ui.dlg_mgr('get');
        this.refreshDlg(dlg);

        this.populateDoorsMapping(this.attributeMap);
    end
end

