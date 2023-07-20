function SetSourceData(this,srcData,rowSelect)








    this.RowSources=hdllinkddg.ClockResetRowSource('/top/clk1','Active Rising Edge Clock','2');

    this.NumRows=size(srcData,1);
    this.NumCols=size(srcData,2);

    for idx=1:this.NumRows
        srcData{idx,2}=hdllinkddg.ClockResetRowSource.convertPropValue('edge',srcData{idx,2});


        this.RowSources(idx)=hdllinkddg.ClockResetRowSource(srcData{idx,:});
    end

    if(this.NumRows>=rowSelect),this.CurrRow=rowSelect;
    elseif(this.NumRows>0),this.CurrRow=1;
    else,this.CurrRow=0;
    end

end
