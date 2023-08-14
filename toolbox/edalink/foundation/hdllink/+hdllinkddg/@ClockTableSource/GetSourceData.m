function srcData=GetSourceData(this)








    srcData=cell(this.NumRows,this.NumCols);
    for idx=1:this.NumRows
        rowH=this.RowSources(idx);
        srcData(idx,:)={...
        rowH.path...
        ,rowH.edge...
        ,rowH.period...
        };
    end
end
