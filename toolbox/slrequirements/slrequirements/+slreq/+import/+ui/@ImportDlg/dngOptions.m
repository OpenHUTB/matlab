function[items,grid]=dngOptions(this)

    isQueryBaseImport=(this.connectionMode>0);

    retrievalMode.Type='radiobutton';
    retrievalMode.Name=getString(message('Slvnv:slreq_import:DngGetReqsFrom'));
    retrievalMode.Tag='DngOptions_mode';

    retrievalMode.Value=0+isQueryBaseImport;
    retrievalMode.Values=[0,1];
    retrievalMode.Entries={...
    getString(message('Slvnv:slreq_import:DngImportFullModule')),...
    getString(message('Slvnv:slreq_import:DngImportByQuery'))};
    retrievalMode.RowSpan=[1,1];
    retrievalMode.ColSpan=[1,2];
    retrievalMode.ObjectMethod='SlreqImportDlg_dngMode_callback';
    retrievalMode.MethodArgs={'%dialog'};
    retrievalMode.ArgDataTypes={'handle'};

    queryBuilderButton.Type='pushbutton';
    queryBuilderButton.Name=getString(message('Slvnv:slreq_import:DngQueryBuilder'));
    queryBuilderButton.Tag='SlreqImportDlg_attributeSelector';
    queryBuilderButton.RowSpan=[2,2];
    queryBuilderButton.ColSpan=[1,1];
    queryBuilderButton.Enabled=isQueryBaseImport;
    queryBuilderButton.ObjectMethod='SlreqImportDlg_attributeSelector_callback';
    queryBuilderButton.MethodArgs={'%dialog'};
    queryBuilderButton.ArgDataTypes={'handle'};

    queryHistoryLabel.Type='text';
    queryHistoryLabel.Tag='DngOptions_queryHistoryLabel';

    queryHistoryLabel.Name=getString(message('Slvnv:slreq_import:DngQueryHistory'));
    queryHistoryLabel.Mode=true;
    queryHistoryLabel.RowSpan=[3,3];
    queryHistoryLabel.ColSpan=[1,2];
    queryHistoryLabel.Enabled=isQueryBaseImport;

    queryHistoryValue.Type='combobox';
    queryHistoryValue.Tag='DngOptions_queryHistory';
    this.queryHistory=slreq.import.QueryHistoryMgr.get(this.srcDoc);
    queryHistoryValue.Values=0:length(this.queryHistory);
    queryHistoryValue.Value=0;
    queryHistoryValue.Entries=[{getString(message('Slvnv:slreq_import:DngQueryFromHistory'))},this.queryHistory];
    queryHistoryValue.Enabled=isQueryBaseImport;
    queryHistoryValue.RowSpan=[4,4];
    queryHistoryValue.ColSpan=[1,2];
    queryHistoryValue.ObjectMethod='DngOptions_queryHistory_callback';
    queryHistoryValue.MethodArgs={'%dialog'};
    queryHistoryValue.ArgDataTypes={'handle'};

    rawQueryLabel.Type='text';
    rawQueryLabel.Tag='DngOptions_rawQueryLabel';
    rawQueryLabel.Name=getString(message('Slvnv:slreq_import:DngRawQueryString'));
    rawQueryLabel.Enabled=isQueryBaseImport;
    rawQueryLabel.RowSpan=[5,5];
    rawQueryLabel.ColSpan=[1,2];

    rawQuery.Type='edit';
    rawQuery.Tag='DngOptions_rawQuery';
    rawQuery.Value=this.queryString;
    rawQuery.Enabled=isQueryBaseImport;
    rawQuery.RowSpan=[6,6];
    rawQuery.ColSpan=[1,2];
    rawQuery.ObjectMethod='SlreqImportDlg_dngRawQuery_callback';
    rawQuery.MethodArgs={'%dialog'};
    rawQuery.ArgDataTypes={'handle'};

    items={retrievalMode,queryBuilderButton,...
    queryHistoryLabel,queryHistoryValue,...
    rawQueryLabel,rawQuery};
    grid=[6,2];

end
