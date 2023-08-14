function SlreqImportDlg_attributeSelector_callback(this,dlg)



    if this.isReadyForAttributeSelection()

        dlg.setEnabled('SlreqImportDlg_attributeSelector',false);

        if~isempty(this.childDlg)
            this.childDlg=[];
            slreq.import.ui.attrDlg_mgr('clear');
        end


        switch this.srcType
        case 2
            this.childDlg=slreq.import.ui.attrDlg_mgr('show',dlg,this.srcType,this.srcDoc,this.subDoc);
        case 3

            [~,shortName,fExt]=fileparts(this.srcDoc);
            rmiut.progressBarFcn('set',0.1,...
            getString(message('Slvnv:slreq_import:ProcessingContentOf',[shortName,fExt])));
            this.childDlg=slreq.import.ui.attrDlg_mgr('show',dlg,this.srcType,this.srcDoc);
            rmiut.progressBarFcn('delete');
        case 4
            this.childDlg=slreq.import.ui.attrDlg_mgr('show',dlg,this.srcType,this.srcDoc);
        case 5
            projUri=this.getProjectUri(this.serverCatalog,this.srcDoc);
            serverLoginInfoStruct=struct('server',this.serverName,'username',this.serverUser,'passcode',this.serverPass,'uri',projUri);
            this.childDlg=slreq.import.ui.attrDlg_mgr('show',dlg,this.srcType,this.srcDoc,serverLoginInfoStruct);
        otherwise

        end
    end
end
