function[inpiter_table]=getInpKernelTblWidget(this)






    [tblColHead,tblData]=this.getInpKernelTableData;

    inpiter_table.Tag='_Input_neighborhood_spec_';
    inpiter_table.Type='table';
    inpiter_table.Size=size(tblData);
    inpiter_table.Grid=1;
    inpiter_table.HeaderVisibility=[0,1];
    inpiter_table.MinimumSize=[460,0];
    inpiter_table.MaximumSize=[800,500];
    inpiter_table.ColHeader=tblColHead;
    inpiter_table.ColumnCharacterWidth=[7,10];

    inpiter_table.ColumnHeaderHeight=2;
    inpiter_table.Data=tblData;
    inpiter_table.RowSpan=[1,2+min(size(tblData,1),8)];
    inpiter_table.ColSpan=[1,4];
    inpiter_table.DialogRefresh=1;
    inpiter_table.Editable=1;
    inpiter_table.Enabled=~this.isHierarchySimulating;
    inpiter_table.ValueChangedCallback=@inpitertable_callback;

end


function inpitertable_callback(dlg,row,col,value)


    source=dlg.getDialogSource;

    inpiterId=source.getColId('inpIter');

    switch(col+1)
    case inpiterId
        if value
            valueStr="on";
        else
            valueStr="off";
        end
        source.DialogData.StencilTable.InputPartition(row+1)=valueStr;
    end

    dlg.refresh;
end
