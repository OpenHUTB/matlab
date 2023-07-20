function dlgStruct=getDialogSchema(this,name)




    if~builtin('license','checkout','SIMULINK_Report_Gen')
        dlgStruct=this.buildErrorMessage(name,true);
        return;

    end



    if strcmp(this.PropertyListMode,'manual')
        wPropertyList=this.dlgWidgetStringVector('PropertyList');
    else


        wPropertyList=this.dlgText('');
    end

    dlgStruct=this.dlgMain(name,{
    this.dlgContainer({
    this.dlgWidget('ObjectType')
    this.dlgWidget('PropertyListMode',...
    'DialogRefresh',1)
wPropertyList
    this.dlgWidget('ShowFullName')
    this.dlgWidget('ShowNamePrompt')
    },getString(message('RptgenSL:rsl_csl_auto_table:optionsLabel')))
    this.atGetDialogSchema(name)
    });
