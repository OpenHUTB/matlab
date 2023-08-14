function[paramiter_table]=getMaskPrmIterTblWidget(this)






    [tblColHead,tblData]=this.getMaskPrmIterTableData;

    paramiter_table.Name=DAStudio.message('Simulink:dialog:ForEachMaskPrmPartitionColHead');
    paramiter_table.Tag='_Mask_Parameter_Iteration_';
    paramiter_table.Type='table';
    paramiter_table.Size=size(tblData);
    paramiter_table.Grid=1;
    paramiter_table.HeaderVisibility=[0,1];
    paramiter_table.MaximumSize=[800,500];
    paramiter_table.ColHeader=tblColHead;
    paramiter_table.ColumnHeaderHeight=2;
    paramiter_table.Data=tblData;
    paramiter_table.RowSpan=[1,2+min(size(tblData,1),8)];
    paramiter_table.ColSpan=[1,3];
    paramiter_table.DialogRefresh=1;
    paramiter_table.Editable=1;
    paramiter_table.Enabled=~this.isHierarchySimulating;
    paramiter_table.ValueChangedCallback=@paramitertable_callback;

end


function paramitertable_callback(dlg,row,col,value)



    source=dlg.getDialogSource;

    paramiterId=source.getColId('inpiter');
    paramiterdimId=source.getColId('inpiterdim');
    paramiterstepsizeId=source.getColId('inpiterstepsize');

    if evalin('base','exist(''ForEachHideNonPartitionableParams'')')~=0
        row=source.DialogData.MaskParamTblMap{row+1}-1;
    end

    switch col
    case paramiterId-1
        if value
            source.DialogData.SubsysMaskParameterPartition{row+1}='on';
        else
            source.DialogData.SubsysMaskParameterPartition{row+1}='off';
        end

    case paramiterdimId-1
        source.DialogData.SubsysMaskParameterPartitionDimension{row+1}=value;

    case paramiterstepsizeId-1
        source.DialogData.SubsysMaskParameterPartitionWidth{row+1}=value;

    end

    dlg.refresh;

end
