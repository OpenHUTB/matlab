function dlgStruct=getDialogSchema(this,name)




    optPanel=getInfoSchema(this);
    editPanel=getEditSchema(this);

    dlgStruct=this.dlgMain(name,...
    {
    this.dlgSet(optPanel,...
    'RowSpan',[1,1],...
    'ColSpan',[1,1])
    this.dlgSet(editPanel,...
    'RowSpan',[2,2],...
    'ColSpan',[1,1])...
    },'LayoutGrid',[3,1],...
    'RowStretch',[0,0,1],...
    'DialogTitle',getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:templateEditorDialogTitle',this.ID)));

