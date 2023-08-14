function onSigTableWidgetChange(this,dialog,row,col,value)

    numIns=this.params.getNumInputPorts;

    if(row<=(numIns-1))
        curPort=this.params.inputPorts(row+1);
    else
        curPort=this.params.outputPorts(row-numIns+1);
    end

    try
        switch(col+1)
        case 4
            origVal=curPort.sampleTime.getStr();
            curPort.sampleTime=eda.internal.filhost.SampleTimeT(value);
        case 5
            origVal=curPort.dtypeSpec.getUnidtStr();
            curPort.dtypeSpec=eda.internal.filhost.DTypeSpecT(value);
        end

    catch ME

        dialog.setTableItemValue('ptTable',row,col,origVal);
        rethrow(ME);
    end



    if(row<=(numIns-1))
        this.params.inputPorts(row+1)=curPort;
    else
        this.params.outputPorts(row-numIns+1)=curPort;
    end

end