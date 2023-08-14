function dlgStruct=loop_getDialogSchema(this,~)





    if~builtin('license','checkout','SIMULINK_Report_Gen')
        dlgStruct=this.buildErrorMessage('panel',true);
        return;
    end


    if strcmp(this.LoopType,'list')
        wObjectList=this.dlgWidgetStringVector('ObjectList');
        wObjectList.ForegroundColor=[1,1,255];
        ltRowStretch=[0,1,0];
    else
        wObjectList=this.dlgText(this.loop_getContextString);
        ltRowStretch=[0,0,0];
    end

    wLoopType=this.dlgWidget('LoopType',...
    'DialogRefresh',true,...
    'RowSpan',[1,1],...
    'ColSpan',[1,1]);

    pReportOn=this.dlgContainer({
wLoopType
    this.dlgSet(wObjectList,...
    'RowSpan',[2,2],...
    'ColSpan',[1,1])
    },getString(message('RptgenSL:rsl_csl_blk_loop:reportOnLabel')),...
    'LayoutGrid',[3,1],...
    'RowStretch',ltRowStretch);


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
    },getString(message('RptgenSL:rsl_csl_blk_loop:loopOptionsLabel')),...
    'LayoutGrid',[2,1],...
    'RowStretch',[0,1]);


    dlgStruct={
pReportOn
pLoopOptions
    };

