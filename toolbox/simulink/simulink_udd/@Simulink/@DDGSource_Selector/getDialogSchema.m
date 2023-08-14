function dlgStruct=getDialogSchema(this,str)




























    block=this.getBlock;

    if isempty(this.DialogData)

        this.cacheDialogParams;
    end

    numDims=this.getNumDims;





    items=cell(1,5);
    [items{1},items{2},items{3},items{5}]=this.getCommonWidgets;


    idxoptID=this.getColId('idxopt');
    idxID=this.getColId('idx');
    outsizeID=this.getColId('outsize');

    for i=1:numDims
        if this.isAllOpt(items{3}.Data{i,idxoptID}.Value)
            items{3}.Data{i,outsizeID}.Value=this.getOutSizeStrForAllOpt;
            items{3}.Data{i,outsizeID}.Enabled=false;
        else
            if this.isDialogOpt(items{3}.Data{i,idxoptID}.Value)
                if this.isIdxVectOpt(items{3}.Data{i,idxoptID}.Value)
                    items{3}.Data{i,outsizeID}.Value=this.getOutSizeStrForDlgIdxOpt;
                    items{3}.Data{i,outsizeID}.Enabled=false;
                end






                if isempty(regexp(items{3}.Data{i,idxID}.Value,'[a-zA-Z_]','once'))
                    try
                        indexVal=eval(items{3}.Data{i,idxID}.Value);
                        if isnumeric(indexVal)&&isscalar(indexVal)&&indexVal==-1
                            items{3}.Data{i,outsizeID}.Value=this.getOutSizeStrForAllOpt;
                            items{3}.Data{i,outsizeID}.Enabled=false;
                        end
                    catch

                    end
                end
            else
                if this.isIdxVectOpt(items{3}.Data{i,idxoptID}.Value)
                    items{3}.Data{i,outsizeID}.Value=this.getOutSizeStrForPrtIdxOpt(i);
                    items{3}.Data{i,outsizeID}.Enabled=false;
                elseif this.isStartEndOpt(items{3}.Data{i,idxoptID}.Value)
                    items{3}.Data{i,outsizeID}.Value=this.getOutSizeStrForPrtStartEndOpt(i);
                    items{3}.Data{i,outsizeID}.Enabled=false;
                end
            end
        end
    end


    isVector=(numDims==1);
    inputwidth_edit=this.initWidget('InputPortWidth',false);
    inputwidth_edit.Tag='_Vector_Input_Width_';
    inputwidth_edit.ActionProperty='InputPortWidth';
    inputwidth_edit.RowSpan=[4,4];
    inputwidth_edit.ColSpan=[1,1];
    inputwidth_edit.Visible=isVector;
    items{4}=inputwidth_edit;


    items{5}.RowSpan=[5,5];


    if slfeature('SelectorAssignmentRuntimeCheckUI')>0
        runtimecheck_tick=this.initWidget('RuntimeRangeChecks',false);
        runtimecheck_tick.Tag='_Runtime_Check_';
        runtimecheck_tick.ToolTip=DAStudio.message('Simulink:blkprm_prompts:AssignSelectRuntimeRangeChecksTooltip');
        runtimecheck_tick.RowSpan=[6,6];
        runtimecheck_tick.ColSpan=[1,1];
        runtimecheck_tick.Visible=true;

        items{end+1}=runtimecheck_tick;
    end



    numRows=items{end}.RowSpan(1);
    rowStretch=zeros([1,numRows]);
    rowStretch(3)=1;

    dlgStruct=this.constructDlgStruct(items,numRows,rowStretch);


    dlgStruct.DialogTag='_Selector_Dialog_';

end
