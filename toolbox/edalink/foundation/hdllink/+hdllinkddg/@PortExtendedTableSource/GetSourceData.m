function srcData=GetSourceData(this)










    srcData=cell(this.NumRows,this.NumCols);

    for idx=1:this.NumRows
        rowH=this.RowSources(idx);

        srcData(idx,:)={...
        rowH.path...
        ,rowH.ioMode...
        ,rowH.hdlType...
        ,rowH.hdlDims...
        ,rowH.sampleTime...
        ,rowH.datatype...
        ,rowH.sign...
        ,rowH.fracLength...
        };

        if(strcmpi(srcData{idx,this.colPos.sampleTime+1},'Inherit'))
            srcData{idx,this.colPos.sampleTime+1}='-1';
        end
        if(strcmpi(srcData{idx,this.colPos.fracLength+1},'Inherit'))
            srcData{idx,this.colPos.fracLength+1}='0';
        end
    end
end


