function elaborateRSEncoderNetwork(this,topNet,blockInfo)%#ok<INUSL>









    insignals=topNet.PirInputSignals;

    in=insignals(1);
    startInput=insignals(2);
    endInput=insignals(3);
    dvIn=insignals(4);


    outsignals=topNet.PirOutputSignals;

    output=outsignals(1);
    startOut=outsignals(2);
    endOut=outsignals(3);
    dvOut=outsignals(4);

    rate=in.SimulinkRate;
    output.SimulinkRate=rate;
    startOut.SimulinkRate=rate;
    endOut.SimulinkRate=rate;
    dvOut.SimulinkRate=rate;



    messageLength=double(blockInfo.MessageLength);
    codewordLength=double(blockInfo.CodewordLength);
    primPoly=double(blockInfo.PrimitivePolynomial);

    if strcmp(blockInfo.PuncturePatternSource,'None')
        usePuncturePattern=false;
        puncturePattern=[];
        parityLength=codewordLength-messageLength;
        fullParityLength=codewordLength-messageLength;
    else
        usePuncturePattern=true;
        puncturePattern=double(blockInfo.PuncturePattern);
        parityLength=sum(puncturePattern);
        fullParityLength=codewordLength-messageLength;
    end

    if strcmp(blockInfo.BSource,'Auto')
        B=1;
    else
        B=double(blockInfo.B);
    end



    if strcmp(blockInfo.PrimitivePolynomialSource,'Auto')
        [tMultTable,~,~,tWordSize,~,~]=HDLRSGenPoly(codewordLength,messageLength,B);
    else
        [tMultTable,~,~,tWordSize,~,~]=HDLRSGenPoly(codewordLength,messageLength,B,primPoly);
    end

    wordSize=double(tWordSize);

    multTable=ufi(tMultTable,wordSize,0);




    controlType=pir_ufixpt_t(1,0);


    startIn=topNet.addSignal(controlType,'startin_valid');
    pirelab.getBitwiseOpComp(topNet,[startInput,dvIn],startIn,'AND');
    endIn_valid=topNet.addSignal(controlType,'endin_valid');
    pirelab.getBitwiseOpComp(topNet,[endInput,dvIn],endIn_valid,'AND');


    inType=pir_ufixpt_t(wordSize,0);
    xorfeedback=topNet.addSignal(inType,'xorfeedback');
    inputxor=topNet.addSignal(inType,'inputxor');

    c=pirelab.getBitwiseOpComp(topNet,[in,xorfeedback],inputxor,'XOR');
    c.addComment('XOR to input with feedback to drive lookup tables');

    dvindelayed=topNet.addSignal(controlType,'dvindelayed');
    startindelayed=topNet.addSignal(controlType,'startindelayed');
    endindelayed=topNet.addSignal(controlType,'endindelayed');
    notendin=topNet.addSignal(controlType,'notendin');
    inpacket=topNet.addSignal(controlType,'inpacket');
    inpacketnext=topNet.addSignal(controlType,'inpacketnext');
    notdonepacket=topNet.addSignal(controlType,'notdonepacket');



    endIn=topNet.addSignal(controlType,'endin_packet');
    pirelab.getBitwiseOpComp(topNet,[endIn_valid,inpacket],endIn,'AND');


    pirelab.getUnitDelayComp(topNet,dvIn,dvindelayed,'dvdelay',0.0);
    pirelab.getUnitDelayComp(topNet,startIn,startindelayed,'startdelay',0.0);
    pirelab.getUnitDelayComp(topNet,endIn,endindelayed,'enddelay',0.0);

    pirelab.getUnitDelayComp(topNet,inpacketnext,inpacket,'inpacketreg',0.0);
    pirelab.getBitwiseOpComp(topNet,endIn,notendin,'NOT');
    pirelab.getBitwiseOpComp(topNet,[startIn,notdonepacket],inpacketnext,'OR');
    pirelab.getBitwiseOpComp(topNet,[notendin,inpacket],notdonepacket,'AND');

    countType=pir_ufixpt_t(ceil(log2(parityLength-1)),0);
    paritycount=topNet.addSignal(countType,'paritycount');

    parityout=topNet.addSignal(inType,'parityout');
    sendparity=topNet.addSignal(controlType,'sendparity');
    setsend=topNet.addSignal(controlType,'setsend');
    notdone=topNet.addSignal(controlType,'notdone');
    parityend=topNet.addSignal(controlType,'parityend');
    notparityend=topNet.addSignal(controlType,'notparityend');
    gateddvin=topNet.addSignal(controlType,'gateddvin');
    inpacketgate=topNet.addSignal(controlType,'inpacketgate');
    predvout=topNet.addSignal(controlType,'predvout');
    parityen=topNet.addSignal(controlType,'parityen');
    parityenprime=topNet.addSignal(controlType,'parityenprime');
    endin_valid_dly=topNet.addSignal(controlType,'endin_valid_dly');
    parityennext=topNet.addSignal(controlType,'parityennext');

    pirelab.getCompareToValueComp(topNet,paritycount,parityend,'==',parityLength-1,'paritycompare');
    pirelab.getBitwiseOpComp(topNet,parityend,notparityend,'NOT');
    pirelab.getBitwiseOpComp(topNet,[endIn,notdone],setsend,'OR');
    pirelab.getBitwiseOpComp(topNet,[notparityend,sendparity],notdone,'AND');
    c=pirelab.getUnitDelayComp(topNet,setsend,sendparity,'sendparityreg',0.0,'',false);
    c.addComment('Register to control the output mux selecting with input data or parity.');

    pirelab.getBitwiseOpComp(topNet,[inpacket,startIn],inpacketgate,'OR');
    pirelab.getBitwiseOpComp(topNet,[dvIn,inpacketgate],gateddvin,'AND');
    pirelab.getBitwiseOpComp(topNet,[gateddvin,sendparity],predvout,'OR');

    pirelab.getBitwiseOpComp(topNet,[dvIn,inpacketgate],parityennext,'AND');
    pirelab.getUnitDelayComp(topNet,parityennext,parityen,'parityenreg',0.0,'',false);

    pirelab.getUnitDelayComp(topNet,endIn_valid,endin_valid_dly,'endvaldly',0.0,'',false);
    pirelab.getBitwiseOpComp(topNet,[dvIn,endin_valid_dly],parityenprime,'OR');

    pirelab.getCounterComp(topNet,sendparity,paritycount,...
    'Count limited',...
    0.0,...
    1.0,...
    parityLength-1,...
    false,...
    false,...
    true,...
    false,...
    'paritycount');


    pirelab.getUnitDelayComp(topNet,predvout,dvOut,'endreg',0.0,'',false);
    pirelab.getWireComp(topNet,startindelayed,startOut);
    pirelab.getUnitDelayComp(topNet,parityend,endOut,'endreg',0.0,'',false);


    zeroconst=topNet.addSignal(inType,'zeroconst');
    pirelab.getConstComp(topNet,zeroconst,0,'zeroconst');




    for ii=1:fullParityLength
        table(ii)=topNet.addSignal(inType,sprintf('gftable%d',ii));%#ok
        delayreg(ii)=topNet.addSignal(inType,sprintf('gftablereg%d',ii));%#ok
        startmux(ii)=topNet.addSignal(inType,sprintf('startmux%d',ii));%#ok
        parityreg(ii)=topNet.addSignal(inType,sprintf('parityreg%d',ii));%#ok 
        parity(ii)=topNet.addSignal(inType,sprintf('parity%d',ii));%#ok

    end








    startInEnb=startIn;


    for ii=1:fullParityLength
        c1=pirelab.getDirectLookupComp(topNet,inputxor,table(ii),multTable(ii,:),'gftable');
        c2=pirelab.getUnitDelayEnabledComp(topNet,table(ii),delayreg(ii),dvIn,'gftablereg',0.0,'',false);

        c3=pirelab.getSwitchComp(topNet,[delayreg(ii),zeroconst],startmux(ii),startIn,'startmux');

        if ii==(codewordLength-messageLength)

            c5=pirelab.getUnitDelayEnabledResettableComp(topNet,startmux(ii),parityreg(ii),parityenprime,startInEnb,...
            'paritystate',0.0,'',true);
        else
            c4=pirelab.getBitwiseOpComp(topNet,[startmux(ii),parityreg(ii+1)],parity(ii),'XOR');
            c5=pirelab.getUnitDelayEnabledResettableComp(topNet,parity(ii),parityreg(ii),parityenprime,startInEnb,...
            'paritystate',0.0,'',true);

        end
    end

    ca=pirelab.getSwitchComp(topNet,[parity(1),zeroconst],xorfeedback,startIn);

    parityToSend=[xorfeedback,parityreg(2:end)];
    if usePuncturePattern
        parityToSend=parityToSend(logical(puncturePattern));
    end
    cm=pirelab.getMultiPortSwitchComp(topNet,[paritycount,parityToSend],parityout,...
    1,1,'floor','Wrap','parityoutmux');

    finalmux=topNet.addSignal(inType,'finalmux');

    cf=pirelab.getSwitchComp(topNet,[in,parityout],finalmux,sendparity,'finalmux');
    ca=pirelab.getUnitDelayEnabledComp(topNet,finalmux,output,predvout,'outputreg',0.0,'',false);



