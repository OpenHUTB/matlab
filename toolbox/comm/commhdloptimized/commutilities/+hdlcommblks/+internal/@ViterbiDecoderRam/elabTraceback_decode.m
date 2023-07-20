function tbdecNet=elabTraceback_decode(~,tbNet,blockInfo,dataRate)





    bankdepth=blockInfo.tbd;
    t=blockInfo.trellis;
    numStates=t.numStates;


    if(blockInfo.L<9)
        dataLen=numStates;
    end


    ramdataType=pir_ufixpt_t(dataLen,0);

    idxWL=ceil(log2(dataLen));
    idxType=pir_ufixpt_t(idxWL,0);

    ufix1Type=pir_ufixpt_t(1,0);

    cntWlen=ceil(log2(bankdepth));
    cntType=pir_ufixpt_t(cntWlen,0);




    tbdecNet=pirelab.createNewNetwork(...
    'Network',tbNet,...
    'Name','Traceback_decode',...
    'InportNames',{'dec_data','tb_data','minidx','reachTbd','bwd_addr'},...
    'InportTypes',[ramdataType,ramdataType,idxType,ufix1Type,cntType],...
    'InportRates',[dataRate,dataRate,dataRate,dataRate,dataRate],...
    'OutportNames',{'decoded'},...
    'OutportTypes',ufix1Type);



    dec_data=tbdecNet.PirInputSignals(1);
    tb_data=tbdecNet.PirInputSignals(2);
    minidx=tbdecNet.PirInputSignals(3);
    reachTbd=tbdecNet.PirInputSignals(4);
    bwd_addr=tbdecNet.PirInputSignals(5);
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
    scomp.addComment('Use minimum state metric index as traceback initial state');
    pirelab.getUnitDelayComp(tbdecNet,tbsel,regtbsel,'regtbsel',0);





    for ii=idxWL:-1:1
        if ii==idxWL
            in1=tb_data;
        else
            in1=sliced_tb_data;
        end

        sliced_tb_data=elabVarBitSel(tbdecNet,in1,regtbsel,ii-1,'tb');
    end


    slicedType=pir_ufixpt_t(idxWL-1,0);
    slicedregtbsel=tbdecNet.addSignal(slicedType,'slicedtbsel');
    c1=pirelab.getBitSliceComp(tbdecNet,regtbsel,slicedregtbsel,(idxWL-2),0);
    c2=pirelab.getBitConcatComp(tbdecNet,[slicedregtbsel,sliced_tb_data],tbindex);
    c1.addComment(' Find previous state in traceback phase');


    decindex=tbdecNet.addSignal(idxType,'decindex');
    decsel=tbdecNet.addSignal(idxType,'decsel');
    regdecsel=tbdecNet.addSignal(idxType,'regdecsel');

    scomp=pirelab.getSwitchComp(tbdecNet,[tbindex,decindex],decsel,regreachTbd,'','~=',0);
    scomp.addComment('Use traceback index as decode initial state');
    pirelab.getUnitDelayComp(tbdecNet,decsel,regdecsel,'regdecsel',0);



    for ii=idxWL:-1:1
        if ii==idxWL
            in1=dec_data;
        else
            in1=sliced_dec_data;
        end

        sliced_dec_data=elabVarBitSel(tbdecNet,in1,regdecsel,ii-1,'dec');
    end

    slicedregdecsel=tbdecNet.addSignal(slicedType,'sliceddecsel');
    c1=pirelab.getBitSliceComp(tbdecNet,regdecsel,slicedregdecsel,(idxWL-2),0);
    c2=pirelab.getBitConcatComp(tbdecNet,[slicedregdecsel,sliced_dec_data],decindex);
    c1.addComment(' Find previous state in decoding phase');

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
    comp.addComment('Buffer reversed decoded data');

    pirelab.getUnitDelayComp(tbdecNet,muxout,seltin,'regselectors',0);

    paramArray={2:bankdepth};
    cs=pirelab.getSelectorComp(tbdecNet,seltin,seltout,'One-based',...
    {'Index vector (dialog)'},paramArray,{'1'},'1');

    cud=pirelab.getUnitDelayEnabledComp(tbdecNet,muxout,idxseltin,regreachTbd,'loaddecoded',0.0,'',false);

    cint=pirelab.getIntDelayComp(tbdecNet,bwd_addr,regbwd_addr,2);
    cint.addComment('Delay reverse order address');


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
