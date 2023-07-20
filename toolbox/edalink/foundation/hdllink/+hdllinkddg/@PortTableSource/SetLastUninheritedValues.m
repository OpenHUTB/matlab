function SetLastUninheritedValues(this)
    if(this.CurrRow==0),return;end

    hRow=this.RowSources(this.CurrRow);
    this.LastUninheritedValues=this.CreateNewRow(hRow);

    if(hRow.datatype==-1)

        this.LastUninheritedValues.fracLength='0';
    else
        this.LastUninheritedValues.fracLength=hRow.fracLength;
    end

    if(hRow.ioMode==1)

        this.LastUninheritedValues.sampleTime='1';
    else
        this.LastUninheritedValues.sampleTime=hRow.sampleTime;
    end
end
