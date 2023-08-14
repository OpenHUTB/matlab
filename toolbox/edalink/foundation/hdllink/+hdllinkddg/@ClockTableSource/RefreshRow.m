function RefreshRow(this,dlg,row)


    hRow=this.RowSources(row);
    trow=row-1;

    edgeStr={'Falling','Rising'};

    dlg.setTableItemValue(this.TableName,trow,this.colPos.path,hRow.path);
    dlg.setTableItemValue(this.TableName,trow,this.colPos.edge,edgeStr{hRow.edge});
    dlg.setTableItemValue(this.TableName,trow,this.colPos.period,hRow.period);


    colEns=this.GetColEnables(row);

    dlg.setTableItemEnabled(this.TableName,trow,this.colPos.path,colEns.path);
    dlg.setTableItemEnabled(this.TableName,trow,this.colPos.edge,colEns.edge);
    dlg.setTableItemEnabled(this.TableName,trow,this.colPos.period,colEns.period);

    if(this.MaxPathLength~=this.GetMaxPathLength)

        dlg.refresh();
    end
end
