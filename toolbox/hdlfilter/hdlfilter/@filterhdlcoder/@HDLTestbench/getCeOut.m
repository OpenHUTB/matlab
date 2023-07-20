function[hdlbody,hdlsignals,ce_out]=getCeOut(this,snk,clkenb)











    bdt=hdlgetparameter('base_data_type');

    hdlsignals=[];
    hdlbody=[];

    enbSignal=snk.ClockEnable.Name;

    if this.needCeOut


        latency=this.latency;
        initialLatency=this.initialLatency;


        [~,delayLine_out]=hdlnewsignal('delayLine_out','block',-1,0,0,bdt,'boolean');
        [~,ce_out]=hdlnewsignal('expected_ce_out','block',-1,0,0,bdt,'boolean');
        setCeOut(this,snk,ce_out);
        if initialLatency==1
            hdlregsignal(delayLine_out);
        end
        hdlsignals=[hdlsignals,makehdlsignaldecl(delayLine_out)];%#ok
        hdlsignals=[hdlsignals,makehdlsignaldecl(ce_out)];%#ok


        if this.isTbSingleRate
            expected_phase=hdlsignalfindname(this.InportSrc(1).dataRdEnb);
        elseif latency==1
            expected_phase=clkenb;
        else
            max_cnt=latency;
            cnt_sz=ceil(log2(max_cnt));
            [cntvtype,cntsltype]=hdlgettypesfromsizes(cnt_sz,0,0);
            [~,expected_phase]=hdlnewsignal('expected_phase','block',-1,0,0,cntvtype,cntsltype);
            hdlregsignal(expected_phase);
            hdlsignals=[hdlsignals,makehdlsignaldecl(expected_phase)];%#ok

            [cntBody,cntSignals]=hdlcounter(expected_phase,latency,'ce_out_process',1,(latency-1),0);
            hdlbody=[hdlbody,cntBody];
            hdlsignals=[hdlsignals,makehdlsignaldecl(cntSignals)];
            expected_phase=cntSignals;
        end


        [tmpbody,tmpsignal]=hdlintdelay(expected_phase,delayLine_out,'ceout_delayLine',initialLatency,0);
        hdlsignals=[hdlsignals,tmpsignal];%#ok
        hdlbody=[hdlbody,tmpbody];%#ok
        hdlbody=[hdlbody,hdlbitop([delayLine_out,clkenb],ce_out,'AND')];%#ok


    else
        ce_out=hdlsignalfindname(enbSignal);
    end


    function setCeOut(this,snk,ce_out)
        for i=1:length(this.OutportSnk)
            if strcmpi(this.OutportSnk(i).HDLPortName{1},snk.HDLPortName{1})
                this.OutportSnk(i).ClockEnable.Name=hdlsignalname(ce_out);
                break;
            end
        end
