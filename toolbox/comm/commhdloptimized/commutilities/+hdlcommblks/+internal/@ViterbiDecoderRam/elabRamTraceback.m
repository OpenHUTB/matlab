function tbNet=elabRamTraceback(this,topNet,blockInfo,dataRate)







    t=blockInfo.trellis;
    numStates=t.numStates;



    ufix1Type=pir_ufixpt_t(1,0);
    decvType=pirelab.getPirVectorType(ufix1Type,numStates);

    idxWL=ceil(log2(numStates));
    idxType=pir_ufixpt_t(idxWL,0);



    tbNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','Traceback',...
    'InportNames',{'dec','idx'},...
    'InportTypes',[decvType,idxType],...
    'InportRates',[dataRate,dataRate],...
    'OutportNames',{'decoded'},...
    'OutportTypes',ufix1Type);

    decin=tbNet.PirInputSignals(1);
    idxin=tbNet.PirInputSignals(2);
    decoded=tbNet.PirOutputSignals(1);





    bankdepth=blockInfo.tbd;
    cntWlen=ceil(log2(bankdepth));
    cntType=pir_ufixpt_t(cntWlen,0);
    ramaddrWlen=ceil(log2(3*bankdepth));
    ramaddrType=pir_ufixpt_t(ramaddrWlen,0);
    reachTbd=tbNet.addSignal(ufix1Type,'reachTbd');
    bwd_addr=tbNet.addSignal(cntType,'bwd_addr');
    wr_addr=tbNet.addSignal(ramaddrType,'wr_addr');
    tb_addr=tbNet.addSignal(ramaddrType,'tb_addr');


    tbctlNet=this.elabTraceback_control(tbNet,blockInfo,dataRate);
    tbctlNet.addComment(['RAM-based Traceback Controller ',newline,'Generates control signals and memory read/write address']);


    pirelab.instantiateNetwork(tbNet,tbctlNet,'',[wr_addr,tb_addr,bwd_addr,reachTbd],'TbController_inst');






    wr_en=tbNet.addSignal(ufix1Type,'wr_en');
    wrencomp=pirelab.getConstComp(tbNet,wr_en,1,'wr_en');
    wrencomp.addComment('RAM write enable');

    L=blockInfo.L;
    commentStr='RAM-based Traceback Decode and LIFO';
    commentStr=[commentStr,newline,'Traceback phase traces a path starting from a state with minimum metric'];
    commentStr=[commentStr,newline,'Decode phase decodes information bits based on the path being traced'];

    if(L<9)


        ramdataType=pir_ufixpt_t(numStates,0);
        decdata=tbNet.addSignal(ramdataType,'decdata');
        tbdata=tbNet.addSignal(ramdataType,'tbdata');
        wr_din=tbNet.addSignal(ramdataType,'wr_din');
        bitconcomp=pirelab.getBitConcatComp(tbNet,decin,wr_din);
        bitconcomp.addComment('Vector to scalar conversion');
        pirelab.getDualPortRamComp(tbNet,[wr_din,wr_addr,wr_en,tb_addr],[decdata,tbdata],...
        'Traceback_RAM',1,0);

        regtbdata=tbNet.addSignal(ramdataType,'regtbdata');
        regdecdata=tbNet.addSignal(ramdataType,'regdecdata');
        pirelab.getUnitDelayComp(tbNet,decdata,regdecdata,'reg_decdata',0);
        pirelab.getUnitDelayComp(tbNet,tbdata,regtbdata,'reg_tbdata',0);



        tbdecNet=this.elabTraceback_decode(tbNet,blockInfo,dataRate);
        tbdecNet.addComment(commentStr);


        pirelab.instantiateNetwork(tbNet,tbdecNet,[regdecdata,regtbdata,idxin,reachTbd,bwd_addr],decoded,'TbDecoder_inst');

    else


        halframdataType=pir_ufixpt_t(numStates/2,0);

        wr_dinL=tbNet.addSignal(halframdataType,'wr_dinL');
        wr_dinH=tbNet.addSignal(halframdataType,'wr_dinH');
        decdataL=tbNet.addSignal(halframdataType,'decdataL');
        decdataH=tbNet.addSignal(halframdataType,'decdataH');
        tbdataL=tbNet.addSignal(halframdataType,'tbdataL');
        tbdataH=tbNet.addSignal(halframdataType,'tbdataH');


        decins=this.demuxSignal(tbNet,decin,'decin_entry');
        bitconcomp=pirelab.getBitConcatComp(tbNet,decins(1:numStates/2),wr_dinL);
        bitconcomp.addComment('Vector to scalar conversion--Lower half');
        bitconcomp=pirelab.getBitConcatComp(tbNet,decins(numStates/2+1:numStates),wr_dinH);
        bitconcomp.addComment('Vector to scalar conversion--Upper half');

        pirelab.getDualPortRamComp(tbNet,[wr_dinL,wr_addr,wr_en,tb_addr],...
        [decdataL,tbdataL],'Traceback_RAM',1,0);
        pirelab.getDualPortRamComp(tbNet,[wr_dinH,wr_addr,wr_en,tb_addr],...
        [decdataH,tbdataH],'Traceback_RAM',1,0);

        regtbdataL=tbNet.addSignal(halframdataType,'regtbdataL');
        regtbdataH=tbNet.addSignal(halframdataType,'regtbdataH');
        regdecdataL=tbNet.addSignal(halframdataType,'regdecdataL');
        regdecdataH=tbNet.addSignal(halframdataType,'regdecdataH');

        pirelab.getUnitDelayComp(tbNet,tbdataL,regtbdataL,'reg_tbdataL',0);
        pirelab.getUnitDelayComp(tbNet,tbdataH,regtbdataH,'reg_tbdataHL',0);
        pirelab.getUnitDelayComp(tbNet,decdataL,regdecdataL,'reg_decdataL',0);
        pirelab.getUnitDelayComp(tbNet,decdataH,regdecdataH,'reg_decdataH',0);




        tbdecNet=this.elabTraceback_decodeL9(tbNet,blockInfo,dataRate);
        tbdecNet.addComment(commentStr);

        pirelab.instantiateNetwork(tbNet,tbdecNet,[regdecdataH,regdecdataL,regtbdataH,regtbdataL,idxin,reachTbd,bwd_addr],decoded,'TbDecoder_inst');

    end
