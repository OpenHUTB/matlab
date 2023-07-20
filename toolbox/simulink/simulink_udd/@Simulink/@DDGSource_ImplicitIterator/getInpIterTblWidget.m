function[inpiter_table]=getInpIterTblWidget(this)






    [tblColHead,tblData]=this.getInpIterTableData;

    inpiter_table.Name=DAStudio.message('Simulink:dialog:ForEachInputPartitionColHead');
    inpiter_table.Tag='_Input_Iteration_';
    inpiter_table.Type='table';
    inpiter_table.Size=size(tblData);
    inpiter_table.Grid=1;
    inpiter_table.HeaderVisibility=[0,1];
    inpiter_table.MinimumSize=[460,0];
    inpiter_table.MaximumSize=[800,500];
    inpiter_table.ColHeader=tblColHead;
    if slfeature('ForEachSubsystemInputOverlapping')==0
        inpiter_table.ColumnCharacterWidth=[7,7,7,7];
    else
        inpiter_table.ColumnCharacterWidth=[7,7,7,7,7];
    end
    inpiter_table.ColumnHeaderHeight=2;
    inpiter_table.Data=tblData;

    inpiter_table.RowSpan=[1,2+min(size(tblData,1),8)];
    inpiter_table.ColSpan=[1,3];
    inpiter_table.DialogRefresh=1;
    inpiter_table.Editable=1;
    inpiter_table.Enabled=~this.isHierarchySimulating;
    inpiter_table.ValueChangedCallback=@inpitertable_callback;

end


function inpitertable_callback(dlg,row,col,value)



    source=dlg.getDialogSource;

    inpiterId=source.getColId('inpiter');
    inpiterdimId=source.getColId('inpiterdim');
    inpiterstepsizeId=source.getColId('inpiterstepsize');
    inpiterstepoffsetId=source.getColId('inpiterstepoffset');

    if~isempty(source.DialogData.InpIterTblMap)
        row=source.DialogData.InpIterTblMap{row+1}-1;
    end

    switch col
    case inpiterId-1
        if value
            source.DialogData.InputPartition{row+1}='on';
        else
            source.DialogData.InputPartition{row+1}='off';
        end

    case inpiterdimId-1
        source.DialogData.InputPartitionDimension{row+1}=value;

    case inpiterstepsizeId-1
        source.DialogData.InputPartitionWidth{row+1}=value;

    case inpiterstepoffsetId-1
        source.DialogData.InputPartitionOffset{row+1}=value;
    end

    dlg.refresh;

end
