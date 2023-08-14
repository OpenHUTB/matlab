function dlgStruct=getDialogSchema(this,name)




    dlgStruct=this.dlgMain(name,{
    this.dlgAddContainer('RowSpan',[1,1],'ColSpan',[1,1])
    this.dlgValueContainer('RowSpan',[2,2],'ColSpan',[1,1])
    this.dlgPreviewContainer('RowSpan',[3,3],'ColSpan',[1,1])
    },...
    'LayoutGrid',[3,1],...
    'RowStretch',[0,1,0],...
    'DialogTitle',getString(message('rptgen:RptgenML_StylesheetElement:editStylesheetDataLabel')));

