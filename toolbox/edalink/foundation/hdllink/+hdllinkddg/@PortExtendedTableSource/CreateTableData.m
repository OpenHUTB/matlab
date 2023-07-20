function cellD=CreateTableData(this)




    ppCell=this.CreateTableCell('edit','path');
    ioCell=this.CreateTableCell('combobox','ioMode');
    hdlTypeCell=this.CreateTableCell('combobox','hdlType');
    hdlDimsCell=this.CreateTableCell('edit','hdlDims');
    stCell=this.CreateTableCell('edit','sampleTime');
    dtCell=this.CreateTableCell('combobox','datatype');
    sgCell=this.CreateTableCell('combobox','sign');
    flCell=this.CreateTableCell('edit','fracLength');





    ioCell.Entries=hdllinkddg.PortExtendedRowSource.getStrValues('ioMode');
    ioCell.Values=hdllinkddg.PortExtendedRowSource.getIntValues('ioMode');
    hdlTypeCell.Entries=hdllinkddg.PortExtendedRowSource.getStrValues('hdlType');
    hdlTypeCell.Values=hdllinkddg.PortExtendedRowSource.getIntValues('hdlType');
    dtCell.Entries=hdllinkddg.PortExtendedRowSource.getStrValues('datatype');
    dtCell.Values=hdllinkddg.PortExtendedRowSource.getIntValues('datatype');
    sgCell.Entries=hdllinkddg.PortExtendedRowSource.getStrValues('sign');
    sgCell.Values=hdllinkddg.PortExtendedRowSource.getIntValues('sign');


    cellD=cell(this.NumRows,8);

    for idx=1:this.NumRows
        s=this.RowSources(idx);
        [ppCell.Source,ioCell.Source,hdlTypeCell.Source,hdlDimsCell.Source,stCell.Source,sgCell.Source,dtCell.Source,flCell.Source]=deal(s);
        colEns=this.GetColEnables(idx);
        ppCell.Enabled=colEns.path;
        ioCell.Enabled=colEns.ioMode;
        hdlTypeCell.Enabled=colEns.hdlType;
        hdlDimsCell.Enabled=colEns.hdlDims;
        stCell.Enabled=colEns.sampleTime;
        dtCell.Enabled=colEns.datatype;
        sgCell.Enabled=colEns.sign;
        flCell.Enabled=colEns.fracLength;
        cellD(idx,:)={ppCell,ioCell,hdlTypeCell,hdlDimsCell,stCell,dtCell,sgCell,flCell};
    end

end
