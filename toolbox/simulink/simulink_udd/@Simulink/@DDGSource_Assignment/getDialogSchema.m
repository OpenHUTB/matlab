function dlgStruct=getDialogSchema(this,str)




























    block=this.getBlock;

    if isempty(this.DialogData)

        this.cacheDialogParams;
    end

    numDims=this.getNumDims;



    items=cell(1,6);
    [items{1},items{2},items{3},items{6}]=this.getCommonWidgets;


    idxoptID=this.getColId('idxopt');
    idxID=this.getColId('idx');
    outsizeID=this.getColId('outsize');


    outinit_enabled=false;
    for i=1:numDims
        if this.isPortOpt(items{3}.Data{i,idxoptID}.Value)
            outinit_enabled=true;
            break;
        end
    end

    outputinit_popup=this.initWidget('OutputInitialize',true);
    outputinit_popup.Tag='_Output_Initialize_';
    outputinit_popup.RowSpan=[4,4];
    outputinit_popup.ColSpan=[1,1];
    outputinit_popup.Visible=outinit_enabled;
    items{4}=outputinit_popup;


    outputWidthEnabled=outinit_enabled&&this.isSpecifyingOutSize(outputinit_popup.Value);
    if~outputWidthEnabled
        for i=1:numDims
            items{3}.Data{i,outsizeID}.Value=this.getOutSizeStrForOutInit;
            items{3}.Data{i,outsizeID}.Enabled=false;
        end
    end



    diagfordims_popup=this.initWidget('DiagnosticForDimensions',false);
    diagfordims_popup.Tag='_Diagnostic_For_Dimensions_';
    diagfordims_popup.RowSpan=[5,5];
    diagfordims_popup.ColSpan=[1,1];
    diagfordims_popup.Visible=outputWidthEnabled;
    items{5}=diagfordims_popup;



    items{6}.RowSpan=[6,6];


    if slfeature('SelectorAssignmentRuntimeCheckUI')>0
        runtimecheck_tick=this.initWidget('RuntimeRangeChecks',false);
        runtimecheck_tick.Tag='_Runtime_Check_';
        runtimecheck_tick.ToolTip=DAStudio.message('Simulink:blkprm_prompts:AssignSelectRuntimeRangeChecksTooltip');
        runtimecheck_tick.RowSpan=[7,7];
        runtimecheck_tick.ColSpan=[1,1];
        runtimecheck_tick.Visible=true;

        items{end+1}=runtimecheck_tick;
    end


    numRows=items{end}.RowSpan(1);
    rowStretch=zeros([1,numRows]);
    rowStretch(3)=1;

    dlgStruct=this.constructDlgStruct(items,numRows,rowStretch);

end
