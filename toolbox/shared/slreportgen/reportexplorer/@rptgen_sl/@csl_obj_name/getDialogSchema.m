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
    this.dlgWidget('RenderAs',...
    'RowSpan',[2,2],...
    'ColSpan',[1,1])
    this.dlgWidget('isFullName',...
    'RowSpan',[3,3],...
    'ColSpan',[1,1])
    },getString(message('RptgenSL:rsl_csl_obj_name:propertiesLabel')),...
    'LayoutGrid',[4,1],...
    'RowStretch',[0,0,0,1])
    });
