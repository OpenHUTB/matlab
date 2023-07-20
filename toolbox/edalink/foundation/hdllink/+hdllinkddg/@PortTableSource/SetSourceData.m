function SetSourceData(this,srcData,rowSelect)
























    this.RowSources=hdllinkddg.PortRowSource('/top/sig1',1,'Inherit',-1,0,'Inherit');
    this.NumRows=size(srcData,1);
    this.NumCols=size(srcData,2);

    for idx=1:this.NumRows
        if(srcData{idx,2}==1)
            srcData{idx,3}='Inherit';
        end
        if(srcData{idx,4}==-1)
            srcData{idx,6}='Inherit';
        end

        this.RowSources(idx)=hdllinkddg.PortRowSource(srcData{idx,:});
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

