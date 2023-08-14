function setAttributesFromReqifDialog(this,childDlgSrc,commit)





    childDlgSrc.caller.setEnabled('SlreqImportDlg_attributeSelector',true);
    if commit
        if~isempty(childDlgSrc.attributeMap)
            this.reqifData=childDlgSrc.reqIfData;
            this.attributeMap=childDlgSrc.attributeMap;

            this.populateReqIfMapping();
        end

        dlg=slreq.import.ui.dlg_mgr('get');
        this.refreshDlg(dlg);
    end
end

