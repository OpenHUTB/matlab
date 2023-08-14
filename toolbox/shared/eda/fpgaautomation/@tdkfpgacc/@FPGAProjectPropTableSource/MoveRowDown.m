function MoveRowDown(this,dialog)










    if(this.CurrRow==this.NumRows)


        return;
    end

    hRowGoesDown=this.RowSources(this.CurrRow);
    hRowGoesUp=this.RowSources(this.CurrRow+1);

    this.RowSources(this.CurrRow+1)=hRowGoesDown;
    this.RowSources(this.CurrRow)=hRowGoesUp;

    this.RefreshRow(dialog,this.CurrRow);
    this.RefreshRow(dialog,this.CurrRow+1);

    this.CurrRow=this.CurrRow+1;
    trow=this.CurrRow-1;
    dialog.selectTableRow(this.TableName,trow);

    dialog.enableApplyButton(true);
end
