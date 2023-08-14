function elaborateViterbiNetwork(this,topNet,blockInfo)









    insignals=topNet.PirInputSignals;


    in=insignals(1);
    regin=topNet.addSignal(in.Type,'regin');
    regcomp=pirelab.getUnitDelayComp(topNet,in,regin,'InputRegister',0);
    regcomp.addComment('Input Register');

    if(blockInfo.hasResetPort&&blockInfo.DelayedResetAction)
        rst=insignals(2);
    else
        rst=[];
    end



    out=topNet.PirOutputSignals(1);




    BMoutWL=blockInfo.nsDec+blockInfo.n-1;
    BMoutType=pir_ufixpt_t(BMoutWL,0);
    t=blockInfo.trellis;
    vectorType=pirelab.getPirVectorType(BMoutType,t.numOutputSymbols);
    bmout=topNet.addSignal(vectorType,'bMet');


    BMetNet=this.elabBMet(topNet,blockInfo);
    BMetNet.addComment('Branch Metric Computation');

    pirelab.instantiateNetwork(topNet,BMetNet,regin,bmout,'BMet_inst');



    regbmet=topNet.addSignal(vectorType,'regBMet');
    regcomp=pirelab.getUnitDelayComp(topNet,bmout,regbmet,'BMetRegister',0);
    regcomp.addComment('Branch Metric output Register');


    ufix1Type=pir_ufixpt_t(1,0);
    decvType=pirelab.getPirVectorType(ufix1Type,t.numStates);
    dec=topNet.addSignal(decvType,'dec');

    idxType=pir_ufixpt_t(log2(t.numStates),0);
    idx=topNet.addSignal(idxType,'idx');


    ACSNet=this.elabACS(topNet,blockInfo,in.SimulinkRate);
    ACSNet.addComment(['ACS: connects the add-compare and select units',newline,'and performs the state metric normalization']);


    if isempty(rst)
        pirelab.instantiateNetwork(topNet,ACSNet,regbmet,[dec,idx],'ACS_inst');
    else
        pirelab.instantiateNetwork(topNet,ACSNet,[regbmet,rst],[dec,idx],'ACS_inst');
    end

    regdec=topNet.addSignal(decvType,'regdec');
    regidx=topNet.addSignal(idxType,'regidx');

    regcomp=pirelab.getUnitDelayComp(topNet,dec,regdec,'decRegister',0);
    regcomp.addComment('ACS dec output Register');

    regcomp=pirelab.getUnitDelayComp(topNet,idx,regidx,'idxRegister',0);
    regcomp.addComment('ACS idx output Register');




    ufix1Type=pir_ufixpt_t(1,0);
    decoded=topNet.addSignal(ufix1Type,'decoded');
    tbNet=this.elabTraceback(topNet,blockInfo,in.SimulinkRate);
    tbNet.addComment(['Traceback Decoding',newline,'Connects traceback units and adds ',num2str(blockInfo.tbregnum),' pipeline registers']);


    if isempty(rst)
        pirelab.instantiateNetwork(topNet,tbNet,[regdec,regidx],decoded,'Traceback_inst');
    else

        pirelab.instantiateNetwork(topNet,tbNet,[regdec,regidx,rst],decoded,'Traceback_inst');
    end


    if(out.Type.isUnsignedType(1))
        outreg=out;
    else
        outreg=topNet.addSignal(ufix1Type,'outreg');
    end


    regcomp=pirelab.getUnitDelayComp(topNet,decoded,outreg,'DecoderoutputRegister',0);
    regcomp.addComment('Viterbi Decoder output Register');

    if~out.Type.isUnsignedType(1)
        dtccomp=pirelab.getDTCComp(topNet,outreg,out,'Nearest','saturate');
        dtccomp.addComment('Output data type conversion');
    end

end
