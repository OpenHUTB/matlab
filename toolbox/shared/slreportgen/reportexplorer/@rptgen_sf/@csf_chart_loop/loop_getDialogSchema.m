function dlgStruct=loop_getDialogSchema(this,name)




    if~builtin('license','checkout','SIMULINK_Report_Gen')
        dlgStruct=this.buildErrorMessage('panel',true);
        return;

    end



    if strcmp(this.LoopType,'list')
        wObjectList=this.dlgWidget('ObjectList');
    else
        wObjectList=this.dlgText(this.loop_getContextString);
    end

    dlgStruct={
    this.dlgContainer({
    this.dlgWidget('LoopType',...
    'DialogRefresh',true);
wObjectList
    },getString(message('RptgenSL:rsf_csf_chart_loop:reportOnLabel')))
    this.dlgContainer({
    this.dlgWidget('SortBy',...
    'RowSpan',[1,1],...
    'ColSpan',[1,1])
    RptgenML.twoColumnTable(this,'FilterTerms','isFilterList',...
    'RowSpan',[2,2],...
    'ColSpan',[1,1])
    RptgenML.twoColumnTable(this,'SFFilterTerms','isSFFilterList',...
    'RowSpan',[3,3],...
    'ColSpan',[1,1])
    },getString(message('RptgenSL:rsf_csf_chart_loop:loopOptionsLabel')),'LayoutGrid',[3,1],'RowStretch',[0,1,1])
    };

