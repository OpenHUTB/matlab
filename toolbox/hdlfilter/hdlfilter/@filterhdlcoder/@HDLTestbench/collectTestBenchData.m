function collectTestBenchData(this,indata,outdata)






    [inputHDLSampleTime,outputHDLSampleTime]=getTBHDLSampleTime(this.HDLFilterComp);
    for n=1:length(this.InportSrc)
        if this.isInputPortComplex
            this.InportSrc(n).data=real(indata{n})';
            this.InportSrc(n).data_im=imag(indata{n})';
        else
            this.InportSrc(n).data=(indata{n})';
        end
        this.InportSrc(n).HDLSampleTime=inputHDLSampleTime;

        if n==1
            if length(indata{n})==1

                this.InportSrc(n).datalength=length(indata{n});
                this.InportSrc(n).dataIsConstant=1;
            else
                this.InportSrc(n).datalength=length(indata{n});
                this.InportSrc(n).dataIsConstant=0;
            end
            indatalen=length(indata{n});
        elseif strcmp(this.InportSrc(n).HDLPortName,hdlgetparameter('filter_fracdelay_name'))



            if length(indata{n})==1
                this.InportSrc(n).datalength=indatalen;
                this.InportSrc(n).dataIsConstant=1;
            else
                this.InportSrc(n).datalength=length(indata{n});
                this.InportSrc(n).dataIsConstant=0;
            end
        else
            this.InportSrc(n).datalength=length(indata{n});
            this.InportSrc(n).dataIsConstant=0;
        end
        this.InportSrc(n).VectorPortSize=1;
        this.InportSrc(n).timeseries=[1:length(indata{n})]';
        this.InportSrc(n).SLSampleTime=1;
        signalname=this.InportSrc(n).HDLPortName{1};
        if iscell(signalname)
            signalname=signalname{1};
        end
        this.InportSrc(n).PortVType=hdlsignalvtype(hdlsignalfindname(signalname));
        this.InportSrc(n).PortSLType=hdlsignalsltype(hdlsignalfindname(signalname));
    end

    if this.isOutputPortComplex
        this.OutportSnk.data=(real(outdata))';
        this.OutportSnk.data_im=(imag(outdata))';
    else
        this.OutportSnk.data=(outdata)';
    end

    this.OutportSnk.HDLSampleTime=outputHDLSampleTime;
    this.OutportSnk.datalength=length(outdata);
    if length(outdata)==1
        this.OutportSnk.dataIsConstant=1;
    else
        this.OutportSnk.dataIsConstant=0;
    end
    this.OutportSnk.VectorPortSize=1;
    this.OutportSnk.timeseries=[1:length(outdata)]';
    this.OutportSnk.SLSampleTime=1;
    signalname=this.OutportSnk.HDLPortName{1};
    if iscell(signalname)
        signalname=signalname{1};
    end
    this.OutportSnk.PortVType=hdlsignalvtype(hdlsignalfindname(signalname));
    this.OutportSnk.PortSLType=hdlsignalsltype(hdlsignalfindname(signalname));
    opsizes=hdlsignalsizes(hdlsignalfindname(signalname));
    this.OutportSnk.dataWidth=opsizes(1);
    if strcmpi(this.HDLFilterComp.Implementation,'localmultirate')&&...
        (strcmpi(this.HDLFilterComp.getCascadeType,'singlerate')||...
        strcmpi(this.HDLFilterComp.getCascadeType,'interpolating'))
        this.OutportSnk.ClockEnable.Name=hdlgetparameter('clockenableoutputvalidname');
    else
        this.OutportSnk.ClockEnable.Name=hdlgetparameter('clockenableoutputname');
    end




    if~strcmpi(hdlgetparameter('filter_coefficient_source'),'internal')&&...
        (strcmpi(this.HDLFilterComp.Implementation,'serial')||strcmpi(this.HDLFilterComp.Implementation,'serialcascade'))
        ffact=hdlgetparameter('foldingfactor');
        phaseVector=cell(1,length(this.InportSrc));
        for n=1:length(this.InportSrc)
            if strcmpi(this.InportSrc(n).HDLPortName,hdlgetparameter('filter_input_name'))
                this.InportSrc(n).HDLSampleTime=ffact;
                phaseVector{n}=1;

            else
                this.InportSrc(n).HDLSampleTime=1;
                phaseVector{n}=0:ffact-1;
            end
        end
        this.phaseVector=phaseVector;
        this.tbRates=[ffact,1];
    end



    if hdlgetparameter('RateChangePort')
        tbinprate=resolveTBRateStimulus(this.HDLFilterComp);
        for n=1:length(this.InportSrc)
            if strcmp(this.InportSrc(n).HDLPortName,'rate')
                this.InportSrc(n).datalength=length(indata{n});
                this.InportSrc(n).dataIsConstant=1;
                this.InportSrc(n).HDLSampleTime=tbinprate;
                phaseVector{n}=0:tbinprate-1;
            elseif strcmp(this.InportSrc(n).HDLPortName,'load_rate')
                this.InportSrc(n).datalength=length(indata{n});
                this.InportSrc(n).dataIsConstant=0;
                this.InportSrc(n).HDLSampleTime=1;
                phaseVector{n}=0:tbinprate-1;
            else
                this.InportSrc(n).datalength=length(indata{n});
                this.InportSrc(n).dataIsConstant=0;
                this.InportSrc(n).HDLSampleTime=tbinprate;
                phaseVector{n}=1;
            end
        end
        this.phaseVector=phaseVector;
        this.tbRates=[tbinprate,1];
    end