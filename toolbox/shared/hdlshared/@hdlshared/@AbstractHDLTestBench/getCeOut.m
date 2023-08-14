function[hdlbody,hdlsignals,ce_out]=getCeOut(this,snk,clkenb)










    bdt=hdlgetparameter('base_data_type');



    initialLatency=this.initialLatency;


    hdlsignals=[];
    hdlbody=[];

    enbSignal=snk.ClockEnable.Name;
    if isempty(hdlsignalfindname(enbSignal))
        [~,delayLine_out]=hdlnewsignal('delayLine_out','block',-1,0,0,bdt,'boolean');
        if initialLatency==1
            hdlregsignal(delayLine_out);
        end
        [~,ce_out]=hdlnewsignal('ce_out','block',-1,0,0,bdt,'boolean');
        hdlsignals=[hdlsignals,makehdlsignaldecl(delayLine_out)];
        hdlsignals=[hdlsignals,makehdlsignaldecl(ce_out)];
        setCeOut(this,snk,ce_out);
        if~isempty(this.InportSrc)
            rdenb=hdlsignalfindname(this.InportSrc(1).dataRdEnb);
        else
            rdenb=hdlsignalfindname(this.ClockEnableName);
        end
        [tmpbody,tmpsignal]=hdlintdelay(rdenb,delayLine_out,'ceout_delayLine',initialLatency,0);
        hdlsignals=[hdlsignals,tmpsignal];
        hdlbody=[hdlbody,tmpbody];
        hdlbody=[hdlbody,hdlbitop([delayLine_out,clkenb],ce_out,'AND')];
        snk.ClockEnable.Name=hdlsignalname(ce_out);

    else
        ce_out=hdlsignalfindname(enbSignal);
    end

    function setCeOut(this,snk,ce_out)
        for i=1:length(this.OutportSnk)
            if strcmpi(this.OutportSnk(i).HDLPortName,snk.HDLPortName)
                this.OutportSnk(i).ClockEnable.Name=hdlsignalname(ce_out);
                break;
            end
        end


