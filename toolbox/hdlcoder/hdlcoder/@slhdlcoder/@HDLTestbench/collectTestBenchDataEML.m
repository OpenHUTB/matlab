function[]=collectTestBenchDataEML(this,dataLog)


    hdldisp(message('hdlcoder:hdldisp:CollectingData'));

    for i=1:length(this.InportSrc)
        loggedData=dataLog.inputData{i};
        datalength=size(loggedData,1);
        datawidth=size(loggedData,2);
        dataIsConstant=isDataConstant(loggedData,datawidth);
        HDLrate=1;
        TStime=1;
        TIinc=1;

        this.InportSrc(i).dataIsComplex=~isreal(loggedData);
        this.InportSrc(i).HDLSampleTime=HDLrate;
        this.InportSrc(i).datalength=datalength;
        this.InportSrc(i).dataIsConstant=dataIsConstant;
        this.InportSrc(i).VectorPortSize=datawidth;
        this.InportSrc(i).timeseries=TStime;
        this.InportSrc(i).SLSampleTime=TIinc;



        if this.isPortComplex(this.InportSrc(i))
            this.InportSrc(i).data=real(loggedData);
            this.InportSrc(i).data_im=imag(loggedData);
        else
            this.InportSrc(i).data=loggedData;
        end
    end

    for i=1:length(this.OutportSnk)
        loggedData=dataLog.outputData{i};
        datalength=size(loggedData,1);
        datawidth=size(loggedData,2);
        dataIsConstant=isDataConstant(loggedData,datawidth);
        HDLrate=1;
        TStime=1;
        TIinc=1;

        this.OutportSnk(i).dataIsComplex=~isreal(loggedData);
        this.OutportSnk(i).HDLSampleTime=HDLrate;
        this.OutportSnk(i).datalength=datalength;
        this.OutportSnk(i).dataIsConstant=dataIsConstant;
        this.OutportSnk(i).VectorPortSize=datawidth;
        this.OutportSnk(i).timeseries=TStime;
        this.OutportSnk(i).SLSampleTime=TIinc;



        if this.isPortComplex(this.OutportSnk(i))
            this.OutportSnk(i).data=real(loggedData);
            this.OutportSnk(i).data_im=imag(loggedData);
        else
            this.OutportSnk(i).data=loggedData;
        end
    end
end


function dataIsConstant=isDataConstant(loggedData,datawidth)
    if datawidth==1
        dataIsConstant=isempty(loggedData)||all(loggedData(:)==loggedData(1));
    else
        dataIsConstant=1;
        for ii=1:datawidth
            dataIsConstant=dataIsConstant&&all(loggedData(:,ii)==loggedData(1,ii));
        end
    end
end
