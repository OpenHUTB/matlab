function dlgStruct=loop_getDialogSchema(this,name)




    if~builtin('license','checkout','SIMULINK_Report_Gen')
        dlgStruct=this.buildErrorMessage('panel',true);
        return;
    end

    dlgStruct={
    this.dlgContainer({
    this.dlgText(this.loop_getContextString,...
    'RowSpan',[1,1],...
    'ColSpan',[1,1])
    },getString(message('RptgenSL:rsl_CAnnotationLoop:reportOnLabel')),...
    'LayoutGrid',[1,1],'RowStretch',[0])
    this.dlgContainer({
    this.dlgWidget('SortBy',...
    'RowSpan',[2,2],...
    'ColSpan',[1,1])
    },getString(message('RptgenSL:rsl_CAnnotationLoop:loopOptionsLabel')),...
    'LayoutGrid',[3,1],'RowStretch',[0,0,1])
    };






