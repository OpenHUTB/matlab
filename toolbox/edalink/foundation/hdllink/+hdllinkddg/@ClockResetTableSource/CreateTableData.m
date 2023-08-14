function cellD=CreateTableData(this)


    pathCell=this.CreateTableCell('edit','path');
    edgeCell=this.CreateTableCell('combobox','edge');
    periodCell=this.CreateTableCell('edit','period');


    edgeCell.Entries=hdllinkddg.ClockResetRowSource.getStrValues('edge');
    edgeCell.Values=hdllinkddg.ClockResetRowSource.getIntValues('edge');


    cellD=cell(this.NumRows,3);

    for idx=1:this.NumRows
        s=this.RowSources(idx);
        [pathCell.Source,edgeCell.Source,periodCell.Source]=deal(s);

        colEns=this.GetColEnables(idx);
        pathCell.Enabled=colEns.path;
        edgeCell.Enabled=colEns.edge;
        periodCell.Enabled=colEns.period;

        cellD(idx,:)={pathCell,edgeCell,periodCell};
    end

end
