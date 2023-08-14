function[numdims_edit,indexmode_popup,dimprop_table,sampletime_edit]=getCommonWidgets(this)





    numDims=this.getNumDims;


    numdims_edit=this.initWidget('NumberOfDimensions',true);
    numdims_edit.Tag='_Number_Of_Dimensions_';
    numdims_edit.RowSpan=[1,1];
    numdims_edit.ColSpan=[1,1];
    numdims_edit.ObjectMethod='NumDimsCallback';
    numdims_edit.MethodArgs={'%dialog','%value'};
    numdims_edit.ArgDataTypes={'handle','mxArray'};



    indexmode_popup=this.initWidget('IndexMode',false);
    indexmode_popup.Tag='_Index_Base_';
    indexmode_popup.RowSpan=[2,2];
    indexmode_popup.ColSpan=[1,1];

    colheaders=this.getDimsPropTableColHeader;


    if(numDims>length(this.DialogData.IndexOptionArray))
        defIdxOpt=this.getDefIdxOpt;
        for i=length(this.DialogData.IndexOptionArray)+1:numDims
            this.DialogData.IndexOptionArray{i}=defIdxOpt;
        end
    end

    defIdxParamAndOutputSize=this.getDefIdxParamAndOutputSize;
    if(numDims>length(this.DialogData.IndexParamArray))
        for i=length(this.DialogData.IndexParamArray)+1:numDims
            this.DialogData.IndexParamArray{i}=defIdxParamAndOutputSize{1};
        end
    end

    if(numDims>length(this.DialogData.OutputSizeArray))
        for i=length(this.DialogData.OutputSizeArray)+1:numDims
            this.DialogData.OutputSizeArray{i}=defIdxParamAndOutputSize{2};
        end
    end

    dimprop_table.Name=' ';
    dimprop_table.Tag='_Dimension_Property_';
    dimprop_table.Type='table';
    dimprop_table.Size=[numDims,length(colheaders)];
    dimprop_table.Grid=1;
    dimprop_table.HeaderVisibility=[1,1];
    dimprop_table.ColHeader=colheaders;
    dimprop_table.Data=this.getDimsPropTableData;
    dimprop_table.RowHeaderWidth=floor(log10(numDims))+2;
    dimprop_table.RowSpan=[3,3];
    dimprop_table.ColSpan=[1,1];
    dimprop_table.ColumnCharacterWidth=[18,8,8];
    dimprop_table.DialogRefresh=1;
    dimprop_table.Editable=1;
    dimprop_table.Enabled=~this.isHierarchySimulating;
    dimprop_table.ValueChangedCallback=@dimsproptable_callback;

    if slfeature('HideSampleTimeWidgetWithDefaultValue')>0

        methods.ObjectMethod='ParamWidgetCallback';
        methods.MethodArgs={'%dialog','SampleTime',false,'%value'};
        methods.ArgDataTypes={'handle','string','bool','mxArray'};
        sampletime_edit=Simulink.SampleTimeWidget.getSampleTimeWidget(...
        '_Sample_Time_',-1,this.DialogData.SampleTime,...
        '','',...
        this,false,0,methods);
    else
        sampletime_edit=this.initWidget('SampleTime',false);
        sampletime_edit.Tag='_Sample_Time_';
    end
    sampletime_edit.RowSpan=[4,4];
    sampletime_edit.ColSpan=[1,1];

end


function dimsproptable_callback(dlg,row,col,value)




    source=dlg.getDialogSource;

    idxoptId=source.getColId('idxopt');
    idxId=source.getColId('idx');
    outsizeId=source.getColId('outsize');

    switch col
    case idxoptId-1
        block=source.getBlock;
        lstIdxOptForParamCache=block.getPropAllowedValues('IdxOptString');
        source.DialogData.IndexOptionArray{row+1}=lstIdxOptForParamCache{value+1};



        defIdxParamAndOutputSize=source.getDefIdxParamAndOutputSize;
        if row<length(block.IndexParamArray)
            source.DialogData.IndexParamArray{row+1}=block.IndexParamArray{row+1};
        else
            source.DialogData.IndexParamArray{row+1}=defIdxParamAndOutputSize{1};
        end
        if row<length(block.OutputSizeArray)
            source.DialogData.OutputSizeArray{row+1}=block.OutputSizeArray{row+1};
        else
            source.DialogData.OutputSizeArray{row+1}=defIdxParamAndOutputSize{2};
        end

        if source.isAllOpt(value)
            dlg.setTableItemValue('_Dimension_Property_',row,idxId-1,source.getIndexStrForAllOpt);
            dlg.setTableItemEnabled('_Dimension_Property_',row,idxId-1,false);
        elseif source.isDialogOpt(value)
            dlg.setTableItemValue('_Dimension_Property_',row,idxId-1,source.DialogData.IndexParamArray{row+1});
            dlg.setTableItemEnabled('_Dimension_Property_',row,idxId-1,true);
        elseif source.isPortOpt(value)
            dlg.setTableItemValue('_Dimension_Property_',row,idxId-1,source.getIndexStrForPortOpt(row+1));
            dlg.setTableItemEnabled('_Dimension_Property_',row,idxId-1,false);
        end

    case idxId-1
        source.DialogData.IndexParamArray{row+1}=value;

    case outsizeId-1
        source.DialogData.OutputSizeArray{row+1}=value;
    end

    dlg.refresh;

end


