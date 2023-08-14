function OnTableValueChangeCB(this,dlg,trow,tcol,value)








    srow=trow+1;
    scol=tcol+1;

    if(srow<1||srow>this.NumRows)
        error(message('HDLLink:OnTableValueChangeCB:BadIndex'));
    end
    hRow=this.RowSources(srow);

    switch(this.colName{scol})
    case 'edge'
        hRow.edge=value;
    case 'path'
        hRow.path=value;
    case 'period'
        try






            hRow.(this.colName{scol})=value;
        catch
            warning(message('HDLLink:OnTableValueChangeCB:ValueNotNumber'));
        end
    end
    this.RefreshRow(dlg,srow);
end
