function cellD=CreateTableData(this)




    ppCell=this.CreateTableCell('edit','path');
    ioCell=this.CreateTableCell('combobox','ioMode');
    stCell=this.CreateTableCell('edit','sampleTime');
    dtCell=this.CreateTableCell('combobox','datatype');
    sgCell=this.CreateTableCell('combobox','sign');
    flCell=this.CreateTableCell('edit','fracLength');





    ioCell.Entries={'Input';'Output'};
    ioCell.Values=[1,2];
    dtCell.Entries={'Inherit','Fixedpoint','Double','Single','Half'};
    dtCell.Values=[-1,0,1,2,3];
    sgCell.Entries={'Unsigned','Signed'};
    sgCell.Values=[0,1];


    cellD=cell(this.NumRows,6);

    for idx=1:this.NumRows
        s=this.RowSources(idx);
        [ppCell.Source,ioCell.Source,stCell.Source,sgCell.Source,dtCell.Source,flCell.Source]=deal(s);
        colEns=this.GetColEnables(idx);
        ppCell.Enabled=colEns.path;
        ioCell.Enabled=colEns.ioMode;
        stCell.Enabled=colEns.sampleTime;
        dtCell.Enabled=colEns.datatype;
        sgCell.Enabled=colEns.sign;
        flCell.Enabled=colEns.fracLength;
        cellD(idx,:)={ppCell,ioCell,stCell,dtCell,sgCell,flCell};
    end

end
