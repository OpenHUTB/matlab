function dlgStruct=getDialogSchema(this,name)





    dlgStruct=this.dlgMain(name,{
    this.dlgText(this.MessageLong,...
    'RowSpan',[1,1],...
    'ColSpan',[1,1],...
    'WordWrap',true)
    },'DialogTitle',this.MessageShort,...
    'LayoutGrid',[2,1],...
    'RowStretch',[0,1],...
    'StandaloneButtonSet',{'OK'},...
    'EmbeddedButtonSet',{});




