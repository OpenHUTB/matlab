function MoveRowUp(this,dialog)










    if(this.CurrRow<=1)
        warning(message('HDLLink:MoveRowUp:BadCurrRow'));
        return;
    end

    hRowGoesUp=this.RowSources(this.CurrRow);
    hRowGoesDown=this.RowSources(this.CurrRow-1);

    this.RowSources(this.CurrRow-1)=hRowGoesUp;
    this.RowSources(this.CurrRow)=hRowGoesDown;

    this.RefreshRow(dialog,this.CurrRow);
    this.RefreshRow(dialog,this.CurrRow-1);

    this.CurrRow=this.CurrRow-1;
    trow=this.CurrRow-1;
    dialog.selectTableRow(this.TableName,trow);

    dialog.enableApplyButton(true);
end
