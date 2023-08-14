function RefreshRow(this,dlg,row)





    hRow=this.RowSources(row);
    trow=row-1;


    dlg.setTableItemValue(this.TableName,trow,this.colPos.name,hRow.name);
    dlg.setTableItemValue(this.TableName,trow,this.colPos.value,hRow.value);
    dlg.setTableItemValue(this.TableName,trow,this.colPos.process,hRow.process);








    if(this.MaxPathLength~=this.GetMaxPathLength)

        dlg.refresh();
    end

end
