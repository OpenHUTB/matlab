function tblWidget=makeTable(h,colHeaders,tag,...
    tblData,...
    tblCellType,...
    tblCellEntries,...
    tblCellEnb,...
    rows,cols,enb,vis,tip)




    tblWidget.Type='table';
    tblWidget.Tag=tag;
    actTableData=cell(size(tblData,1),length(colHeaders));
    for i=1:size(tblData,1)
        for j=1:length(colHeaders)
            actTableData{i,j}.Type=tblCellType{i,j};
            if isequal(tblCellType{i,j},'combobox')
                actTableData{i,j}.Entries=tblCellEntries{i,j};
            end
            actTableData{i,j}.Value=tblData{i,j};
            actTableData{i,j}.Enabled=tblCellEnb(i,j);
            actTableData{i,j}.BackgroundColor=[255,255,255];
        end
    end
    tblWidget.Visible=vis;
    tblWidget.Enabled=enb;
    tblWidget.RowSpan=rows;
    tblWidget.ColSpan=cols;
    tblWidget.Size=size(actTableData);
    tblWidget.ColHeader=colHeaders;
    tblWidget.Editable=true;
    tblWidget.Data=actTableData;
    tblWidget.SelectionBehavior='row';
    tblWidget.Grid=true;
    tblWidget.ColumnCharacterWidth=[5,5,5,5,5];
    tblWidget.ColumnHeaderHeight=1;
    tblWidget.HeaderVisibility=ones(1,length(colHeaders));
    tblWidget.ColumnStretchable=[1,1,1,1,1];
    tblWidget.SelectedRow=h.selectedTableRow;
    tblWidget.ValueChangedCallback=@h.tableValueChangedCallback;
    tblWidget.CurrentItemChangedCallback=@h.tableCurrentItemChangedCallback;
    tblWidget.ToolTip=tip;
end
