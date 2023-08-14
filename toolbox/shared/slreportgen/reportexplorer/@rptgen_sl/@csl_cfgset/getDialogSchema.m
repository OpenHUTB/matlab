function dlgStruct=getDialogSchema(this,name)




    msg=@(key)rptgen_sl.csl_cfgset.msg(key);


    this.updateErrorState;

    [wTitleMode,lTitleMode]=dlgWidget(this,'TitleMode',...
    'DialogRefresh',true,...
    'RowSpan',[1,1],...
    'ColSpan',[2,2]);

    wTitleMode.ToolTip=msg('WdgtTTTitleMode');

    wCustomTitle=dlgWidget(this,'CustomTitle',...
    'Enabled',strcmp(this.TitleMode,'manual'),...
    'RowSpan',[1,1],...
    'ColSpan',[3,3]);

    wCustomTitle.ToolTip=msg('WdgtTTCustomTitle');

    wShowGrids=dlgWidget(this,'ShowTableGrids',...
    'RowSpan',[2,2],...
    'ColSpan',[1,3]);
    wShowGrids.Name=msg('WdgtLblShowGrids');
    wShowGrids.ToolTip=msg('WdgtTTShowGrids');

    wPageWide=dlgWidget(this,'MakeTablePageWide',...
    'RowSpan',[3,3],...
    'ColSpan',[1,3]);

    wPageWide.Name=msg('WdgtLblPgWide');
    wPageWide.ToolTip=msg('WdgtTTPgWide');


    pDisplay=this.dlgContainer({
wTitleMode
lTitleMode
wCustomTitle
wShowGrids
wPageWide

    },rptgen.rpt_var_display.msg('WdgtLblDisplayOpt'),...
    'LayoutGrid',[4,3],...
    'RowStretch',[0,0,0,1],...
    'ColStretch',[0,0,1],...
    'RowSpan',[2,2],...
    'ColSpan',[1,1]);



    dlgStruct=this.dlgMain(name,{
pDisplay
    },...
    'LayoutGrid',[2,1],...
    'RowStretch',[0,1]);



