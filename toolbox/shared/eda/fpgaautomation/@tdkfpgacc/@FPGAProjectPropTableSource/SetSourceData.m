function SetSourceData(this,srcData,rowSelect)










    this.RowSources=tdkfpgacc.FPGAProjectPropRowSource;

    this.NumRows=size(srcData,1);
    this.NumCols=size(srcData,2);

    for idx=1:this.NumRows



        this.RowSources(idx)=tdkfpgacc.FPGAProjectPropRowSource(srcData{idx,:});
    end

    if(this.NumRows>=rowSelect),this.CurrRow=rowSelect;
    elseif(this.NumRows>0),this.CurrRow=1;
    else this.CurrRow=0;
    end

end
