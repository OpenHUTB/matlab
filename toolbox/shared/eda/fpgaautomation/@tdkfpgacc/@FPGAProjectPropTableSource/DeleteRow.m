function DeleteRow(this,dialog)



    hCurrRow=this.RowSources(this.CurrRow);

    for idx=(this.CurrRow):(this.NumRows)
        if(idx<this.NumRows)
            this.RowSources(idx)=this.RowSources(idx+1);
        else
            this.RowSources(idx)=[];
        end
    end



    this.NumRows=this.NumRows-1;
    if(this.CurrRow>this.NumRows)
        this.CurrRow=this.NumRows;
    end


    dialog.enableApplyButton(true);
    dialog.resetSize(false);


end
