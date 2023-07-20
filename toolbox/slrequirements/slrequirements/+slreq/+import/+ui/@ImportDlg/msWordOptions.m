function[items,grid]=msWordOptions(this)

    styleOption.Type='radiobutton';
    styleOption.Name=getString(message('Slvnv:slreq_import:Content'));
    styleOption.Tag='SlreqImportDlg_styleOption';
    styleOption.Value=this.style;
    styleOption.Values=[0,1];
    styleOption.Entries={...
    getString(message('Slvnv:slreq_import:OptionPlainTextWord')),...
    getString(message('Slvnv:slreq_import:OptionRichTextWord'))};
    styleOption.RowSpan=[1,1];
    styleOption.ColSpan=[1,1];
    styleOption.ObjectMethod='SlreqImportDlg_styleOption_callback';
    styleOption.MethodArgs={'%dialog'};
    styleOption.ArgDataTypes={'handle'};

    mappingNote1.Type='text';
    mappingNote1.Name=getString(message('Slvnv:slreq_import:OptionImportSectionsWord1'));
    mappingNote1.RowSpan=[1,1];
    mappingNote1.ColSpan=[1,5];

    mappingNote2.Type='text';
    mappingNote2.Name=getString(message('Slvnv:slreq_import:OptionImportSectionsWord2'));
    mappingNote2.RowSpan=[2,2];
    mappingNote2.ColSpan=[1,5];

    bookmarkCheck.Type='checkbox';
    bookmarkCheck.Name=getString(message('Slvnv:slreq_import:UseBookmarks'))';
    bookmarkCheck.Tag='SlreqImportDlg_bookmarkCheck';
    bookmarkCheck.Value=this.bookmarks;
    bookmarkCheck.Enabled=true;
    bookmarkCheck.RowSpan=[3,3];
    bookmarkCheck.ColSpan=[1,4];
    bookmarkCheck.ObjectMethod='SlreqImportDlg_bookmarkCheck_callback';
    bookmarkCheck.MethodArgs={'%dialog'};
    bookmarkCheck.ArgDataTypes={'handle'};

    patternCheck.Type='checkbox';
    patternCheck.Name=getString(message('Slvnv:slreq_import:UsePattern'))';
    patternCheck.Tag='SlreqImportDlg_patternCheck';
    patternCheck.Value=this.mapping>0;
    patternCheck.RowSpan=[4,4];
    patternCheck.ColSpan=[1,3];
    patternCheck.ObjectMethod='SlreqImportDlg_patternCheck_callback';
    patternCheck.MethodArgs={'%dialog'};
    patternCheck.ArgDataTypes={'handle'};

    previewButton.Name=getString(message('Slvnv:slreq_import:Preview'));
    previewButton.Tag='SlreqImportDlg_Preview';
    previewButton.Type='pushbutton';
    previewButton.RowSpan=[3,3];
    previewButton.ColSpan=[5,5];
    previewButton.ObjectMethod='SlreqImportDlg_Preview_callback';
    previewButton.MethodArgs={'%dialog'};
    previewButton.ArgDataTypes={'handle'};
    previewButton.Enabled=this.isReadyForPreview();

    patternEdit.Type='edit';
    patternEdit.Tag='SlreqImportDlg_patternEdit';
    patternEdit.Value=this.pattern;

    patternEdit.ToolTip='Use a regular expression to match persistent IDs in your document';
    patternEdit.RowSpan=[4,4];
    patternEdit.ColSpan=[4,5];
    patternEdit.Enabled=(this.mapping==1);
    patternEdit.ObjectMethod='SlreqImportDlg_patternEdit_callback';
    patternEdit.MethodArgs={'%dialog'};
    patternEdit.ArgDataTypes={'handle'};

    numbersCheck.Type='checkbox';
    numbersCheck.Name=getString(message('Slvnv:slreq_import:IgnoreSectionNumbers'))';
    numbersCheck.Tag='SlreqImportDlg_numbersCheck';
    numbersCheck.Value=this.ignoreOutlineNumbers;
    numbersCheck.RowSpan=[5,5];
    numbersCheck.ColSpan=[1,3];
    numbersCheck.ObjectMethod='SlreqImportDlg_numbersCheck_callback';
    numbersCheck.MethodArgs={'%dialog'};
    numbersCheck.ArgDataTypes={'handle'};

    mappingGroup.Type='group';
    mappingGroup.Name=getString(message('Slvnv:slreq_import:ContentSelection'));
    mappingGroup.LayoutGrid=[5,5];
    mappingGroup.Items={...
    mappingNote1,...
    mappingNote2,...
    bookmarkCheck,previewButton,...
    patternCheck,patternEdit,...
    numbersCheck};
    mappingGroup.RowSpan=[2,2];
    mappingGroup.ColSpan=[1,1];

    items={styleOption,mappingGroup};
    grid=[2,1];

end
