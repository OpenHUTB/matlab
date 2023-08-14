function SlreqImportDlg_subDocCombo_callback(this,dlg)



    switch this.srcType
    case 2
        selected=dlg.getWidgetValue('SlreqImportDlg_subDocCombo');
        selectedSheet=this.docObj.sSheets{selected+1};
        if~strcmp(selectedSheet,this.subDoc)
            this.subDoc=selectedSheet;
            this.docObj.setActiveSheet(selected+1);
        end
    case 5
        selected=dlg.getWidgetValue('SlreqImportDlg_subDocCombo');
        if selected>0&&~isempty(this.subDocs)
            this.subDoc=this.subDocs{selected};
        else
            this.subDoc='';
        end
        dlg.refresh();
    otherwise

    end
end
