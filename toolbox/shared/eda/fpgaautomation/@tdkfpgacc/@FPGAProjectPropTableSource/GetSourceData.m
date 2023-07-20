function srcData=GetSourceData(this)











    srcData=cell(this.NumRows,this.NumCols);

    for idx=1:this.NumRows
        rowH=this.RowSources(idx);

        srcData(idx,:)={...
        rowH.name...
        ,rowH.value...
        ,rowH.process...
        };
    end

end
