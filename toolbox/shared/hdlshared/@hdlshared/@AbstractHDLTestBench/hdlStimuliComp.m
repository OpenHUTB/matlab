function[hdlbody,hdlsignals]=hdlStimuliComp(this,clkrate,tbenb_dly,srcDone)




    hdlsignals=[];
    hdlbody=[];

    if~isempty(this.InportSrc)
        srcDoneSignals=[];
        for instance=1:length(this.InportSrc)
            hdlbody=[hdlbody,...
            this.insertComment({'Read the data and transmit it to the DUT'}),'\n'];%#ok<*AGROW>
            component=this.InportSrc(instance);
            [compBody,compPorts]=this.hdlsrcinstantiation(component);
            hdlbody=[hdlbody,compBody];
            for i=1:length(compPorts)
                hdlsignals=[hdlsignals,makehdlsignaldecl(compPorts(i))];
            end

            task_rdenb=compPorts(1);
            addr=compPorts(2);
            doneSig=compPorts(3);
            srcDoneSignals=[srcDoneSignals,doneSig];


            hdlbody=[hdlbody,hdlsignalassignment(hdlsignalfindname(component.dataRdEnb),task_rdenb)];
            [stimuliBody,stimuliSignal]=this.hdlreadDataProc(task_rdenb,tbenb_dly,addr,instance,clkrate);
            hdlsignals=[hdlsignals,stimuliSignal];
            hdlbody=[hdlbody,stimuliBody];
        end
        hdlbody=[hdlbody,...
        this.insertComment({'Create done signal for Input data'}),'\n'];
        hdlbody=[hdlbody,this.hdlandsignals(srcDone,srcDoneSignals)];
    end
