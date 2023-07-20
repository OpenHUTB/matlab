function[hdlbody,hdlsignal,signalidx]=hdlslowclkgenerator(this,inputdatainterval)


    hdlbody=[this.insertComment({'Slow Clock (clkenb)'}),'\n'];
    hdlsignal=[];

    count=inputdatainterval;



    Size=ceil(log2(count));
    [vtype,sltype]=hdlgettypesfromsizes(Size,0,0);
    [~,counter]=hdlnewsignal('counter','block',-1,0,0,vtype,sltype);
    hdlregsignal(counter);
    hdlsignal=[hdlsignal,makehdlsignaldecl(counter)];

    if(this.isCEasDataValid()&&inputdatainterval>this.clkrate)
        phaseV{1}=0;
        if(iscell(this.phaseVector))
            for i=1:length(this.phaseVector)
                phaseV{end+1}=this.phaseVector{i}+inputdatainterval;
            end
        else
            phaseV{2}=this.phaseVector;
        end
    else
        phaseV=this.phaseVector;
    end
    [tmpbody,signalidx]=hdlcounter(counter,count,'slow_clock_enable',1,1,...
    phaseV,-1);
    hdlbody=[hdlbody,tmpbody];
    for m=1:length(signalidx)
        hdlsignal=[hdlsignal,makehdlsignaldecl(signalidx(m))];%#ok<*AGROW>
    end



    sampleTimeVector=[];
    for i=1:length(this.InportSrc)
        sampleTimeVector=[sampleTimeVector,this.inportSrc(i).HDLSampleTime];
    end

    uniqueSampleTime=this.tbRates;
    for i=1:length(this.InportSrc)

        idx=getIdxFromUniqueSampleTime(sampleTimeVector(i),uniqueSampleTime);

        this.InportSrc(i).ClockEnableSigIdx=signalidx(idx);
        this.InportSrc(i).ClockEnable=hdlsignalname(signalidx(idx));
        this.InportSrc(i).dataRdEnb=['rdEnb_',hdlsignalname(signalidx(idx))];
    end



    function idx=getIdxFromUniqueSampleTime(SampleTime,SampleTimeVector)
        idx=1;
        for i=1:length(SampleTimeVector)
            if SampleTimeVector(i)==SampleTime
                idx=i;
                break;
            end
        end



