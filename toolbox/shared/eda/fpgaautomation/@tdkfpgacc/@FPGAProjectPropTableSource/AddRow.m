function AddRow(this,dialog)



    if(this.CurrRow>0&&this.CurrRow<=this.NumRows)
        hCurrRow=this.RowSources(this.CurrRow);


        hNewRow=this.CreateNewRow(hCurrRow);














        hSave=hNewRow;
        for idx=(this.CurrRow+1):(this.NumRows+1)
            if(idx<=this.NumRows)
                hTmp=this.RowSources(idx);
                this.RowSources(idx)=hSave;
                hSave=hTmp;
            else
                this.RowSources(idx)=hSave;
            end
        end

    elseif(this.CurrRow==0)
        this.RowSources=this.CreateNewRow;
    end





    this.CurrRow=this.CurrRow+1;

    this.NumRows=this.NumRows+1;

    dialog.enableApplyButton(true);
    dialog.resetSize(false);

end
