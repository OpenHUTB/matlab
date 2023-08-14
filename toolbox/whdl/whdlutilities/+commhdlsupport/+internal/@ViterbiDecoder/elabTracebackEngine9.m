function tbNet=elabTracebackEngine9(~,topNet,blockInfo,dataRate)



    idxWL=blockInfo.idxWL;
    cntWL=blockInfo.cntWL;
    ramWL=blockInfo.ramWL;

    ramType=pir_ufixpt_t(ramWL,0);
    ufix1Type=pir_ufixpt_t(1,0);
    ufix2Type=pir_ufixpt_t(2,0);
    cntType=pir_ufixpt_t(cntWL,0);
    idxType=pir_ufixpt_t(idxWL,0);
    slicedType=pir_ufixpt_t(idxWL-1,0);
    inType=ramType;

    if(blockInfo.ResetPort)
        inportnames={'tbdataL','tbdataH','decdataH','decdataH',...
        'minindx','enb','rst'};
        inporttypes=[ramType,ramType,ramType,ramType,...
        idxType,ufix1Type,ufix1Type];
        inportrates=[dataRate,dataRate,dataRate,dataRate,...
        dataRate,dataRate,dataRate];
    else
        inportnames={'tbdataL','tbdataH','decdataH','decdataH',...
        'minindx','enb'};
        inporttypes=[ramType,ramType,ramType,ramType,...
        idxType,ufix1Type];
        inportrates=[dataRate,dataRate,dataRate,dataRate,...
        dataRate,dataRate];
    end


    tbNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','TracebackEngine',...
    'InportNames',inportnames,...
    'InportTypes',inporttypes,...
    'InportRates',inportrates,...
    'OutportNames',{'decoded','valid'},...
    'OutportTypes',[ufix1Type,ufix1Type]...
    );



    tbdataL=tbNet.PirInputSignals(1);
    tbdataH=tbNet.PirInputSignals(2);
    decdataL=tbNet.PirInputSignals(3);
    decdataH=tbNet.PirInputSignals(4);
    minindx=tbNet.PirInputSignals(5);
    enb=tbNet.PirInputSignals(6);
    if(blockInfo.ResetPort)
        rst=tbNet.PirInputSignals(7);
    end

    decoded=tbNet.PirOutputSignals(1);
    valid=tbNet.PirOutputSignals(2);



    cnttbd=tbNet.addSignal(cntType,'cntTbd');
    toggle=tbNet.addSignal(ufix1Type,'toggle');
    decodedreg=tbNet.addSignal(ufix1Type,'decodedreg');

    tbsel=tbNet.addSignal(idxType,'tbsel');
    tbindex=tbNet.addSignal(idxType,'tbindex');
    tbindexreg=tbNet.addSignal(idxType,'tbindexreg');

    decsel=tbNet.addSignal(idxType,'decsel');
    decindex=tbNet.addSignal(idxType,'decindex');
    decindexreg=tbNet.addSignal(idxType,'decindexreg');

    slicedregtbsel=tbNet.addSignal(slicedType,'slicedtbsel');
    slicedregdecsel=tbNet.addSignal(slicedType,'slicedregdecsel');


    if(blockInfo.ResetPort)
        cntcomp1=pirelab.getCounterComp(tbNet,[rst,enb],cnttbd,'Count limited',...
        0,1,blockInfo.tbd-1,...
        true,false,true,false,...
        'counter');
    else
        cntcomp1=pirelab.getCounterComp(tbNet,enb,cnttbd,'Count limited',...
        0,1,blockInfo.tbd-1,...
        false,false,true,false,...
        'counter');
    end
    cntcomp1.addComment('counts up to BankDepth tbd');
    pirelab.getCompareToValueComp(tbNet,cnttbd,toggle,'==',blockInfo.tbd-1);
    tbNet.addComment('Variable bit selection for traceback data');

    for ii=idxWL:-1:1
        if ii==idxWL

            bitsel=tbNet.addSignal(ufix1Type,['tbbitsel',num2str(ii-1)]);
            bitselout=tbNet.addSignal(inType,'tbdata_128');
            sComptb1=pirelab.getBitSliceComp(tbNet,tbindexreg,bitsel,ii-1,ii-1);
            sComptb1.addComment(['Variable Bit Selection',num2str(ii-1)]);

            sComptb2=pirelab.getSwitchComp(tbNet,[tbdataL,tbdataH],bitselout,bitsel,'','==',0);
            sComptb2.addComment('select low and high');
            sliced_tb_data=bitselout;
        else
            in1=sliced_tb_data;
            sliced_tb_data=elabVarBitSel(tbNet,in1,tbindexreg,ii-1,'tb');
        end
    end

    tbbitout=sliced_tb_data;
    tbNet.addComment('Variable bit selection for decode data');

    for ii=idxWL:-1:1
        if ii==idxWL

            bitsel=tbNet.addSignal(ufix1Type,['decbitsel',num2str(ii-1)]);
            bitselout=tbNet.addSignal(inType,'decdata_128');
            sCompdec1=pirelab.getBitSliceComp(tbNet,decindexreg,bitsel,ii-1,ii-1);
            sCompdec1.addComment(['Variable Bit Selection',num2str(ii-1)]);

            sCompdec2=pirelab.getSwitchComp(tbNet,[decdataL,decdataH],bitselout,bitsel,'','==',0);
            sCompdec2.addComment('select low and high');
            sliced_dec_data=bitselout;
        else
            in1=sliced_dec_data;
            sliced_dec_data=elabVarBitSel(tbNet,in1,decindexreg,ii-1,'dec');
        end
    end
    decbitout=sliced_dec_data;


    bscomp1=pirelab.getBitSliceComp(tbNet,tbindexreg,slicedregtbsel,(idxWL-2),0);
    bscomp1.addComment('Find previous state in traceback phase');
    bscomp2=pirelab.getBitSliceComp(tbNet,decindexreg,slicedregdecsel,(idxWL-2),0);
    bscomp2.addComment('Find previous state in decode phase');
    pirelab.getBitConcatComp(tbNet,[slicedregtbsel,tbbitout],tbindex);
    pirelab.getBitConcatComp(tbNet,[slicedregdecsel,decbitout],decindex);


    scomp3=pirelab.getSwitchComp(tbNet,[minindx,tbindex],tbsel,toggle,'','~=',0);
    scomp3.addComment('select minindex at boundary');
    scomp4=pirelab.getSwitchComp(tbNet,[tbindex,decindex],decsel,toggle,'','~=',0);
    scomp4.addComment('select tbindex at boundary');


    if(blockInfo.ResetPort)
        ucomp1=pirelab.getUnitDelayEnabledResettableComp(tbNet,tbsel,tbindexreg,enb,rst,...
        'tbindexreg',0);
        ucomp2=pirelab.getUnitDelayEnabledResettableComp(tbNet,decsel,decindexreg,enb,rst,...
        'decindexreg',0);
    else
        ucomp1=pirelab.getUnitDelayEnabledComp(tbNet,tbsel,tbindexreg,enb,...
        'tbindexreg',0);
        ucomp2=pirelab.getUnitDelayEnabledComp(tbNet,decsel,decindexreg,enb,...
        'decindexreg',0);
    end
    ucomp1.addComment('register tbindex');
    ucomp2.addComment('register decindex');

    dcomp=pirelab.getBitSliceComp(tbNet,decindexreg,decodedreg,idxWL-1,idxWL-1);
    dcomp.addComment('decoded bit');

    if(blockInfo.ResetPort)
        pirelab.getUnitDelayResettableComp(tbNet,decodedreg,decoded,rst,'decode out',0);
    else
        pirelab.getUnitDelayComp(tbNet,decodedreg,decoded,'decode out',0);
    end


    statereg=tbNet.addSignal(ufix2Type,'statereg');
    addtmp=tbNet.addSignal(ufix2Type,'addtmp');
    plusone=tbNet.addSignal(ufix1Type,'plusone');
    pirelab.getConstComp(tbNet,plusone,1,'plusoneconst');
    pirelab.getAddComp(tbNet,[statereg,plusone],addtmp,'Floor','Wrap');
    toggleenb=tbNet.addSignal(ufix1Type,'toggleenb');
    pirelab.getLogicComp(tbNet,[toggle,enb],toggleenb,'and');

    if(blockInfo.ResetPort)
        pirelab.getUnitDelayEnabledResettableComp(tbNet,addtmp,statereg,toggleenb,rst,...
        'state reg',0);
    else
        pirelab.getUnitDelayEnabledComp(tbNet,addtmp,statereg,toggleenb,...
        'state reg',0);
    end

    validenb=tbNet.addSignal(ufix1Type,'validenb');
    validtmp=tbNet.addSignal(ufix1Type,'validenbreg');
    validenbtmp=tbNet.addSignal(ufix1Type,'validenbtmp');
    statenbtmp=tbNet.addSignal(ufix1Type,'statenbtmp');
    statenbreg=tbNet.addSignal(ufix1Type,'statenbreg');
    pirelab.getCompareToValueComp(tbNet,statereg,validenb,'==',2);
    pirelab.getLogicComp(tbNet,[validenb,toggleenb],validenbtmp,'and');
    pirelab.getLogicComp(tbNet,[validenbtmp,statenbreg],statenbtmp,'or');

    if(blockInfo.ResetPort)
        pirelab.getUnitDelayResettableComp(tbNet,statenbtmp,statenbreg,rst,'stat_enb_reg',0);
    else
        pirelab.getUnitDelayComp(tbNet,statenbtmp,statenbreg,'stat_enb_reg',0);
    end

    pirelab.getLogicComp(tbNet,[statenbreg,enb],validtmp,'and');
    if(blockInfo.ResetPort)
        Vcomp=pirelab.getUnitDelayResettableComp(tbNet,validtmp,valid,rst,'valid out',0);
    else
        Vcomp=pirelab.getUnitDelayComp(tbNet,validtmp,valid,'valid out',0);
    end
    Vcomp.addComment('valid generation');
end


function bitselout=elabVarBitSel(tbdecNet,in1,in2,bitnumber,name)
    ufix1Type=pir_ufixpt_t(1,0);
    bitsel=tbdecNet.addSignal(ufix1Type,[name,'bitsel',num2str(bitnumber)]);
    inType=in1.Type;
    outWL=inType.WordLength/2;
    outType=pir_ufixpt_t(outWL,0);
    bitselout=tbdecNet.addSignal(outType,[name,'data_',num2str(outWL)]);

    lowerhalf=tbdecNet.addSignal(outType,[name,'lowerhalf',num2str(outWL)]);
    upperhalf=tbdecNet.addSignal(outType,[name,'upperhalf',num2str(outWL)]);

    sComp1=pirelab.getBitSliceComp(tbdecNet,in2,bitsel,bitnumber,bitnumber);
    sComp1.addComment(['Variable Bit Selection',num2str(bitnumber)]);

    pirelab.getBitSliceComp(tbdecNet,in1,lowerhalf,outWL-1,0);
    pirelab.getBitSliceComp(tbdecNet,in1,upperhalf,2*outWL-1,outWL);
    pirelab.getSwitchComp(tbdecNet,[lowerhalf,upperhalf],bitselout,bitsel,'','==',0);
end

