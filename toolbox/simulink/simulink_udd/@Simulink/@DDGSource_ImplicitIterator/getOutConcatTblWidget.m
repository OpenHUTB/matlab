function[outconcat_table]=getOutConcatTblWidget(this)






    [tblColHead,tblData]=this.getOutConcatTableData;

    outconcat_table.Name=DAStudio.message('Simulink:dialog:ForEachOutputConcatColHead');
    outconcat_table.Tag='_Output_Concatenation_';
    outconcat_table.Type='table';
    outconcat_table.Size=size(tblData);
    outconcat_table.Grid=1;
    outconcat_table.HeaderVisibility=[0,1];
    outconcat_table.MaximumSize=[800,500];
    outconcat_table.ColHeader=tblColHead;
    outconcat_table.Data=tblData;
    outconcat_table.ColumnHeaderHeight=2;
    outconcat_table.ColumnCharacterWidth=[10,10];

    outconcat_table.RowSpan=[1,2+min(size(tblData,1),8)];
    outconcat_table.ColSpan=[1,3];
    outconcat_table.DialogRefresh=1;
    outconcat_table.Editable=1;
    outconcat_table.Enabled=~this.isHierarchySimulating;
    outconcat_table.ValueChangedCallback=@outconcattable_callback;

end


function outconcattable_callback(dlg,row,col,value)



    source=dlg.getDialogSource;

    outconcatId=source.getColId('outconcat');
    outconcatdimId=source.getColId('outconcatdim');

    if~isempty(source.DialogData.OutConcatTblMap)
        row=source.DialogData.OutConcatTblMap{row+1}-1;
    end

    switch col
    case outconcatId-1
        if value
            source.DialogData.OutputConcatenation{row+1}='on';
        else
            source.DialogData.OutputConcatenation{row+1}='off';
        end

    case outconcatdimId-1
        source.DialogData.OutputConcatenationDimension{row+1}=value;
    end

    dlg.refresh;

end
