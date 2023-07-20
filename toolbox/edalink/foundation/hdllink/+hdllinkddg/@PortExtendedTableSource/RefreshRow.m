function RefreshRow(this,dlg,row)





    hRow=this.RowSources(row);
    trow=row-1;

    ioModeStr=hdllinkddg.PortExtendedRowSource.convertPropValue('ioMode',hRow.ioMode);
    hdlTypeStr=hdllinkddg.PortExtendedRowSource.convertPropValue('hdlType',hRow.hdlType);
    datatypeStr=hdllinkddg.PortExtendedRowSource.convertPropValue('datatype',hRow.datatype);
    signStr=hdllinkddg.PortExtendedRowSource.convertPropValue('sign',hRow.sign);

    dlg.setTableItemValue(this.TableName,trow,this.colPos.path,hRow.path);
    dlg.setTableItemValue(this.TableName,trow,this.colPos.ioMode,ioModeStr);
    dlg.setTableItemValue(this.TableName,trow,this.colPos.hdlType,hdlTypeStr);
    dlg.setTableItemValue(this.TableName,trow,this.colPos.hdlDims,hRow.hdlDims);
    dlg.setTableItemValue(this.TableName,trow,this.colPos.sampleTime,hRow.sampleTime);
    dlg.setTableItemValue(this.TableName,trow,this.colPos.datatype,datatypeStr);
    dlg.setTableItemValue(this.TableName,trow,this.colPos.sign,signStr);
    dlg.setTableItemValue(this.TableName,trow,this.colPos.fracLength,hRow.fracLength);


    colEns=this.GetColEnables(row);
    dlg.setTableItemEnabled(this.TableName,trow,this.colPos.path,colEns.path);
    dlg.setTableItemEnabled(this.TableName,trow,this.colPos.ioMode,colEns.ioMode);
    dlg.setTableItemEnabled(this.TableName,trow,this.colPos.hdlType,colEns.hdlType);
    dlg.setTableItemEnabled(this.TableName,trow,this.colPos.hdlDims,colEns.hdlDims);
    dlg.setTableItemEnabled(this.TableName,trow,this.colPos.sampleTime,colEns.sampleTime);
    dlg.setTableItemEnabled(this.TableName,trow,this.colPos.datatype,colEns.datatype);
    dlg.setTableItemEnabled(this.TableName,trow,this.colPos.sign,colEns.sign);
    dlg.setTableItemEnabled(this.TableName,trow,this.colPos.fracLength,colEns.fracLength);

    if(this.MaxPathLength~=this.GetMaxPathLength)

        dlg.refresh();
    end

end
