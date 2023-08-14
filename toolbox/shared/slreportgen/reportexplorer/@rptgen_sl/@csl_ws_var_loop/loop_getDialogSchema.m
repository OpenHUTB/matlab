function dlgStruct=loop_getDialogSchema(this,~)





    if~builtin('license','checkout','SIMULINK_Report_Gen')
        dlgStruct=this.buildErrorMessage('panel',true);
        return;
    end

    tContext=this.dlgText(this.loop_getContextString(),...
    'RowSpan',[1,1],...
    'ColSpan',[1,1]);

    pReportOn=this.dlgContainer({
tContext
    },this.msg('WdgtLblReportOn'),...
    'LayoutGrid',[1,1],...
    'RowStretch',0);

    wSortBy=this.dlgWidget('SortBy',...
    'RowSpan',[2,2],...
    'ColSpan',[1,1]);

    wFilterTerms=RptgenML.twoColumnTable(this,'FilterTerms','isFilterList',...
    'RowSpan',[3,3],...
    'ColSpan',[1,1]);

    pLoopOptions=this.dlgContainer({
wSortBy
wFilterTerms
    },this.msg('WdgtLblLoopOptions'),...
    'LayoutGrid',[3,1],...
    'RowStretch',[0,0,1]);

    dlgStruct={
pReportOn
pLoopOptions
    };


