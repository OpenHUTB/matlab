function cellD=CreateTableData(this)




    nameCell=this.CreateTableCell('edit','name');
    valueCell=this.CreateTableCell('edit','value');
    processCell=this.CreateTableCell('edit','process');





    cellD=cell(this.NumRows,3);

    for idx=1:this.NumRows
        s=this.RowSources(idx);
        [nameCell.Source,valueCell.Source,processCell.Source]=deal(s);






        cellD(idx,:)={nameCell,valueCell,processCell};
    end

end
