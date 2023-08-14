function ctlNet=elabCRCControl(~,topNet,blockInfo,inRate)






    ufix1Type=pir_ufixpt_t(1,0);



    clen=blockInfo.CRClen;
    dlen=blockInfo.dlen;
    if(clen==dlen)
        cntval=2*clen/dlen-1;
    else
        cntval=clen/dlen-1;
    end
    cntWL=floor(log2(double(cntval)))+1;
    cntType=pir_ufixpt_t(cntWL,0);

    outportnames={'startOut','processMsg','padZero','outputCRC','endOut','validOut','counter'};
    outporttypes=[ufix1Type,ufix1Type,ufix1Type,ufix1Type,ufix1Type,ufix1Type,cntType];

    if(clen>dlen)
        outportnames=[outportnames,{'counter_outputCRC'}];
        outporttypes=[outporttypes,cntType];
    end


    ctlNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','CRCGenControl',...
    'InportNames',{'startIn','endIn','validIn'},...
    'InportTypes',[ufix1Type,ufix1Type,ufix1Type],...
    'InportRates',[inRate,inRate,inRate],...
    'OutportNames',outportnames,...
    'OutportTypes',outporttypes...
    );


    sofin=ctlNet.PirInputSignals(1);
    eofin=ctlNet.PirInputSignals(2);
    validin=ctlNet.PirInputSignals(3);

    sofout=ctlNet.PirOutputSignals(1);
    processMsg=ctlNet.PirOutputSignals(2);
    padZero=ctlNet.PirOutputSignals(3);
    outputCRC=ctlNet.PirOutputSignals(4);
    eofout=ctlNet.PirOutputSignals(5);
    validout=ctlNet.PirOutputSignals(6);
    cntout=ctlNet.PirOutputSignals(7);


    cnt1out=ctlNet.addSignal(pir_ufixpt_t(1,0),'cnt1out');
    cnt1rst=ctlNet.addSignal(ufix1Type,'cnt1rst');
    cnt1enb=ctlNet.addSignal(ufix1Type,'cnt1enb');

    cnt2out=ctlNet.addSignal(cntType,'cnt2out');
    cnt2rst=ctlNet.addSignal(ufix1Type,'cnt2rst');
    cnt3rst=ctlNet.addSignal(ufix1Type,'cnt3rst');
    cnt2enb=ctlNet.addSignal(ufix1Type,'cnt2enb');
    cnt3enb=ctlNet.addSignal(ufix1Type,'cnt3enb');
    cnt3out=ctlNet.addSignal(cntType,'cnt3out');


    ready=ctlNet.addSignal(ufix1Type,'ready');

    tprocessMsg=ctlNet.addSignal(ufix1Type,'tprocessMsg');

    if(clen==dlen)
        pirelab.getLogicComp(ctlNet,tprocessMsg,ready,'not');
    else

        processzero_short=ctlNet.addSignal(ufix1Type,'processzero_short');
        tsysenb_short=ctlNet.addSignal(ufix1Type,'tsysenb_short');
        sysenb_short=ctlNet.addSignal(ufix1Type,'sysenb_short');

        pirelab.getCompareToValueComp(ctlNet,cnt3out,processzero_short,'<',cntval);
        pirelab.getLogicComp(ctlNet,[cnt3enb,processzero_short],tsysenb_short,'and');
        pirelab.getLogicComp(ctlNet,[tprocessMsg,tsysenb_short],sysenb_short,'or');
        pirelab.getLogicComp(ctlNet,sysenb_short,ready,'not');
    end

    pirelab.getLogicComp(ctlNet,[ready,sofin],cnt1enb,'and');


    cnt1Comp=pirelab.getCounterComp(ctlNet,[cnt1rst,cnt1enb],cnt1out,...
    'Count limited',0,1,1,1,0,1,0);
    cnt1Comp.addComment('Counter1: triggered by Start of frame signal');



    deofin=ctlNet.addSignal(eofin.Type,'deofin');
    pirelab.getUnitDelayComp(ctlNet,eofin,deofin,'eofin_delay_register',0);


    ccomp=pirelab.getLogicComp(ctlNet,[tprocessMsg,deofin],cnt2enb,'and');
    ccomp.addComment('Counter 2 enable signal');

    cnt2Comp=pirelab.getCounterComp(ctlNet,[cnt2rst,cnt2enb],cnt2out,...
    'Count limited',0,cntval,1,1,0,1,0);
    cnt2Comp.addComment('Counter2: triggered by End of frame signal');


    ccomp=pirelab.getCompareToValueComp(ctlNet,cnt2out,cnt3enb,'>=',1);
    ccomp.addComment('Counter 3 enable signal');

    if clen==dlen
        cnt3Comp=pirelab.getCounterComp(ctlNet,[cnt3rst,cnt3enb],cnt3out,...
        'Count limited',0,1,cntval,1,0,1,0);
        pirelab.getCompareToValueComp(ctlNet,cnt2out,cnt2rst,'==',cntval);

    else
        cnt3Comp=pirelab.getCounterComp(ctlNet,[cnt2rst,cnt3enb],cnt3out,...
        'Count limited',0,1,cntval,1,0,1,0);
        pirelab.getCompareToValueComp(ctlNet,cnt3out,cnt2rst,'==',cntval);

    end
    cnt3Comp.addComment('Counter3: counts when start to pad zeros');
    pirelab.getCompareToValueComp(ctlNet,cnt3out,cnt3rst,'==',cntval);

    cnt2fstout=ctlNet.addSignal(cntType,'cnt2fstout');
    pirelab.getCompareToValueComp(ctlNet,cnt2out,cnt2fstout,'==',0);
    pirelab.getLogicComp(ctlNet,[cnt2enb,cnt2fstout],cnt1rst,'and');

    if(clen>dlen)
        cnt4out=ctlNet.addSignal(cntType,'cnt4out');
        cnt4rst=ctlNet.addSignal(ufix1Type,'cnt4rst');

        cnt5enb=ctlNet.addSignal(ufix1Type,'cnt5enb');
        cnt5out=ctlNet.addSignal(cntType,'cnt5out');

        cnt4enb=cnt2rst;
        cnt4Comp=pirelab.getCounterComp(ctlNet,[cnt4rst,cnt4enb],cnt4out,...
        'Count limited',0,1,cntval,1,0,1,0);
        cnt4Comp.addComment('Counter4: triggered after processing all the padded zeros');

        ccomp=pirelab.getCompareToValueComp(ctlNet,cnt4out,cnt5enb,'>=',1);
        ccomp.addComment('Counter 5 enable signal');

        cnt5Comp=pirelab.getCounterComp(ctlNet,[cnt4rst,cnt5enb],cnt5out,...
        'Count limited',0,1,cntval,1,0,1,0);
        cnt5Comp.addComment('Counter5: counts when start to output CRC');
        pirelab.getCompareToValueComp(ctlNet,cnt5out,cnt4rst,'==',cntval);
    end




    dtprocessMsg=ctlNet.addSignal(ufix1Type,'dtprocessMsg');
    rdtprocessMsg=ctlNet.addSignal(ufix1Type,'rdtprocessMsg');
    sout=ctlNet.addSignal(ufix1Type,'startout');
    pirelab.getCompareToValueComp(ctlNet,cnt1out,tprocessMsg,'==',1);
    pirelab.getUnitDelayComp(ctlNet,tprocessMsg,dtprocessMsg,'tprocessMsg_delay_register',0);
    pirelab.getLogicComp(ctlNet,dtprocessMsg,rdtprocessMsg,'not');
    pirelab.getLogicComp(ctlNet,[tprocessMsg,rdtprocessMsg],sout,'and');
    ccomp=pirelab.getIntDelayComp(ctlNet,sout,sofout,round(clen/dlen),'sof_delay_register',0);
    ccomp.addComment(' Start of frame output signal');


    ccomp=pirelab.getDTCComp(ctlNet,tprocessMsg,processMsg,'floor','Wrap');
    ccomp.addComment('processMsg');





    if(clen==dlen)
        ccomp=pirelab.getUnitDelayComp(ctlNet,cnt2rst,outputCRC,'outputCRC_register',0);
        teofout=cnt3rst;
        topcrc=cnt3rst;
    else
        ccomp=pirelab.getDTCComp(ctlNet,cnt5enb,outputCRC,'floor','Wrap');
        teofout=cnt4rst;
        topcrc=cnt5enb;
    end
    ccomp.addComment('outputCRC');




    dteofout=ctlNet.addSignal(ufix1Type,'dteofout');
    rdteofout=ctlNet.addSignal(ufix1Type,'rdteofout');
    pirelab.getUnitDelayComp(ctlNet,teofout,dteofout,'eofout_delay_register',0);
    pirelab.getLogicComp(ctlNet,dteofout,rdteofout,'not');
    ccomp=pirelab.getLogicComp(ctlNet,[teofout,rdteofout],eofout,'and');
    ccomp.addComment('End of frame output signal');



    processzero=ctlNet.addSignal(ufix1Type,'processzero');
    tpadZero=ctlNet.addSignal(ufix1Type,'tpadZero');
    if(clen==dlen)
        pirelab.getCompareToValueComp(ctlNet,cnt3out,processzero,'==',0);
    else
        pirelab.getCompareToValueComp(ctlNet,cnt3out,processzero,'<=',cntval);
    end

    pirelab.getLogicComp(ctlNet,[cnt3enb,processzero],tpadZero,'and');
    ccomp=pirelab.getDTCComp(ctlNet,tpadZero,padZero,'floor','Wrap');
    ccomp.addComment('padZero');




    pirelab.getDTCComp(ctlNet,cnt3out,cntout,'floor','Wrap');

    if(clen>dlen)

        cntout_opcrc=ctlNet.PirOutputSignals(8);
        pirelab.getDTCComp(ctlNet,cnt5out,cntout_opcrc,'floor','Wrap');
    end


    tvalidout=ctlNet.addSignal(ufix1Type,'tvalidout');
    dtvalidout=ctlNet.addSignal(ufix1Type,'dvalidout');
    udvalidin=ctlNet.addSignal(ufix1Type,'udvalidin');

    sysenb=ctlNet.addSignal(ufix1Type,'sysenb');
    pirelab.getUnitDelayComp(ctlNet,validin,udvalidin,'validin_unitdelay_register',0);
    pirelab.getLogicComp(ctlNet,[tprocessMsg,tpadZero],sysenb,'or');


    if(clen==dlen)
        pirelab.getLogicComp(ctlNet,[sysenb,udvalidin],tvalidout,'and');

    else
        rcnt3enb=ctlNet.addSignal(ufix1Type,'rcnt3enb');
        clearvalidin=ctlNet.addSignal(ufix1Type,'clearvalidin');
        pirelab.getLogicComp(ctlNet,cnt3enb,rcnt3enb,'not');
        pirelab.getSwitchComp(ctlNet,[rcnt3enb,udvalidin],clearvalidin,cnt3enb,'','~=',0);
        pirelab.getLogicComp(ctlNet,[sysenb,clearvalidin],tvalidout,'and');
    end

    ccomp=pirelab.getIntDelayComp(ctlNet,tvalidout,dtvalidout,round(clen/dlen),'tvalidout_delay_register',0);
    ccomp.addComment('Buffer the validIn signal');
    ccomp=pirelab.getLogicComp(ctlNet,[dtvalidout,topcrc],validout,'or');
    ccomp.addComment('Data valid output');


