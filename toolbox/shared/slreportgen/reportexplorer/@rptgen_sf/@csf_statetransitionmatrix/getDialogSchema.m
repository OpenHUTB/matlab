function dlgStruct=getDialogSchema(this,name)




    if~builtin('license','checkout','SIMULINK_Report_Gen')
        dlgStruct=this.buildErrorMessage(name,true);
        return;

    end

    w=this.dlgWidget;
















    [wTitleMode,tTitleMode]=this.dlgWidget('TitleMode',...
    'ColSpan',[1,2],...
    'RowSpan',[1,1],...
    'DialogRefresh',true);

    wTitle=this.dlgWidget('Title',...
    'ColSpan',[3,3],...
    'RowSpan',[1,1],...
    'Enabled',strcmp(this.TitleMode,'manual'));



    dlgStruct=this.dlgMain(name,{
tTitleMode
wTitleMode
wTitle
    w.DisplayConditionActions
    },...
    'LayoutGrid',[2,3],...
    'ColStretch',[0,0,1],...
    'RowStretch',[0,1]);


