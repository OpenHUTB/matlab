function dlgStruct=getDialogSchema(this,name)




    this.getRefentryInfo;

    dlgStruct=this.dlgMain(name,{
    this.dlgAddContainer('RowSpan',[1,1],'ColSpan',[1,1])
    this.dlgValueContainer('RowSpan',[2,2],'ColSpan',[1,1])
    this.dlgPreviewContainer('RowSpan',[3,3],'ColSpan',[1,1])
    this.dlgHelpContainer('RowSpan',[4,4],'ColSpan',[1,1])
    },...
    'LayoutGrid',[4,1],...
    'RowStretch',[0,1,0,0],...
    'DialogTitle',getString(message('rptgen:RptgenML_StylesheetElementID:editStylesheetDataLabel')));

