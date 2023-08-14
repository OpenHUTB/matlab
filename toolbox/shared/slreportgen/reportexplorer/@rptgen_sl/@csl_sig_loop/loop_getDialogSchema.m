function dlgStruct=loop_getDialogSchema(this,name)




    if~builtin('license','checkout','SIMULINK_Report_Gen')
        dlgStruct=this.buildErrorMessage('panel',true);
        return;

    end



























    dlgStruct=this.dlgContainer({
    this.dlgWidget('isBlockIncoming',...
    'RowSpan',[1,1],...
    'ColSpan',[1,1])
    this.dlgWidget('isBlockOutgoing',...
    'RowSpan',[2,2],...
    'ColSpan',[1,1])
    this.dlgWidget('isSystemIncoming',...
    'RowSpan',[1,1],...
    'ColSpan',[2,2])
    this.dlgWidget('isSystemInternal',...
    'RowSpan',[2,2],...
    'ColSpan',[2,2])
    this.dlgWidget('isSystemOutgoing',...
    'RowSpan',[3,3],...
    'ColSpan',[2,2])
    this.dlgWidget('SortBy',...
    'RowSpan',[4,4],...
    'ColSpan',[1,2])
    },getString(message('RptgenSL:rsl_csl_sig_loop:selectSignalsLabel')),'LayoutGrid',[4,2]);
