function RefreshRow(this,dlg,row)





    hRow=this.RowSources(row);
    trow=row-1;

    ioModeStr={'Input','Output'};
    datatypeStr={'Inherit','Fixedpoint','Double','Single','Half'};
    signStr={'Unsigned','Signed'};
    dlg.setTableItemValue(this.TableName,trow,this.colPos.path,hRow.path);
    dlg.setTableItemValue(this.TableName,trow,this.colPos.ioMode,ioModeStr{hRow.ioMode});
    dlg.setTableItemValue(this.TableName,trow,this.colPos.sampleTime,hRow.sampleTime);
    dlg.setTableItemValue(this.TableName,trow,this.colPos.datatype,datatypeStr{hRow.datatype+2});
    dlg.setTableItemValue(this.TableName,trow,this.colPos.sign,signStr{hRow.sign+1});
    dlg.setTableItemValue(this.TableName,trow,this.colPos.fracLength,hRow.fracLength);


    colEns=this.GetColEnables(row);
    dlg.setTableItemEnabled(this.TableName,trow,this.colPos.path,colEns.path);
    dlg.setTableItemEnabled(this.TableName,trow,this.colPos.ioMode,colEns.path);
    dlg.setTableItemEnabled(this.TableName,trow,this.colPos.sampleTime,colEns.sampleTime);
    dlg.setTableItemEnabled(this.TableName,trow,this.colPos.datatype,colEns.datatype);
    dlg.setTableItemEnabled(this.TableName,trow,this.colPos.sign,colEns.sign);
    dlg.setTableItemEnabled(this.TableName,trow,this.colPos.fracLength,colEns.fracLength);

    if(this.MaxPathLength~=this.GetMaxPathLength)

        dlg.refresh();
    end

end
