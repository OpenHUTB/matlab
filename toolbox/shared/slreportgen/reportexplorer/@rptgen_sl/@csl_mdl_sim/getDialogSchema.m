function dlgStruct=getDialogSchema(this,name)




    if~builtin('license','checkout','SIMULINK_Report_Gen')
        dlgStruct=this.buildErrorMessage(name,true);
        return;

    end

    dlgStruct=this.dlgMain(name,{
    this.dlgIOParameters('RowSpan',[1,1],'ColSpan',[1,1])
    this.dlgTimespan('RowSpan',[2,2],'ColSpan',[1,1])
    this.dlgSimOpt('RowSpan',[3,3],'ColSpan',[1,1])
    },'LayoutGrid',[3,1],...
    'RowStretch',[0,0,1]);


