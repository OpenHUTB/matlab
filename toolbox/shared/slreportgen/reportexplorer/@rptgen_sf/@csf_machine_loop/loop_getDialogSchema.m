function dlgStruct=loop_getDialogSchema(this,name)




    if~builtin('license','checkout','SIMULINK_Report_Gen')
        dlgStruct=this.buildErrorMessage('panel',true);
        return;

    end

    dlgStruct={
    this.dlgContainer({
    RptgenML.twoColumnTable(this,'SFFilterTerms','isSFFilterList',...
    'RowSpan',[1,1],...
    'ColSpan',[1,1])
    },getString(message('RptgenSL:rsf_csf_machine_loop:loopOptionsLabel')),'LayoutGrid',[1,1],'RowStretch',[1])
    };
