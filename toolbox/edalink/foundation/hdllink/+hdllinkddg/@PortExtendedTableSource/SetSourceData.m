function SetSourceData(this,srcData,rowSelect)
























    this.RowSources=hdllinkddg.PortExtendedRowSource('/top/sig1',1,12,'[1]','Inherit',-1,0,'Inherit');
    this.NumRows=size(srcData,1);
    this.NumCols=size(srcData,2);



    for idx=1:this.NumRows
        if(srcData{idx,this.colPos.ioMode+1}==1)
            srcData{idx,this.colPos.sampleTime+1}='Inherit';
        end
        if(srcData{idx,this.colPos.datatype+1}==-1)
            srcData{idx,this.colPos.fracLength+1}='Inherit';
        end

        this.RowSources(idx)=hdllinkddg.PortExtendedRowSource(srcData{idx,:});
    end

    if(this.NumRows>=rowSelect)
        this.CurrRow=rowSelect;
    elseif(this.NumRows>0)
        this.CurrRow=1;
    else
        this.CurrRow=0;
    end

    this.SetLastUninheritedValues;

end

