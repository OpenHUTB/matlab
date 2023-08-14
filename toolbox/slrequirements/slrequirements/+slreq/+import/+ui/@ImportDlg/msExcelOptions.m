function[items,grid]=msExcelOptions(this)

    styleOption.Type='radiobutton';
    styleOption.Name=getString(message('Slvnv:slreq_import:Content'));
    styleOption.Tag='SlreqImportDlg_styleOption';
    styleOption.Value=this.style;
    styleOption.Values=[0,1];
    styleOption.Entries={...
    getString(message('Slvnv:slreq_import:OptionPlainTextExcel')),...
    getString(message('Slvnv:slreq_import:OptionRichTextExcel'))};
    styleOption.RowSpan=[1,1];
    styleOption.ColSpan=[1,1];
    styleOption.ObjectMethod='SlreqImportDlg_styleOption_callback';
    styleOption.MethodArgs={'%dialog'};
    styleOption.ArgDataTypes={'handle'};

    mappingOption.Type='radiobutton';
    mappingOption.Name='';
    mappingOption.Tag='SlreqImportDlg_mappingOption';
    mappingOption.Value=this.mapping;
    mappingOption.Values=[0,1];
    mappingOption.Entries={...
    getString(message('Slvnv:slreq_import:OptionImportSelectedExcel')),...
    getString(message('Slvnv:slreq_import:OptionImportSearchExcel'))};
    mappingOption.RowSpan=[1,2];
    mappingOption.ColSpan=[1,1];
    mappingOption.ObjectMethod='SlreqImportDlg_mappingOption_callback';
    mappingOption.MethodArgs={'%dialog'};
    mappingOption.ArgDataTypes={'handle'};

    columnSelector.Type='pushbutton';
    columnSelector.Name=getString(message('Slvnv:slreq_import:MapColumns'));
    columnSelector.Tag='SlreqImportDlg_attributeSelector';
    columnSelector.RowSpan=[1,1];
    columnSelector.ColSpan=[4,4];
    columnSelector.Enabled=(this.mapping==0)&&this.isReadyForAttributeSelection();
    columnSelector.ObjectMethod='SlreqImportDlg_attributeSelector_callback';
    columnSelector.MethodArgs={'%dialog'};
    columnSelector.ArgDataTypes={'handle'};

    columnList.Type='text';
    columnList.Tag='SlreqImportDlg_columnList';
    columnList.Name=listSelectedColumns();
    columnList.RowSpan=[1,1];
    columnList.ColSpan=[3,3];

    patternEdit.Type='edit';
    patternEdit.Tag='SlreqImportDlg_patternEdit';
    patternEdit.Value=this.pattern;

    patternEdit.ToolTip='Use a regular expression to match persistent IDs in your document';
    patternEdit.RowSpan=[2,2];
    patternEdit.ColSpan=[2,3];
    patternEdit.Enabled=(this.mapping==1);
    patternEdit.ObjectMethod='SlreqImportDlg_patternEdit_callback';
    patternEdit.MethodArgs={'%dialog'};
    patternEdit.ArgDataTypes={'handle'};

    previewButton.Name=getString(message('Slvnv:slreq_import:Preview'));
    previewButton.Tag='SlreqImportDlg_Preview';
    previewButton.Type='pushbutton';
    previewButton.RowSpan=[2,2];
    previewButton.ColSpan=[4,4];
    previewButton.ObjectMethod='SlreqImportDlg_Preview_callback';
    previewButton.MethodArgs={'%dialog'};
    previewButton.ArgDataTypes={'handle'};
    previewButton.Enabled=this.isReadyForPreview();

    mappingGroup.Type='group';
    mappingGroup.Name=getString(message('Slvnv:slreq_import:ContentSelection'));
    mappingGroup.LayoutGrid=[2,4];
    mappingGroup.Items={mappingOption,columnSelector,columnList,patternEdit,previewButton};
    mappingGroup.RowSpan=[2,2];
    mappingGroup.ColSpan=[1,1];

    items={styleOption,mappingGroup};
    grid=[2,1];

    function list=listSelectedColumns()
        if~isempty(this.idColumn)
            list=[',',rmiut.xlsColNumToName(this.idColumn)];
        else
            list=',';
        end
        if~isempty(this.summaryColumn)
            list=[list,',',rmiut.xlsColNumToName(this.summaryColumn)];
        end
        if~isempty(this.descriptionColumn)
            list=[list,',',rmiut.xlsColNumToName(this.descriptionColumn)];
        end
        if~isempty(this.rationaleColumn)
            list=[list,',',rmiut.xlsColNumToName(this.rationaleColumn)];
        end
        if~isempty(this.keywordsColumn)
            list=[list,',',rmiut.xlsColNumToName(this.keywordsColumn)];
        end
        if~isempty(this.attributeColumn)
            list=[list,',',rmiut.xlsColNumToName(this.attributeColumn)];
        end
        list(1)=' ';
        if length(list)>1

            list=[list,', ',sprintf('%d-',this.rows);];
            list(end)=[];
        end
    end
end
