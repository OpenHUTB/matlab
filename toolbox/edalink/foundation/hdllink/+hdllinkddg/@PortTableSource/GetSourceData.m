function srcData=GetSourceData(this)










    srcData=cell(this.NumRows,this.NumCols);

    for idx=1:this.NumRows
        rowH=this.RowSources(idx);

        srcData(idx,:)={...
        rowH.path...
        ,rowH.ioMode...
        ,rowH.sampleTime...
        ,rowH.datatype...
        ,rowH.sign...
        ,rowH.fracLength...
        };

        if(strcmpi(srcData{idx,3},'Inherit'))
            srcData{idx,3}='-1';
        end
        if(strcmpi(srcData{idx,6},'Inherit'))
            srcData{idx,6}='0';
        end
    end
end


