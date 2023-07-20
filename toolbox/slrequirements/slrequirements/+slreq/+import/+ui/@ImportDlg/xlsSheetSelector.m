function items=xlsSheetSelector(this)

    sheetLabel.Type='text';
    sheetLabel.Name=getString(message('Slvnv:slreq_import:MSExcelSheetName'));
    sheetLabel.RowSpan=[3,3];
    sheetLabel.ColSpan=[2,2];
    sheetLabel.Enabled=~isempty(this.srcDoc);

    subDocCombo.Type='combobox';
    subDocCombo.Tag='SlreqImportDlg_subDocCombo';
    if isempty(this.srcDoc)
        subDocCombo.Entries={};
    else

        this.docObj=rmidotnet.docUtilObj(this.srcDoc);
        if isempty(this.docObj)
            subDocCombo.Entries={};
            subDocCombo.Value=[];
        else
            sheetNames=this.docObj.getSheetNames();
            subDocCombo.Entries=sheetNames';
            this.subDoc=sheetNames{this.docObj.iSheet};
            subDocCombo.Value=this.subDoc;
        end
    end
    subDocCombo.RowSpan=[3,3];
    subDocCombo.ColSpan=[3,4];
    subDocCombo.Enabled=~isempty(this.srcDoc);
    subDocCombo.ObjectMethod='SlreqImportDlg_subDocCombo_callback';
    subDocCombo.MethodArgs={'%dialog'};
    subDocCombo.ArgDataTypes={'handle'};

    subDocPrefixOption.Type='checkbox';
    subDocPrefixOption.Tag='SlreqImportDlg_subDocPrefix';
    subDocPrefixOption.Name=getString(message('Slvnv:slreq_import:UseWorksheetNamePrefix'));
    subDocPrefixOption.ObjectMethod='SlreqImportDlg_subDocPrefix_callback';
    subDocPrefixOption.MethodArgs={'%dialog'};
    subDocPrefixOption.ArgDataTypes={'handle'};
    subDocPrefixOption.RowSpan=[4,4];
    subDocPrefixOption.ColSpan=[2,4];
    items={sheetLabel,subDocCombo,subDocPrefixOption};

end

