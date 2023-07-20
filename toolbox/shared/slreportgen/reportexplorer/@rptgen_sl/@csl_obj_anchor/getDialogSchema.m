function dlgStruct=getDialogSchema(this,name)




    if~builtin('license','checkout','SIMULINK_Report_Gen')
        dlgStruct=this.buildErrorMessage(name,true);
        return;

    end





    dlgStruct=this.dlgMain(name,{
    this.dlgContainer({
    this.dlgWidget('ObjectType',...
    'RowSpan',[1,1],...
    'ColSpan',[1,1])
    this.dlgWidget('LinkText',...
    'RowSpan',[2,2],...
    'ColSpan',[1,1])
    },getString(message('RptgenSL:rsl_csl_obj_anchor:propertiesLabel')),...
    'LayoutGrid',[3,1],...
    'RowStretch',[0,0,1])
    });
