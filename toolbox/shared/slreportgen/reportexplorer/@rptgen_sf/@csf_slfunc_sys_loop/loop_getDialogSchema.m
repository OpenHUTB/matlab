function dlgStruct=loop_getDialogSchema(this,~)





    if~builtin('license','checkout','SIMULINK_Report_Gen')
        dlgStruct=this.buildErrorMessage('panel',true);
        return;
    end



    wIncludeNestedCharts=this.dlgWidget('IncludeNestedCharts',...
    'RowSpan',[1,1],...
    'ColSpan',[1,1]);

    pReportOn=this.dlgContainer({
wIncludeNestedCharts
    },getString(message('RptgenSL:rsf_csf_slfunc_sys_loop:reportOnLabel')),...
    'LayoutGrid',[2,1],...
    'RowStretch',[0,0]);


    wSortBy=this.dlgWidget('SortBy',...
    'RowSpan',[1,1],...
    'ColSpan',[1,1],...
    'DialogRefresh',true);

    wFilterTable=RptgenML.twoColumnTable(this,'FilterTerms','isFilterList',...
    'RowSpan',[2,2],...
    'ColSpan',[1,1]);

    pLoopOptions=this.dlgContainer({
wSortBy
wFilterTable
    },getString(message('RptgenSL:rsf_csf_slfunc_sys_loop:loopOptionsLabel')),...
    'LayoutGrid',[2,1],...
    'RowStretch',[0,1]);


    dlgStruct={
pReportOn
pLoopOptions
    };

