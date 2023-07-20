function[hdlbody,hdlsignals,check_enb]=hdlDelayChecking(this,instance,rdenbPort)


    hdlbody=[];
    hdlsignals=[];
    check_enb='';

    if(hdlgetparameter('IgnoreDataChecking')>0)
        max_cnt=hdlgetparameter('IgnoreDataChecking');
        cnt_sz=ceil(log2(max_cnt));
        [cntvtype,cntsltype]=hdlgettypesfromsizes(cnt_sz,0,0);

        bdt=hdlgetparameter('base_data_type');
        [~,check_enb]=hdlnewsignal([this.OutportSnk(instance).loggingPortName,'_chkenb'],'block',-1,0,0,bdt,'boolean');
        hdlregsignal(check_enb);
        hdlsignals=[hdlsignals,makehdlsignaldecl(check_enb)];

        [~,check_cnt]=hdlnewsignal([this.OutportSnk(instance).loggingPortName,'_chkcnt'],'block',-1,0,0,cntvtype,cntsltype);
        hdlregsignal(check_cnt);
        hdlsignals=[hdlsignals,makehdlsignaldecl(check_cnt)];
        hdlbody=[hdlbody,...
        this.insertComment({' Checker: Delay Checking.'}),'\n'];
        hdlbody=[hdlbody,this.hdlcheckerdelay(instance,check_enb,check_cnt,cnt_sz,max_cnt,rdenbPort)];
    end
