function OnTableValueChangeCB(this,dlg,trow,tcol,value)








    srow=trow+1;
    scol=tcol+1;

    if(srow<1||srow>this.NumRows)
        error(message('EDALink:OnTableValueChangeCB:BadIndex'));
    end
    hRow=this.RowSources(srow);


    switch(this.colName{scol})
    case 'name'

        hRow.name=value;
    case 'value'
        hRow.value=value;
    case 'process'
        hRow.process=value;













    end

    this.RefreshRow(dlg,srow);
end
