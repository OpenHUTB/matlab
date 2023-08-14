function dlgStruct=getDialogSchema(this,name)




    if~builtin('license','checkout','SIMULINK_Report_Gen')
        dlgStruct=this.buildErrorMessage(name,true);
        return;

    end

    w=this.dlgWidget;

    dlgStruct=this.dlgMain(name,{
    this.dlgContainer({
    this.dlgSet(w.TitleMode,...
    'ColSpan',[1,1],...
    'RowSpan',[1,1],...
    'DialogRefresh',true)
    this.dlgSet(w.Title,...
    'ColSpan',[2,2],...
    'RowSpan',[1,1],...
    'Enabled',strcmp(this.TitleMode,'manual'))
    },getString(message('RptgenSL:rsf_csf_truthtable:titleLabel')),'LayoutGrid',[2,1])
    this.dlgContainer({
    w.ShowConditionHeader
    w.ShowConditionNumber
    w.ShowConditionCode
    w.ShowConditionDescription
    w.ConditionWrapLimit
    },getString(message('RptgenSL:rsf_csf_truthtable:conditionTableLabel')))
    this.dlgContainer({
    w.ShowActionHeader
    w.ShowActionNumber
    w.ShowActionCode
    w.ShowActionDescription
    },getString(message('RptgenSL:rsf_csf_truthtable:actionTableLabel')))
    });
