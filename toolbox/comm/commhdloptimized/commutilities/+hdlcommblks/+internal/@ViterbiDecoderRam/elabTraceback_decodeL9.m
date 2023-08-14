function tbdecNet=elabTraceback_decodeL9(~,tbNet,blockInfo,dataRate)






    bankdepth=blockInfo.tbd;
    t=blockInfo.trellis;
    numStates=t.numStates;


    ramdataType=pir_ufixpt_t(numStates/2,0);

    idxWL=ceil(log2(numStates));
    idxType=pir_ufixpt_t(idxWL,0);

    ufix1Type=pir_ufixpt_t(1,0);

    cntWlen=ceil(log2(bankdepth));
    cntType=pir_ufixpt_t(cntWlen,0);




    tbdecNet=pirelab.createNewNetwork(...
    'Network',tbNet,...
    'Name','Traceback_decode',...
    'InportNames',{'dec_dataH','dec_dataL','tb_dataH','tb_dataL','minidx','reachTbd','bwd_addr'},...
    'InportTypes',[ramdataType,ramdataType,ramdataType,ramdataType,idxType,ufix1Type,cntType],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate,dataRate,dataRate],...
    'OutportNames',{'decoded'},...
    'OutportTypes',ufix1Type);


    dec_dataH=tbdecNet.PirInputSignals(1);
    dec_dataL=tbdecNet.PirInputSignals(2);
    tb_dataH=tbdecNet.PirInputSignals(3);
    tb_dataL=tbdecNet.PirInputSignals(4);
    minidx=tbdecNet.PirInputSignals(5);
    reachTbd=tbdecNet.PirInputSignals(6);
    bwd_addr=tbdecNet.PirInputSignals(7);
    decoded=tbdecNet.PirOutputSignals(1);



    tbindex=tbdecNet.addSignal(idxType,'tbindex');
    tbsel=tbdecNet.addSignal(idxType,'tbsel');
    regtbsel=tbdecNet.addSignal(idxType,'regtbsel');
    regminidx=tbdecNet.addSignal(idxType,'regminidx');
    regreachTbd=tbdecNet.addSignal(ufix1Type,'regreachTbd');

    comp=pirelab.getIntDelayComp(tbdecNet,reachTbd,regreachTbd,2);
    comp.addComment('Delay control signal');
    comp=pirelab.getIntDelayComp(tbdecNet,minidx,regminidx,2);
    comp.addComment('Delay state metric minimum index');

    scomp=pirelab.getSwitchComp(tbdecNet,[regminidx,tbindex],tbsel,regreachTbd,'','~=',0);
    scomp.addComment('Use state metric minimum index as traceback initial state');
    pirelab.getUnitDelayComp(tbdecNet,tbsel,regtbsel,'regtbsel',0);






    slicedType=pir_ufixpt_t(idxWL-1,0);
    slicedregtbsel=tbdecNet.addSignal(slicedType,'slicedtbsel');
    c1=pirelab.getBitSliceComp(tbdecNet,regtbsel,slicedregtbsel,(idxWL-2),0);
    c1.addComment(' Find previous state in traceback phase');

    for ii=idxWL:-1:1
        if ii==idxWL

            bitsel=tbdecNet.addSignal(ufix1Type,['tbbitsel',num2str(ii-1)]);
            bitselout=tbdecNet.addSignal(ramdataType,['tbdata_',num2str(numStates/2)]);
            sComp1=pirelab.getBitSliceComp(tbdecNet,regtbsel,bitsel,ii-1,ii-1);
            sComp1.addComment(['Variable Bit Selection',num2str(ii-1)]);

            sComp2=pirelab.getSwitchComp(tbdecNet,[tb_dataH,tb_dataL],bitselout,bitsel,'','~=',0);
            sliced_tb_data=bitselout;
        else
            in1=sliced_tb_data;
            sliced_tb_data=elabVarBitSel(tbdecNet,in1,slicedregtbsel,ii-1,'tb');
        end


    end

    c2=pirelab.getBitConcatComp(tbdecNet,[slicedregtbsel,sliced_tb_data],tbindex);


    decindex=tbdecNet.addSignal(idxType,'decindex');
    decsel=tbdecNet.addSignal(idxType,'decsel');
    regdecsel=tbdecNet.addSignal(idxType,'regdecsel');

    scomp=pirelab.getSwitchComp(tbdecNet,[tbindex,decindex],decsel,regreachTbd,'','~=',0);
    scomp.addComment('Use traceback index as decode initial state');
    pirelab.getUnitDelayComp(tbdecNet,decsel,regdecsel,'regdecsel',0);



    slicedregdecsel=tbdecNet.addSignal(slicedType,'sliceddecsel');
    c1=pirelab.getBitSliceComp(tbdecNet,regdecsel,slicedregdecsel,(idxWL-2),0);
    c1.addComment(' Find previous state in decoding phase');

    for ii=idxWL:-1:1
        if ii==idxWL

            bitsel=tbdecNet.addSignal(ufix1Type,['decbitsel',num2str(ii-1)]);
            bitselout=tbdecNet.addSignal(ramdataType,['decdata_',num2str(numStates/2)]);
            sComp1=pirelab.getBitSliceComp(tbdecNet,regdecsel,bitsel,ii-1,ii-1);
            sComp1.addComment(['Variable Bit Selection',num2str(ii-1)]);

            sComp2=pirelab.getSwitchComp(tbdecNet,[dec_dataH,dec_dataL],bitselout,bitsel,'','~=',0);
            sliced_dec_data=bitselout;
        else
            in1=sliced_dec_data;
            sliced_dec_data=elabVarBitSel(tbdecNet,in1,slicedregdecsel,ii-1,'dec');
        end


    end

    c2=pirelab.getBitConcatComp(tbdecNet,[slicedregdecsel,sliced_dec_data],decindex);

    decoded_rev=tbdecNet.addSignal(ufix1Type,'decoded_rev');
    pirelab.getBitSliceComp(tbdecNet,regdecsel,decoded_rev,idxWL-1,idxWL-1);



    seloutvType=pirelab.getPirVectorType(ufix1Type,bankdepth-1);
    selinvType=pirelab.getPirVectorType(ufix1Type,bankdepth);

    seltout=tbdecNet.addSignal(seloutvType,'seltout');
    seltin=tbdecNet.addSignal(selinvType,'seltin');
    muxout=tbdecNet.addSignal(selinvType,'muxout');
    idxseltin=tbdecNet.addSignal(selinvType,'idxseltin');

    regbwd_addr=tbdecNet.addSignal(cntType,'regbwd_addr');


    comp=pirelab.getMuxComp(tbdecNet,[seltout,decoded_rev],muxout);
    comp.addComment(' Buffer reversed decoded data');

    pirelab.getUnitDelayComp(tbdecNet,muxout,seltin,'regselectors',0);


    paramArray={2:bankdepth};
    cs=pirelab.getSelectorComp(tbdecNet,seltin,seltout,'One-based',...
    {'Index vector (dialog)'},paramArray,{'1'},'1');

    cud=pirelab.getUnitDelayEnabledComp(tbdecNet,muxout,idxseltin,regreachTbd,'loaddecoded',0.0,'',false);

    cint=pirelab.getIntDelayComp(tbdecNet,bwd_addr,regbwd_addr,2);



    if(cntType.WordLength>8)
        seltidxWlen=16;
    else
        seltidxWlen=8;
    end

    seltidx=tbdecNet.addSignal(pir_ufixpt_t(seltidxWlen,0),'seltidx');

    pirelab.getDTCComp(tbdecNet,regbwd_addr,seltidx,'nearest','wrap');
    cs=pirelab.getSelectorComp(tbdecNet,[idxseltin,seltidx],decoded,'Zero-based',...
    {'Index vector (port)'},{4},{'1'},'1');
    cs.addComment('Output decoded data');

end


function bitselout=elabVarBitSel(tbdecNet,in1,in2,bitnumber,name)

    ufix1Type=pir_ufixpt_t(1,0);
    bitsel=tbdecNet.addSignal(ufix1Type,[name,'bitsel',num2str(bitnumber)]);
    in1Type=in1.Type;
    outWlen=in1Type.WordLength/2;
    outType=pir_ufixpt_t(outWlen,0);
    bitselout=tbdecNet.addSignal(outType,[name,'data_',num2str(outWlen)]);

    lowerhalf=tbdecNet.addSignal(outType,[name,'lowerhalf',num2str(outWlen)]);
    upperhalf=tbdecNet.addSignal(outType,[name,'upperhalf',num2str(outWlen)]);

    sComp1=pirelab.getBitSliceComp(tbdecNet,in2,bitsel,bitnumber,bitnumber);
    sComp2=pirelab.getBitSliceComp(tbdecNet,in1,lowerhalf,outWlen-1,0);
    sComp3=pirelab.getBitSliceComp(tbdecNet,in1,upperhalf,2*outWlen-1,outWlen);
    sComp4=pirelab.getSwitchComp(tbdecNet,[lowerhalf,upperhalf],bitselout,bitsel,'','~=',0);
    sComp1.addComment(['Variable Bit Selection',num2str(bitnumber)]);

end

