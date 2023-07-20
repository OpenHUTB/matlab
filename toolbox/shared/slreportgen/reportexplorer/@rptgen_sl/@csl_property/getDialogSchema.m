function dlgStruct=getDialogSchema(this,name)




    if~builtin('license','checkout','SIMULINK_Report_Gen')
        dlgStruct=this.buildErrorMessage(name,true);
        return;

    end

    if strcmp(this.ObjectType,'Annotation')

        objectAndParameter={
        this.dlgWidget('ObjectType',...
        'DialogRefresh',1)
        };

        displayOptions=this.dlgContainer({
        },'',...
        'LayoutGrid',[11,3],...
        'RowStretch',[0,0,0,0,0,0,0,0,0,0,1],...
        'ColStretch',[0,0,1]);
    else

        objectAndParameter={
        this.dlgWidget('ObjectType',...
        'DialogRefresh',1)
        this.dlgWidget([this.ObjectType,'Property'])
        };
        displayOptions=this.vdGetDialogSchema(name);
    end

    dlgStruct=this.dlgMain(name,{
    this.dlgContainer(objectAndParameter,...
    getString(message('RptgenSL:rsl_csl_property:slObjectAndParamLabel')))
displayOptions
    });
