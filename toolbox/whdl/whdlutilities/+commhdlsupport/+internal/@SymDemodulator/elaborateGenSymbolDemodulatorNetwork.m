function elaborateGenSymbolDemodulatorNetwork(this,topNet,blockInfo,insignals,outsignals)






    Inpind=1;
    dataIn=insignals(Inpind);
    rate=dataIn.SimulinkRate;
    Inpind=Inpind+1;
    if(strcmpi(blockInfo.ModulationSource,'Input port'))
        if(strcmpi(blockInfo.OutputType,'Scalar'))
            validIn=insignals(Inpind);
            Inpind=Inpind+1;
        else
            startIn=insignals(Inpind);
            endIn=insignals(Inpind+1);
            validIn=insignals(Inpind+2);
            Inpind=Inpind+3;
        end
        modSelIn=insignals(Inpind);
        Inpind=Inpind+1;
    else
        validIn=insignals(Inpind);
        Inpind=Inpind+1;
    end
    if(blockInfo.NoiseVariance)
        nVar=insignals(Inpind);
    end

    Outind=1;
    dataOut=outsignals(Outind);
    Outind=Outind+1;
    if(strcmpi(blockInfo.ModulationSource,'Input port'))
        if(strcmpi(blockInfo.OutputType,'Scalar'))
            validOut=outsignals(Outind);
            Outind=Outind+1;
        else
            startOut=outsignals(Outind);
            endOut=outsignals(Outind+1);
            validOut=outsignals(Outind+2);
            Outind=Outind+3;
            startOut.SimulinkRate=rate;
            endOut.SimulinkRate=rate;
        end
    else
        validOut=outsignals(Outind);
        Outind=Outind+1;
    end
    if strcmpi(blockInfo.OutputType,'Scalar')
        readyOut=outsignals(Outind);
        readyOut.SimulinkRate=rate;
    end


    dataOut.SimulinkRate=rate;
    validOut.SimulinkRate=rate;

    inWL=dataIn.Type.BaseType.WordLength;
    inFL=dataIn.Type.BaseType.FractionLength;

    if(blockInfo.NoiseVariance)
        nVarWL=nVar.Type.BaseType.WordLength;
        nVarFL=nVar.Type.BaseType.FractionLength;
        nVarType=pir_ufixpt_t(nVarWL,nVarFL);
        outTypeNV=pir_sfixpt_t(inWL+13,inFL);

        if(inFL==0&&(inWL==8||inWL==16||inWL==32))
            divInpType=pir_sfixpt_t(inWL+4+11-nVarFL,inFL-11+nVarFL);
            inType=pir_complex_t(pir_sfixpt_t(inWL+11,inFL-11));
            inWL=inWL+11;
            inFL=inFL-11;
            outType=pir_sfixpt_t(inWL+4,inFL);
        else
            divInpType=pir_sfixpt_t(inWL+4-nVarFL,inFL+nVarFL);
            inType=pir_complex_t(pir_sfixpt_t(inWL,inFL));
            outType=pir_sfixpt_t(inWL+4,inFL);
        end

        nVarZero=newControlSignal(topNet,'nVarZero',rate);
        nVarIn=newDataSignal(topNet,nVarType,'nVarIn',rate);
        oneSig=newDataSignal(topNet,outTypeNV,'oneSig',rate);
        pirelab.getConstComp(topNet,oneSig,1);
        pirelab.getCompareToValueComp(topNet,nVar,nVarZero,'==',0,'nVarcomp');
        pirelab.getSwitchComp(topNet,[nVar,oneSig],nVarIn,nVarZero);
    else
        inType=pir_complex_t(pir_sfixpt_t(inWL,inFL));
        outType=pir_sfixpt_t(inWL+4,inFL);
    end


    if(strcmpi(blockInfo.ModulationSource,'Input port'))
        modSelInDelay=newDataSignal(topNet,pir_ufixpt_t(3,0),'modSelInDelay',rate);
        pirelab.getDTCComp(topNet,modSelIn,modSelInDelay);
    end



    if strcmp(blockInfo.ModulationSource,'Property')
        if(strcmp(blockInfo.OutputType,'Vector'))
            switch(blockInfo.ModulationScheme)
            case 'BPSK'
                bpskDataIn=newDataSignal(topNet,inType,'bpskDataIn',rate);
                bpskValidIn=newControlSignal(topNet,'bpskValidIn',rate);
                pirelab.getWireComp(topNet,validIn,bpskValidIn);
                pirelab.getDTCComp(topNet,dataIn,bpskDataIn);


                bpskDataOut=newDataSignal(topNet,outType,'bpskDataOut',rate);
                bpskValidOut=newControlSignal(topNet,'bpskValidOut',rate);

                symbBPSKVectorDemodNet=this.elabBPSKVectorSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symbBPSKVectorDemodNet.addComment('BPSK vector Demodulation');

                inports_bpsk(1)=bpskDataIn;
                inports_bpsk(2)=bpskValidIn;

                outports_bpsk(1)=bpskDataOut;
                outports_bpsk(2)=bpskValidOut;

                pirelab.instantiateNetwork(topNet,symbBPSKVectorDemodNet,inports_bpsk,outports_bpsk,'symbBPSKDemodNet_inst');

                if(blockInfo.NoiseVariance)
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,outTypeNV,'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,outTypeNV,'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        bpskdataDTC=newDataSignal(topNet,divInpType,'bpskdataDTC',rate);
                        pirelab.getDTCComp(topNet,bpskDataOut,bpskdataDTC,'Zero','Saturate');
                        nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                        pirelab.getIntDelayComp(topNet,nVarIn,nVarInDelayed,6);
                        [divOut,latency]=nonRestoreDivision(topNet,bpskdataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,bpskValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                    else
                        pirelab.getCompareToValueComp(topNet,bpskDataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,bpskValidOut,validOut);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,bpskDataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,bpskDataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,bpskValidOut,validOut);
                end

            case 'QPSK'
                qpskDataIn=newDataSignal(topNet,inType,'qpskDataIn',rate);
                qpskValidIn=newControlSignal(topNet,'qpskValidIn',rate);
                pirelab.getWireComp(topNet,validIn,qpskValidIn);
                pirelab.getDTCComp(topNet,dataIn,qpskDataIn);


                qpskDataOut=newDataSignal(topNet,pirelab.createPirArrayType(outType,[2,0]),'qpskDataOut',rate);
                qpskValidOut=newControlSignal(topNet,'qpskValidOut',rate);

                symbqpskVectorDemodNet=this.elabQPSKVectorSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symbqpskVectorDemodNet.addComment('QPSK vector Demodulation');

                inports_qpsk(1)=qpskDataIn;
                inports_qpsk(2)=qpskValidIn;

                outports_qpsk(1)=qpskDataOut;
                outports_qpsk(2)=qpskValidOut;

                pirelab.instantiateNetwork(topNet,symbqpskVectorDemodNet,inports_qpsk,outports_qpsk,'symbQPSKDemodNet_inst');

                if(blockInfo.NoiseVariance)
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,pirelab.createPirArrayType(outTypeNV,[2,0]),'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,pirelab.createPirArrayType(outTypeNV,[2,0]),'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        qpskdataDTC=newDataSignal(topNet,pirelab.createPirArrayType(divInpType,[2,0]),'qpskdataDTC',rate);
                        pirelab.getDTCComp(topNet,qpskDataOut,qpskdataDTC,'Zero','Saturate');
                        nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                        pirelab.getIntDelayComp(topNet,nVarIn,nVarInDelayed,5);
                        [divOut,latency]=nonRestoreDivision(topNet,qpskdataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,qpskValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                    else
                        pirelab.getCompareToValueComp(topNet,qpskDataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,qpskValidOut,validOut);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,qpskDataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,qpskDataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,qpskValidOut,validOut);
                end


            case '8-PSK'
                psk8DataInDelay=newDataSignal(topNet,inType,'psk8DataInDelay',rate);
                psk8ValidInDelay=newControlSignal(topNet,'psk8ValidInDelay',rate);
                pirelab.getWireComp(topNet,validIn,psk8ValidInDelay);
                pirelab.getDTCComp(topNet,dataIn,psk8DataInDelay);


                psk8DataOut=newDataSignal(topNet,pirelab.createPirArrayType(outType,[3,0]),'psk8DataOut',rate);
                psk8ValidOut=newControlSignal(topNet,'psk8ValidOut',rate);

                symb8PSKVectorDemodNet=this.elab8PSKVectorSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symb8PSKVectorDemodNet.addComment('8PSK vector Demodulation');

                inports_psk8(1)=psk8DataInDelay;
                inports_psk8(2)=psk8ValidInDelay;

                outports_psk8(1)=psk8DataOut;
                outports_psk8(2)=psk8ValidOut;

                pirelab.instantiateNetwork(topNet,symb8PSKVectorDemodNet,inports_psk8,outports_psk8,'symb8PSKDemodNet_inst');

                if(blockInfo.NoiseVariance)
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,pirelab.createPirArrayType(outTypeNV,[3,0]),'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,pirelab.createPirArrayType(outTypeNV,[3,0]),'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        psk8dataDTC=newDataSignal(topNet,pirelab.createPirArrayType(divInpType,[3,0]),'psk8dataDTC',rate);
                        pirelab.getDTCComp(topNet,psk8DataOut,psk8dataDTC,'Zero','Saturate');
                        nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                        pirelab.getIntDelayComp(topNet,nVarIn,nVarInDelayed,7);
                        [divOut,latency]=nonRestoreDivision(topNet,psk8dataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,psk8ValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                    else
                        pirelab.getCompareToValueComp(topNet,psk8DataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,psk8ValidOut,validOut);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,psk8DataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,psk8DataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,psk8ValidOut,validOut);
                end


            case '16-PSK'
                psk16ValidInDelay=newControlSignal(topNet,'psk16ValidInDelay',rate);
                pirelab.getWireComp(topNet,validIn,psk16ValidInDelay);
                psk16DataInDelay=newDataSignal(topNet,inType,'psk16DataInDelay',rate);
                pirelab.getDTCComp(topNet,dataIn,psk16DataInDelay);


                psk16DataOut=newDataSignal(topNet,pirelab.createPirArrayType(outType,[4,0]),'psk16DataOut',rate);
                psk16ValidOut=newControlSignal(topNet,'psk16ValidOut',rate);

                symb16PSKVectorDemodNet=this.elab16PSKVectorSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symb16PSKVectorDemodNet.addComment('16PSK vector Demodulation');

                inports_psk16(1)=psk16DataInDelay;
                inports_psk16(2)=psk16ValidInDelay;

                outports_psk16(1)=psk16DataOut;
                outports_psk16(2)=psk16ValidOut;

                pirelab.instantiateNetwork(topNet,symb16PSKVectorDemodNet,inports_psk16,outports_psk16,'symb16PSKDemodNet_inst');

                if(blockInfo.NoiseVariance)
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,pirelab.createPirArrayType(outTypeNV,[4,0]),'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,pirelab.createPirArrayType(outTypeNV,[4,0]),'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        psk16dataDTC=newDataSignal(topNet,pirelab.createPirArrayType(divInpType,[4,0]),'psk16dataDTC',rate);
                        pirelab.getDTCComp(topNet,psk16DataOut,psk16dataDTC,'Zero','Saturate');
                        nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                        pirelab.getIntDelayComp(topNet,nVarIn,nVarInDelayed,9);
                        [divOut,latency]=nonRestoreDivision(topNet,psk16dataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,psk16ValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                    else
                        pirelab.getCompareToValueComp(topNet,psk16DataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,psk16ValidOut,validOut);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,psk16DataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,psk16DataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,psk16ValidOut,validOut);
                end


            case '32-PSK'
                psk32ValidInDelay=newControlSignal(topNet,'psk32ValidInDelay',rate);
                pirelab.getWireComp(topNet,validIn,psk32ValidInDelay);
                psk32DataInDelay=newDataSignal(topNet,inType,'psk16DataInDelay',rate);
                pirelab.getDTCComp(topNet,dataIn,psk32DataInDelay);


                psk32DataOut=newDataSignal(topNet,pirelab.createPirArrayType(outType,[5,0]),'psk32DataOut',rate);
                psk32ValidOut=newControlSignal(topNet,'psk32ValidOut',rate);

                symb32PSKVectorDemodNet=this.elab32PSKVectorSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symb32PSKVectorDemodNet.addComment('32PSK vector Demodulation');

                inports_psk32(1)=psk32DataInDelay;
                inports_psk32(2)=psk32ValidInDelay;

                outports_psk32(1)=psk32DataOut;
                outports_psk32(2)=psk32ValidOut;

                pirelab.instantiateNetwork(topNet,symb32PSKVectorDemodNet,inports_psk32,outports_psk32,'symb32PSKDemodNet_inst');

                if(blockInfo.NoiseVariance)
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,pirelab.createPirArrayType(outTypeNV,[5,0]),'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,pirelab.createPirArrayType(outTypeNV,[5,0]),'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        psk32dataDTC=newDataSignal(topNet,pirelab.createPirArrayType(divInpType,[5,0]),'psk32dataDTC',rate);
                        pirelab.getDTCComp(topNet,psk32DataOut,psk32dataDTC,'Zero','Saturate');
                        nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                        pirelab.getIntDelayComp(topNet,nVarIn,nVarInDelayed,11);
                        [divOut,latency]=nonRestoreDivision(topNet,psk32dataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,psk32ValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                    else
                        pirelab.getCompareToValueComp(topNet,psk32DataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,psk32ValidOut,validOut);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,psk32DataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,psk32DataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,psk32ValidOut,validOut);
                end


            case '16-QAM'
                qam16ValidInDelay=newControlSignal(topNet,'qam16ValidInDelay',rate);
                pirelab.getWireComp(topNet,validIn,qam16ValidInDelay);
                qam16dataInDelay=newDataSignal(topNet,inType,'qam16dataInDelay',rate);
                pirelab.getDTCComp(topNet,dataIn,qam16dataInDelay);


                qam16DataOut=newDataSignal(topNet,pirelab.createPirArrayType(outType,[4,0]),'qam16DataOut',rate);
                qam16ValidOut=newControlSignal(topNet,'qam16ValidOut',rate);

                symb16QAMVectorDemodNet=this.elab16QAMVectorSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symb16QAMVectorDemodNet.addComment('16QAM vector Demodulation');

                inports_qam16(1)=qam16dataInDelay;
                inports_qam16(2)=qam16ValidInDelay;

                outports_qam16(1)=qam16DataOut;
                outports_qam16(2)=qam16ValidOut;

                pirelab.instantiateNetwork(topNet,symb16QAMVectorDemodNet,inports_qam16,outports_qam16,'symb16QAMDemodNet_inst');

                if(blockInfo.NoiseVariance)
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,pirelab.createPirArrayType(outTypeNV,[4,0]),'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,pirelab.createPirArrayType(outTypeNV,[4,0]),'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        qam16dataDTC=newDataSignal(topNet,pirelab.createPirArrayType(divInpType,[4,0]),'qam16dataDTC',rate);
                        pirelab.getDTCComp(topNet,qam16DataOut,qam16dataDTC,'Zero','Saturate');
                        nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                        pirelab.getIntDelayComp(topNet,nVarIn,nVarInDelayed,6);
                        [divOut,latency]=nonRestoreDivision(topNet,qam16dataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,qam16ValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                    else
                        pirelab.getCompareToValueComp(topNet,qam16DataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,qam16ValidOut,validOut);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,qam16DataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,qam16DataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,qam16ValidOut,validOut);
                end


            case '64-QAM'
                qam64ValidInDelay=newControlSignal(topNet,'qam64ValidInDelay',rate);
                pirelab.getWireComp(topNet,validIn,qam64ValidInDelay);
                qam64dataInDelay=newDataSignal(topNet,inType,'qam64dataInDelay',rate);
                pirelab.getDTCComp(topNet,dataIn,qam64dataInDelay);


                qam64DataOut=newDataSignal(topNet,pirelab.createPirArrayType(outType,[6,0]),'qam64DataOut',rate);
                qam64ValidOut=newControlSignal(topNet,'qam64ValidOut',rate);

                symb64QAMVectorDemodNet=this.elab64QAMVectorSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symb64QAMVectorDemodNet.addComment('64QAM vector Demodulation');

                inports_qam64(1)=qam64dataInDelay;
                inports_qam64(2)=qam64ValidInDelay;

                outports_qam64(1)=qam64DataOut;
                outports_qam64(2)=qam64ValidOut;

                pirelab.instantiateNetwork(topNet,symb64QAMVectorDemodNet,inports_qam64,outports_qam64,'symb64QAMDemodNet_inst');

                if(blockInfo.NoiseVariance)
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,pirelab.createPirArrayType(outTypeNV,[6,0]),'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,pirelab.createPirArrayType(outTypeNV,[6,0]),'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        qam64dataDTC=newDataSignal(topNet,pirelab.createPirArrayType(divInpType,[6,0]),'qam64dataDTC',rate);
                        pirelab.getDTCComp(topNet,qam64DataOut,qam64dataDTC,'Zero','Saturate');
                        nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                        pirelab.getIntDelayComp(topNet,nVarIn,nVarInDelayed,11);
                        [divOut,latency]=nonRestoreDivision(topNet,qam64dataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,qam64ValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                    else
                        pirelab.getCompareToValueComp(topNet,qam64DataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,qam64ValidOut,validOut);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,qam64DataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,qam64DataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,qam64ValidOut,validOut);
                end


            otherwise
                qam256ValidInDelay=newControlSignal(topNet,'qam256ValidInDelay',rate);
                pirelab.getWireComp(topNet,validIn,qam256ValidInDelay);
                qam256dataInDelay=newDataSignal(topNet,inType,'qam256dataInDelay',rate);
                pirelab.getDTCComp(topNet,dataIn,qam256dataInDelay);


                qam256DataOut=newDataSignal(topNet,pirelab.createPirArrayType(outType,[8,0]),'qam256DataOut',rate);
                qam256ValidOut=newControlSignal(topNet,'qam256ValidOut',rate);

                symb256QAMVectorDemodNet=this.elab256QAMVectorSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symb256QAMVectorDemodNet.addComment('256QAM vector Demodulation');

                inports_qam256(1)=qam256dataInDelay;
                inports_qam256(2)=qam256ValidInDelay;

                outports_qam256(1)=qam256DataOut;
                outports_qam256(2)=qam256ValidOut;

                pirelab.instantiateNetwork(topNet,symb256QAMVectorDemodNet,inports_qam256,outports_qam256,'symb256QAMDemodNet_inst');

                if(blockInfo.NoiseVariance)
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,pirelab.createPirArrayType(outTypeNV,[8,0]),'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,pirelab.createPirArrayType(outTypeNV,[8,0]),'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        qam256dataDTC=newDataSignal(topNet,pirelab.createPirArrayType(divInpType,[8,0]),'qam256dataDTC',rate);
                        pirelab.getDTCComp(topNet,qam256DataOut,qam256dataDTC,'Zero','Saturate');
                        nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                        pirelab.getIntDelayComp(topNet,nVarIn,nVarInDelayed,11);
                        [divOut,latency]=nonRestoreDivision(topNet,qam256dataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,qam256ValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                    else
                        pirelab.getCompareToValueComp(topNet,qam256DataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,qam256ValidOut,validOut);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,qam256DataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,qam256DataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,qam256ValidOut,validOut);
                end


            end
        else

            switch(blockInfo.ModulationScheme)
            case 'BPSK'
                bpskValidInDelay=newControlSignal(topNet,'bpskValidInDelay',rate);
                pirelab.getWireComp(topNet,validIn,bpskValidInDelay);
                bpskdataInDelay=newDataSignal(topNet,inType,'bpskdataInDelay',rate);
                pirelab.getDTCComp(topNet,dataIn,bpskdataInDelay);


                bpskDataOut=newDataSignal(topNet,outType,'bpskDataOut',rate);
                bpskValidOut=newControlSignal(topNet,'bpskValidOut',rate);
                bpskReadyOut=newControlSignal(topNet,'bpskReadyOut',rate);

                symbBPSKScalarDemodNet=this.elabBPSKScalarSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symbBPSKScalarDemodNet.addComment('BPSK Scalar Demodulation');

                inports_bpsk(1)=bpskdataInDelay;
                inports_bpsk(2)=bpskValidInDelay;

                outports_bpsk(1)=bpskDataOut;
                outports_bpsk(2)=bpskValidOut;
                outports_bpsk(3)=bpskReadyOut;

                pirelab.instantiateNetwork(topNet,symbBPSKScalarDemodNet,inports_bpsk,outports_bpsk,'symbBPSKScalarDemodNet_inst');

                if(blockInfo.NoiseVariance)
                    bpskReadyDelay=newControlSignal(topNet,'bpskReadyDelay',rate);
                    dataValid=newControlSignal(topNet,'dataValid',rate);
                    nVarInSampled=newDataSignal(topNet,nVarType,'nVarInSampled',rate);
                    pirelab.getUnitDelayComp(topNet,bpskReadyOut,bpskReadyDelay,'',1);
                    pirelab.getLogicComp(topNet,[bpskReadyDelay,validIn],dataValid,'and');
                    pirelab.getUnitDelayEnabledComp(topNet,nVarIn,nVarInSampled,dataValid);
                    nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                    pirelab.getIntDelayComp(topNet,nVarInSampled,nVarInDelayed,4);
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,outTypeNV,'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,outTypeNV,'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        bpskdataDTC=newDataSignal(topNet,divInpType,'bpskdataDTC',rate);
                        pirelab.getDTCComp(topNet,bpskDataOut,bpskdataDTC,'Zero','Saturate');
                        [divOut,latency]=nonRestoreDivision(topNet,bpskdataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,bpskValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                    else
                        pirelab.getCompareToValueComp(topNet,bpskDataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,bpskValidOut,validOut);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,bpskDataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,bpskDataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,bpskValidOut,validOut);
                end

                pirelab.getWireComp(topNet,bpskReadyOut,readyOut);


            case 'QPSK'
                qpskValidInDelay=newControlSignal(topNet,'qpskValidInDelay',rate);
                pirelab.getWireComp(topNet,validIn,qpskValidInDelay);
                qpskdataInDelay=newDataSignal(topNet,inType,'qpskdataInDelay',rate);
                pirelab.getDTCComp(topNet,dataIn,qpskdataInDelay);


                qpskDataOut=newDataSignal(topNet,outType,'qpskDataOut',rate);
                qpskValidOut=newControlSignal(topNet,'qpskValidOut',rate);
                qpskReadyOut=newControlSignal(topNet,'qpskReadyOut',rate);

                symbQPSKScalarDemodNet=this.elabQPSKScalarSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symbQPSKScalarDemodNet.addComment('QPSK Scalar Demodulation');

                inports_qpsk(1)=qpskdataInDelay;
                inports_qpsk(2)=qpskValidInDelay;

                outports_qpsk(1)=qpskDataOut;
                outports_qpsk(2)=qpskValidOut;
                outports_qpsk(3)=qpskReadyOut;

                pirelab.instantiateNetwork(topNet,symbQPSKScalarDemodNet,inports_qpsk,outports_qpsk,'symbQPSKScalarDemodNet_inst');

                if(blockInfo.NoiseVariance)
                    qpskReadyDelay=newControlSignal(topNet,'qpskReadyDelay',rate);
                    dataValid=newControlSignal(topNet,'dataValid',rate);
                    nVarInSampled=newDataSignal(topNet,nVarType,'nVarInSampled',rate);
                    pirelab.getUnitDelayComp(topNet,qpskReadyOut,qpskReadyDelay,'',1);
                    pirelab.getLogicComp(topNet,[qpskReadyDelay,validIn],dataValid,'and');
                    pirelab.getUnitDelayEnabledComp(topNet,nVarIn,nVarInSampled,dataValid);
                    nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                    pirelab.getIntDelayComp(topNet,nVarInSampled,nVarInDelayed,6);
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,outTypeNV,'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,outTypeNV,'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        qpskdataDTC=newDataSignal(topNet,divInpType,'qpskdataDTC',rate);
                        pirelab.getDTCComp(topNet,qpskDataOut,qpskdataDTC,'Zero','Saturate');
                        [divOut,latency]=nonRestoreDivision(topNet,qpskdataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,qpskValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                    else
                        pirelab.getCompareToValueComp(topNet,qpskDataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,qpskValidOut,validOut);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,qpskDataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,qpskDataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,qpskValidOut,validOut);
                end

                pirelab.getWireComp(topNet,qpskReadyOut,readyOut);


            case '8-PSK'
                psk8ValidInDelay=newControlSignal(topNet,'psk8ValidInDelay',rate);
                pirelab.getWireComp(topNet,validIn,psk8ValidInDelay);
                psk8dataInDelay=newDataSignal(topNet,inType,'psk8dataInDelay',rate);
                pirelab.getDTCComp(topNet,dataIn,psk8dataInDelay);


                psk8DataOut=newDataSignal(topNet,outType,'psk8DataOut',rate);
                psk8ValidOut=newControlSignal(topNet,'psk8ValidOut',rate);
                psk8ReadyOut=newControlSignal(topNet,'psk8ReadyOut',rate);

                symb8PSKScalarDemodNet=this.elab8PSKScalarSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symb8PSKScalarDemodNet.addComment('8PSK Scalar Demodulation');

                inports_psk8(1)=psk8dataInDelay;
                inports_psk8(2)=psk8ValidInDelay;

                outports_psk8(1)=psk8DataOut;
                outports_psk8(2)=psk8ValidOut;
                outports_psk8(3)=psk8ReadyOut;

                pirelab.instantiateNetwork(topNet,symb8PSKScalarDemodNet,inports_psk8,outports_psk8,'symb8PSKScalarDemodNet_inst');


                if(blockInfo.NoiseVariance)
                    psk8ReadyDelay=newControlSignal(topNet,'psk8ReadyDelay',rate);
                    dataValid=newControlSignal(topNet,'dataValid',rate);
                    nVarInSampled=newDataSignal(topNet,nVarType,'nVarInSampled',rate);
                    pirelab.getUnitDelayComp(topNet,psk8ReadyOut,psk8ReadyDelay,'',1);
                    pirelab.getLogicComp(topNet,[psk8ReadyDelay,validIn],dataValid,'and');
                    pirelab.getUnitDelayEnabledComp(topNet,nVarIn,nVarInSampled,dataValid);
                    nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                    pirelab.getIntDelayComp(topNet,nVarInSampled,nVarInDelayed,6);
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,outTypeNV,'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,outTypeNV,'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        psk8dataDTC=newDataSignal(topNet,divInpType,'psk8dataDTC',rate);
                        pirelab.getDTCComp(topNet,psk8DataOut,psk8dataDTC,'Zero','Saturate');
                        [divOut,latency]=nonRestoreDivision(topNet,psk8dataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,psk8ValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                    else
                        pirelab.getCompareToValueComp(topNet,psk8DataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,psk8ValidOut,validOut);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,psk8DataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,psk8DataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,psk8ValidOut,validOut);
                end

                pirelab.getWireComp(topNet,psk8ReadyOut,readyOut);


            case '16-PSK'
                psk16ValidInDelay=newControlSignal(topNet,'psk16ValidInDelay',rate);
                pirelab.getWireComp(topNet,validIn,psk16ValidInDelay);
                psk16dataInDelay=newDataSignal(topNet,inType,'psk16dataInDelay',rate);
                pirelab.getDTCComp(topNet,dataIn,psk16dataInDelay);


                psk16DataOut=newDataSignal(topNet,outType,'psk16DataOut',rate);
                psk16ValidOut=newControlSignal(topNet,'psk16ValidOut',rate);
                psk16ReadyOut=newControlSignal(topNet,'psk16ReadyOut',rate);

                symb16PSKScalarDemodNet=this.elab16PSKScalarSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symb16PSKScalarDemodNet.addComment('16PSK Scalar Demodulation');

                inports_psk16(1)=psk16dataInDelay;
                inports_psk16(2)=psk16ValidInDelay;

                outports_psk16(1)=psk16DataOut;
                outports_psk16(2)=psk16ValidOut;
                outports_psk16(3)=psk16ReadyOut;

                pirelab.instantiateNetwork(topNet,symb16PSKScalarDemodNet,inports_psk16,outports_psk16,'symb16PSKScalarDemodNet_inst');

                if(blockInfo.NoiseVariance)
                    psk16ReadyDelay=newControlSignal(topNet,'psk16ReadyDelay',rate);
                    dataValid=newControlSignal(topNet,'dataValid',rate);
                    nVarInSampled=newDataSignal(topNet,nVarType,'nVarInSampled',rate);
                    pirelab.getUnitDelayComp(topNet,psk16ReadyOut,psk16ReadyDelay,'',1);
                    pirelab.getLogicComp(topNet,[psk16ReadyDelay,validIn],dataValid,'and');
                    pirelab.getUnitDelayEnabledComp(topNet,nVarIn,nVarInSampled,dataValid);
                    nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                    pirelab.getIntDelayComp(topNet,nVarInSampled,nVarInDelayed,8);
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,outTypeNV,'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,outTypeNV,'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        psk16dataDTC=newDataSignal(topNet,divInpType,'psk16dataDTC',rate);
                        pirelab.getDTCComp(topNet,psk16DataOut,psk16dataDTC,'Zero','Saturate');
                        [divOut,latency]=nonRestoreDivision(topNet,psk16dataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,psk16ValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                    else
                        pirelab.getCompareToValueComp(topNet,psk16DataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,psk16ValidOut,validOut);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,psk16DataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,psk16DataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,psk16ValidOut,validOut);
                end

                pirelab.getWireComp(topNet,psk16ReadyOut,readyOut);


            case '32-PSK'
                psk32ValidInDelay=newControlSignal(topNet,'psk32ValidInDelay',rate);
                pirelab.getWireComp(topNet,validIn,psk32ValidInDelay);
                psk32dataInDelay=newDataSignal(topNet,inType,'psk32dataInDelay',rate);
                pirelab.getDTCComp(topNet,dataIn,psk32dataInDelay);


                psk32DataOut=newDataSignal(topNet,outType,'psk32DataOut',rate);
                psk32ValidOut=newControlSignal(topNet,'psk32ValidOut',rate);
                psk32ReadyOut=newControlSignal(topNet,'psk32ReadyOut',rate);

                symb32PSKScalarDemodNet=this.elab32PSKScalarSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symb32PSKScalarDemodNet.addComment('32PSK Scalar Demodulation');

                inports_psk32(1)=psk32dataInDelay;
                inports_psk32(2)=psk32ValidInDelay;

                outports_psk32(1)=psk32DataOut;
                outports_psk32(2)=psk32ValidOut;
                outports_psk32(3)=psk32ReadyOut;

                pirelab.instantiateNetwork(topNet,symb32PSKScalarDemodNet,inports_psk32,outports_psk32,'symb32PSKScalarDemodNet_inst');

                if(blockInfo.NoiseVariance)
                    psk32ReadyDelay=newControlSignal(topNet,'psk32ReadyDelay',rate);
                    dataValid=newControlSignal(topNet,'dataValid',rate);
                    nVarInSampled=newDataSignal(topNet,nVarType,'nVarInSampled',rate);
                    pirelab.getUnitDelayComp(topNet,psk32ReadyOut,psk32ReadyDelay,'',1);
                    pirelab.getLogicComp(topNet,[psk32ReadyDelay,validIn],dataValid,'and');
                    pirelab.getUnitDelayEnabledComp(topNet,nVarIn,nVarInSampled,dataValid);
                    nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                    pirelab.getIntDelayComp(topNet,nVarInSampled,nVarInDelayed,11);
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,outTypeNV,'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,outTypeNV,'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        psk32dataDTC=newDataSignal(topNet,divInpType,'psk32dataDTC',rate);
                        pirelab.getDTCComp(topNet,psk32DataOut,psk32dataDTC,'Zero','Saturate');
                        [divOut,latency]=nonRestoreDivision(topNet,psk32dataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,psk32ValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                    else
                        pirelab.getCompareToValueComp(topNet,psk32DataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,psk32ValidOut,validOut);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,psk32DataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,psk32DataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,psk32ValidOut,validOut);
                end

                pirelab.getWireComp(topNet,psk32ReadyOut,readyOut);


            case '16-QAM'
                qam16ValidInDelay=newControlSignal(topNet,'qam16ValidInDelay',rate);
                pirelab.getWireComp(topNet,validIn,qam16ValidInDelay);
                qam16dataInDelay=newDataSignal(topNet,inType,'qam16dataInDelay',rate);
                pirelab.getDTCComp(topNet,dataIn,qam16dataInDelay);


                qam16DataOut=newDataSignal(topNet,outType,'qam16DataOut',rate);
                qam16ValidOut=newControlSignal(topNet,'qam16ValidOut',rate);
                qam16ReadyOut=newControlSignal(topNet,'qam16ReadyOut',rate);

                symb16QAMScalarDemodNet=this.elab16QAMScalarSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symb16QAMScalarDemodNet.addComment('16QAM Scalar Demodulation');

                inports_qam16(1)=qam16dataInDelay;
                inports_qam16(2)=qam16ValidInDelay;

                outports_qam16(1)=qam16DataOut;
                outports_qam16(2)=qam16ValidOut;
                outports_qam16(3)=qam16ReadyOut;

                pirelab.instantiateNetwork(topNet,symb16QAMScalarDemodNet,inports_qam16,outports_qam16,'symb16QAMScalarDemodNet_inst');

                if(blockInfo.NoiseVariance)
                    qam16ReadyDelay=newControlSignal(topNet,'qam16ReadyDelay',rate);
                    dataValid=newControlSignal(topNet,'dataValid',rate);
                    nVarInSampled=newDataSignal(topNet,nVarType,'nVarInSampled',rate);
                    pirelab.getUnitDelayComp(topNet,qam16ReadyOut,qam16ReadyDelay,'',1);
                    pirelab.getLogicComp(topNet,[qam16ReadyDelay,validIn],dataValid,'and');
                    pirelab.getUnitDelayEnabledComp(topNet,nVarIn,nVarInSampled,dataValid);
                    nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                    pirelab.getIntDelayComp(topNet,nVarInSampled,nVarInDelayed,10);
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,outTypeNV,'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,outTypeNV,'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        qam16dataDTC=newDataSignal(topNet,divInpType,'qam16dataDTC',rate);
                        pirelab.getDTCComp(topNet,qam16DataOut,qam16dataDTC,'Zero','Saturate');
                        [divOut,latency]=nonRestoreDivision(topNet,qam16dataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,qam16ValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                    else
                        pirelab.getCompareToValueComp(topNet,qam16DataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,qam16ValidOut,validOut);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,qam16DataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,qam16DataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,qam16ValidOut,validOut);
                end

                pirelab.getWireComp(topNet,qam16ReadyOut,readyOut);


            case '64-QAM'
                qam64ValidInDelay=newControlSignal(topNet,'qam64ValidInDelay',rate);
                pirelab.getWireComp(topNet,validIn,qam64ValidInDelay);
                qam64dataInDelay=newDataSignal(topNet,inType,'qam64dataInDelay',rate);
                pirelab.getDTCComp(topNet,dataIn,qam64dataInDelay);


                qam64DataOut=newDataSignal(topNet,outType,'qam64DataOut',rate);
                qam64ValidOut=newControlSignal(topNet,'qam64ValidOut',rate);
                qam64ReadyOut=newControlSignal(topNet,'qam64ReadyOut',rate);

                symb64QAMScalarDemodNet=this.elab64QAMScalarSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symb64QAMScalarDemodNet.addComment('64QAM Scalar Demodulation');

                inports_qam64(1)=qam64dataInDelay;
                inports_qam64(2)=qam64ValidInDelay;

                outports_qam64(1)=qam64DataOut;
                outports_qam64(2)=qam64ValidOut;
                outports_qam64(3)=qam64ReadyOut;

                pirelab.instantiateNetwork(topNet,symb64QAMScalarDemodNet,inports_qam64,outports_qam64,'symb64QAMScalarDemodNet_inst');

                if(blockInfo.NoiseVariance)
                    qam64ReadyDelay=newControlSignal(topNet,'qam64ReadyDelay',rate);
                    dataValid=newControlSignal(topNet,'dataValid',rate);
                    nVarInSampled=newDataSignal(topNet,nVarType,'nVarInSampled',rate);
                    pirelab.getUnitDelayComp(topNet,qam64ReadyOut,qam64ReadyDelay,'',1);
                    pirelab.getLogicComp(topNet,[qam64ReadyDelay,validIn],dataValid,'and');
                    pirelab.getUnitDelayEnabledComp(topNet,nVarIn,nVarInSampled,dataValid);
                    nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                    pirelab.getIntDelayComp(topNet,nVarInSampled,nVarInDelayed,14);
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,outTypeNV,'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,outTypeNV,'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        qam64dataDTC=newDataSignal(topNet,divInpType,'qam64dataDTC',rate);
                        pirelab.getDTCComp(topNet,qam64DataOut,qam64dataDTC,'Zero','Saturate');
                        [divOut,latency]=nonRestoreDivision(topNet,qam64dataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,qam64ValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                    else
                        pirelab.getCompareToValueComp(topNet,qam64DataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,qam64ValidOut,validOut);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,qam64DataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,qam64DataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,qam64ValidOut,validOut);
                end

                pirelab.getWireComp(topNet,qam64ReadyOut,readyOut);


            otherwise
                qam256ValidInDelay=newControlSignal(topNet,'qam256ValidInDelay',rate);
                pirelab.getWireComp(topNet,validIn,qam256ValidInDelay);
                qam256dataInDelay=newDataSignal(topNet,inType,'qam256dataInDelay',rate);
                pirelab.getDTCComp(topNet,dataIn,qam256dataInDelay);


                qam256DataOut=newDataSignal(topNet,outType,'qam256DataOut',rate);
                qam256ValidOut=newControlSignal(topNet,'qam256ValidOut',rate);
                qam256ReadyOut=newControlSignal(topNet,'qam256ReadyOut',rate);

                symb256QAMScalarDemodNet=this.elab256QAMScalarSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symb256QAMScalarDemodNet.addComment('256QAM Scalar Demodulation');

                inports_qam256(1)=qam256dataInDelay;
                inports_qam256(2)=qam256ValidInDelay;

                outports_qam256(1)=qam256DataOut;
                outports_qam256(2)=qam256ValidOut;
                outports_qam256(3)=qam256ReadyOut;

                pirelab.instantiateNetwork(topNet,symb256QAMScalarDemodNet,inports_qam256,outports_qam256,'symb256QAMScalarDemodNet_inst');

                if(blockInfo.NoiseVariance)
                    qam256ReadyDelay=newControlSignal(topNet,'qam256ReadyDelay',rate);
                    dataValid=newControlSignal(topNet,'dataValid',rate);
                    nVarInSampled=newDataSignal(topNet,nVarType,'nVarInSampled',rate);
                    pirelab.getUnitDelayComp(topNet,qam256ReadyOut,qam256ReadyDelay,'',1);
                    pirelab.getLogicComp(topNet,[qam256ReadyDelay,validIn],dataValid,'and');
                    pirelab.getUnitDelayEnabledComp(topNet,nVarIn,nVarInSampled,dataValid);
                    nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                    pirelab.getIntDelayComp(topNet,nVarInSampled,nVarInDelayed,14);
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,outTypeNV,'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,outTypeNV,'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        qam256dataDTC=newDataSignal(topNet,divInpType,'qam256dataDTC',rate);
                        pirelab.getDTCComp(topNet,qam256DataOut,qam256dataDTC,'Zero','Saturate');
                        [divOut,latency]=nonRestoreDivision(topNet,qam256dataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,qam256ValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                    else
                        pirelab.getCompareToValueComp(topNet,qam256DataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,qam256ValidOut,validOut);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,qam256DataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,qam256DataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,qam256ValidOut,validOut);
                end

                pirelab.getWireComp(topNet,qam256ReadyOut,readyOut);


            end
        end
    else

        if(strcmpi(blockInfo.OutputType,'Scalar'))
            switch(blockInfo.MaxModulation)
            case 'BPSK'
                bpskValidInDelay=newControlSignal(topNet,'bpskValidInDelay',rate);
                pirelab.getWireComp(topNet,validIn,bpskValidInDelay);
                bpskdataInDelay=newDataSignal(topNet,inType,'bpskdataInDelay',rate);
                pirelab.getDTCComp(topNet,dataIn,bpskdataInDelay);
                bpskmodSelInDelay=newDataSignal(topNet,pir_ufixpt_t(3,0),'bpskmodSelInDelay',rate);
                pirelab.getWireComp(topNet,modSelInDelay,bpskmodSelInDelay);


                bpskDataOut=newDataSignal(topNet,outType,'bpskDataOut',rate);
                bpskValidOut=newControlSignal(topNet,'bpskValidOut',rate);
                bpskReadyOut=newControlSignal(topNet,'bpskReadyOut',rate);

                symbBPSKmaxScalarDemodNet=this.elabMaxModBPSKScalarSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symbBPSKmaxScalarDemodNet.addComment('Input port BPSK maxModulation Scalar output');

                inports_bpsk(1)=bpskdataInDelay;
                inports_bpsk(2)=bpskValidInDelay;
                inports_bpsk(3)=bpskmodSelInDelay;

                outports_bpsk(1)=bpskDataOut;
                outports_bpsk(2)=bpskValidOut;
                outports_bpsk(3)=bpskReadyOut;

                pirelab.instantiateNetwork(topNet,symbBPSKmaxScalarDemodNet,inports_bpsk,outports_bpsk,'symbBPSKmaxScalarDemodNet_inst');

                if(blockInfo.NoiseVariance)
                    bpskReadyDelay=newControlSignal(topNet,'bpskReadyDelay',rate);
                    dataValid=newControlSignal(topNet,'dataValid',rate);
                    nVarInSampled=newDataSignal(topNet,nVarType,'nVarInSampled',rate);
                    pirelab.getUnitDelayComp(topNet,bpskReadyOut,bpskReadyDelay,'',1);
                    pirelab.getLogicComp(topNet,[bpskReadyDelay,validIn],dataValid,'and');
                    pirelab.getUnitDelayEnabledComp(topNet,nVarIn,nVarInSampled,dataValid);
                    nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                    pirelab.getIntDelayComp(topNet,nVarInSampled,nVarInDelayed,4);
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,outTypeNV,'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,outTypeNV,'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        bpskdataDTC=newDataSignal(topNet,divInpType,'bpskdataDTC',rate);
                        pirelab.getDTCComp(topNet,bpskDataOut,bpskdataDTC,'Zero','Saturate');
                        [divOut,latency]=nonRestoreDivision(topNet,bpskdataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,bpskValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                    else
                        pirelab.getCompareToValueComp(topNet,bpskDataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,bpskValidOut,validOut);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,bpskDataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,bpskDataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,bpskValidOut,validOut);
                end

                pirelab.getWireComp(topNet,bpskReadyOut,readyOut);


            case 'QPSK'
                qpskValidInDelay=newControlSignal(topNet,'qpskValidInDelay',rate);
                pirelab.getWireComp(topNet,validIn,qpskValidInDelay);
                qpskdataInDelay=newDataSignal(topNet,inType,'qpskdataInDelay',rate);
                pirelab.getDTCComp(topNet,dataIn,qpskdataInDelay);
                qpskmodSelInDelay=newDataSignal(topNet,pir_ufixpt_t(3,0),'qpskmodSelInDelay',rate);
                pirelab.getWireComp(topNet,modSelInDelay,qpskmodSelInDelay);


                qpskDataOut=newDataSignal(topNet,outType,'qpskDataOut',rate);
                qpskValidOut=newControlSignal(topNet,'qpskValidOut',rate);
                qpskReadyOut=newControlSignal(topNet,'qpskReadyOut',rate);

                symbQPSKmaxScalarDemodNet=this.elabMaxModQPSKScalarSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symbQPSKmaxScalarDemodNet.addComment('Input port QPSK maxModulation Scalar output');

                inports_qpsk(1)=qpskdataInDelay;
                inports_qpsk(2)=qpskValidInDelay;
                inports_qpsk(3)=qpskmodSelInDelay;

                outports_qpsk(1)=qpskDataOut;
                outports_qpsk(2)=qpskValidOut;
                outports_qpsk(3)=qpskReadyOut;

                pirelab.instantiateNetwork(topNet,symbQPSKmaxScalarDemodNet,inports_qpsk,outports_qpsk,'symbQPSKmaxScalarDemodNet_inst');

                if(blockInfo.NoiseVariance)
                    qpskReadyDelay=newControlSignal(topNet,'qpskReadyDelay',rate);
                    dataValid=newControlSignal(topNet,'dataValid',rate);
                    nVarInSampled=newDataSignal(topNet,nVarType,'nVarInSampled',rate);
                    pirelab.getUnitDelayComp(topNet,qpskReadyOut,qpskReadyDelay,'',1);
                    pirelab.getLogicComp(topNet,[qpskReadyDelay,validIn],dataValid,'and');
                    pirelab.getUnitDelayEnabledComp(topNet,nVarIn,nVarInSampled,dataValid);
                    nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                    pirelab.getIntDelayComp(topNet,nVarInSampled,nVarInDelayed,7);
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,outTypeNV,'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,outTypeNV,'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        qpskdataDTC=newDataSignal(topNet,divInpType,'qpskdataDTC',rate);
                        pirelab.getDTCComp(topNet,qpskDataOut,qpskdataDTC,'Zero','Saturate');
                        [divOut,latency]=nonRestoreDivision(topNet,qpskdataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,qpskValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                    else
                        pirelab.getCompareToValueComp(topNet,qpskDataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,qpskValidOut,validOut);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,qpskDataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,qpskDataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,qpskValidOut,validOut);
                end

                pirelab.getWireComp(topNet,qpskReadyOut,readyOut);


            case '8-PSK'
                psk8ValidInDelay=newControlSignal(topNet,'psk8ValidInDelay',rate);
                pirelab.getWireComp(topNet,validIn,psk8ValidInDelay);
                psk8dataInDelay=newDataSignal(topNet,inType,'psk8dataInDelay',rate);
                pirelab.getDTCComp(topNet,dataIn,psk8dataInDelay);
                psk8modSelInDelay=newDataSignal(topNet,pir_ufixpt_t(3,0),'psk8modSelInDelay',rate);
                pirelab.getWireComp(topNet,modSelInDelay,psk8modSelInDelay);


                psk8DataOut=newDataSignal(topNet,outType,'psk8DataOut',rate);
                psk8ValidOut=newControlSignal(topNet,'psk8ValidOut',rate);
                psk8ReadyOut=newControlSignal(topNet,'psk8ReadyOut',rate);

                symb8PSKmaxScalarDemodNet=this.elabMaxMod8PSKScalarSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symb8PSKmaxScalarDemodNet.addComment('Input port 8PSK maxModulation Scalar output');

                inports_psk8(1)=psk8dataInDelay;
                inports_psk8(2)=psk8ValidInDelay;
                inports_psk8(3)=psk8modSelInDelay;

                outports_psk8(1)=psk8DataOut;
                outports_psk8(2)=psk8ValidOut;
                outports_psk8(3)=psk8ReadyOut;

                pirelab.instantiateNetwork(topNet,symb8PSKmaxScalarDemodNet,inports_psk8,outports_psk8,'symb8PSKmaxScalarDemodNet_inst');

                if(blockInfo.NoiseVariance)
                    psk8ReadyDelay=newControlSignal(topNet,'psk8ReadyDelay',rate);
                    dataValid=newControlSignal(topNet,'dataValid',rate);
                    nVarInSampled=newDataSignal(topNet,nVarType,'nVarInSampled',rate);
                    pirelab.getUnitDelayComp(topNet,psk8ReadyOut,psk8ReadyDelay,'',1);
                    pirelab.getLogicComp(topNet,[psk8ReadyDelay,validIn],dataValid,'and');
                    pirelab.getUnitDelayEnabledComp(topNet,nVarIn,nVarInSampled,dataValid);
                    nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                    pirelab.getIntDelayComp(topNet,nVarInSampled,nVarInDelayed,7);
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,outTypeNV,'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,outTypeNV,'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        psk8dataDTC=newDataSignal(topNet,divInpType,'psk8dataDTC',rate);
                        pirelab.getDTCComp(topNet,psk8DataOut,psk8dataDTC,'Zero','Saturate');
                        [divOut,latency]=nonRestoreDivision(topNet,psk8dataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,psk8ValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                    else
                        pirelab.getCompareToValueComp(topNet,psk8DataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,psk8ValidOut,validOut);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,psk8DataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,psk8DataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,psk8ValidOut,validOut);
                end

                pirelab.getWireComp(topNet,psk8ReadyOut,readyOut);

            case '16-PSK'
                psk16ValidInDelay=newControlSignal(topNet,'psk16ValidInDelay',rate);
                pirelab.getWireComp(topNet,validIn,psk16ValidInDelay);
                psk16dataInDelay=newDataSignal(topNet,inType,'psk16dataInDelay',rate);
                pirelab.getDTCComp(topNet,dataIn,psk16dataInDelay);
                psk16modSelInDelay=newDataSignal(topNet,pir_ufixpt_t(3,0),'psk16modSelInDelay',rate);
                pirelab.getWireComp(topNet,modSelInDelay,psk16modSelInDelay);


                psk16DataOut=newDataSignal(topNet,outType,'psk16DataOut',rate);
                psk16ValidOut=newControlSignal(topNet,'psk16ValidOut',rate);
                psk16ReadyOut=newControlSignal(topNet,'psk16ReadyOut',rate);

                symb16PSKmaxScalarDemodNet=this.elabMaxMod16PSKScalarSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symb16PSKmaxScalarDemodNet.addComment('Input port 16PSK maxModulation Scalar output');

                inports_psk16(1)=psk16dataInDelay;
                inports_psk16(2)=psk16ValidInDelay;
                inports_psk16(3)=psk16modSelInDelay;

                outports_psk16(1)=psk16DataOut;
                outports_psk16(2)=psk16ValidOut;
                outports_psk16(3)=psk16ReadyOut;

                pirelab.instantiateNetwork(topNet,symb16PSKmaxScalarDemodNet,inports_psk16,outports_psk16,'symb16PSKmaxScalarDemodNet_inst');

                if(blockInfo.NoiseVariance)
                    psk16ReadyDelay=newControlSignal(topNet,'psk16ReadyDelay',rate);
                    dataValid=newControlSignal(topNet,'dataValid',rate);
                    nVarInSampled=newDataSignal(topNet,nVarType,'nVarInSampled',rate);
                    pirelab.getUnitDelayComp(topNet,psk16ReadyOut,psk16ReadyDelay,'',1);
                    pirelab.getLogicComp(topNet,[psk16ReadyDelay,validIn],dataValid,'and');
                    pirelab.getUnitDelayEnabledComp(topNet,nVarIn,nVarInSampled,dataValid);
                    nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                    pirelab.getIntDelayComp(topNet,nVarInSampled,nVarInDelayed,9);
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,outTypeNV,'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,outTypeNV,'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        psk16dataDTC=newDataSignal(topNet,divInpType,'psk16dataDTC',rate);
                        pirelab.getDTCComp(topNet,psk16DataOut,psk16dataDTC,'Zero','Saturate');
                        [divOut,latency]=nonRestoreDivision(topNet,psk16dataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,psk16ValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                    else
                        pirelab.getCompareToValueComp(topNet,psk16DataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,psk16ValidOut,validOut);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,psk16DataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,psk16DataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,psk16ValidOut,validOut);
                end

                pirelab.getWireComp(topNet,psk16ReadyOut,readyOut);

            case '32-PSK'
                psk32ValidInDelay=newControlSignal(topNet,'psk32ValidInDelay',rate);
                pirelab.getWireComp(topNet,validIn,psk32ValidInDelay);
                psk32dataInDelay=newDataSignal(topNet,inType,'psk32dataInDelay',rate);
                pirelab.getDTCComp(topNet,dataIn,psk32dataInDelay);
                psk32modSelInDelay=newDataSignal(topNet,pir_ufixpt_t(3,0),'psk32modSelInDelay',rate);
                pirelab.getWireComp(topNet,modSelInDelay,psk32modSelInDelay);


                psk32DataOut=newDataSignal(topNet,outType,'psk32DataOut',rate);
                psk32ValidOut=newControlSignal(topNet,'psk32ValidOut',rate);
                psk32ReadyOut=newControlSignal(topNet,'psk32ReadyOut',rate);

                symb32PSKmaxScalarDemodNet=this.elabMaxMod32PSKScalarSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symb32PSKmaxScalarDemodNet.addComment('Input port 32PSK maxModulation Scalar output');

                inports_psk32(1)=psk32dataInDelay;
                inports_psk32(2)=psk32ValidInDelay;
                inports_psk32(3)=psk32modSelInDelay;

                outports_psk32(1)=psk32DataOut;
                outports_psk32(2)=psk32ValidOut;
                outports_psk32(3)=psk32ReadyOut;

                pirelab.instantiateNetwork(topNet,symb32PSKmaxScalarDemodNet,inports_psk32,outports_psk32,'symb32PSKmaxScalarDemodNet_inst');

                if(blockInfo.NoiseVariance)
                    psk32ReadyDelay=newControlSignal(topNet,'psk32ReadyDelay',rate);
                    dataValid=newControlSignal(topNet,'dataValid',rate);
                    nVarInSampled=newDataSignal(topNet,nVarType,'nVarInSampled',rate);
                    pirelab.getUnitDelayComp(topNet,psk32ReadyOut,psk32ReadyDelay,'',1);
                    pirelab.getLogicComp(topNet,[psk32ReadyDelay,validIn],dataValid,'and');
                    pirelab.getUnitDelayEnabledComp(topNet,nVarIn,nVarInSampled,dataValid);
                    nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                    pirelab.getIntDelayComp(topNet,nVarInSampled,nVarInDelayed,11);
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,outTypeNV,'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,outTypeNV,'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        psk32dataDTC=newDataSignal(topNet,divInpType,'psk32dataDTC',rate);
                        pirelab.getDTCComp(topNet,psk32DataOut,psk32dataDTC,'Zero','Saturate');
                        [divOut,latency]=nonRestoreDivision(topNet,psk32dataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,psk32ValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                    else
                        pirelab.getCompareToValueComp(topNet,psk32DataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,psk32ValidOut,validOut);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,psk32DataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,psk32DataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,psk32ValidOut,validOut);
                end

                pirelab.getWireComp(topNet,psk32ReadyOut,readyOut);


            case '16-QAM'
                qam16ValidInDelay=newControlSignal(topNet,'qam16ValidInDelay',rate);
                pirelab.getWireComp(topNet,validIn,qam16ValidInDelay);
                qam16dataInDelay=newDataSignal(topNet,inType,'qam16dataInDelay',rate);
                pirelab.getDTCComp(topNet,dataIn,qam16dataInDelay);
                qam16modSelInDelay=newDataSignal(topNet,pir_ufixpt_t(3,0),'qam16modSelInDelay',rate);
                pirelab.getWireComp(topNet,modSelInDelay,qam16modSelInDelay);


                qam16DataOut=newDataSignal(topNet,outType,'qam16DataOut',rate);
                qam16ValidOut=newControlSignal(topNet,'qam16ValidOut',rate);
                qam16ReadyOut=newControlSignal(topNet,'qam16ReadyOut',rate);

                symb16QAMmaxScalarDemodNet=this.elabMaxMod16QAMScalarSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symb16QAMmaxScalarDemodNet.addComment('Input port 16QAM maxModulation Scalar output');

                inports_qam16(1)=qam16dataInDelay;
                inports_qam16(2)=qam16ValidInDelay;
                inports_qam16(3)=qam16modSelInDelay;

                outports_qam16(1)=qam16DataOut;
                outports_qam16(2)=qam16ValidOut;
                outports_qam16(3)=qam16ReadyOut;

                pirelab.instantiateNetwork(topNet,symb16QAMmaxScalarDemodNet,inports_qam16,outports_qam16,'symb16QAMmaxScalarDemodNet_inst');

                if(blockInfo.NoiseVariance)
                    qam16ReadyDelay=newControlSignal(topNet,'qam16ReadyDelay',rate);
                    dataValid=newControlSignal(topNet,'dataValid',rate);
                    nVarInSampled=newDataSignal(topNet,nVarType,'nVarInSampled',rate);
                    pirelab.getUnitDelayComp(topNet,qam16ReadyOut,qam16ReadyDelay,'',1);
                    pirelab.getLogicComp(topNet,[qam16ReadyDelay,validIn],dataValid,'and');
                    pirelab.getUnitDelayEnabledComp(topNet,nVarIn,nVarInSampled,dataValid);
                    nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                    pirelab.getIntDelayComp(topNet,nVarInSampled,nVarInDelayed,10);
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,outTypeNV,'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,outTypeNV,'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        qam16dataDTC=newDataSignal(topNet,divInpType,'qam16dataDTC',rate);
                        pirelab.getDTCComp(topNet,qam16DataOut,qam16dataDTC,'Zero','Saturate');
                        [divOut,latency]=nonRestoreDivision(topNet,qam16dataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,qam16ValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                    else
                        pirelab.getCompareToValueComp(topNet,qam16DataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,qam16ValidOut,validOut);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,qam16DataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,qam16DataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,qam16ValidOut,validOut);
                end

                pirelab.getWireComp(topNet,qam16ReadyOut,readyOut);


            case '64-QAM'
                qam64ValidInDelay=newControlSignal(topNet,'qam64ValidInDelay',rate);
                pirelab.getWireComp(topNet,validIn,qam64ValidInDelay);
                qam64dataInDelay=newDataSignal(topNet,inType,'qam64dataInDelay',rate);
                pirelab.getDTCComp(topNet,dataIn,qam64dataInDelay);
                qam64modSelInDelay=newDataSignal(topNet,pir_ufixpt_t(3,0),'qam64modSelInDelay',rate);
                pirelab.getWireComp(topNet,modSelInDelay,qam64modSelInDelay);


                qam64DataOut=newDataSignal(topNet,outType,'qam64DataOut',rate);
                qam64ValidOut=newControlSignal(topNet,'qam64ValidOut',rate);
                qam64ReadyOut=newControlSignal(topNet,'qam64ReadyOut',rate);

                symb64QAMmaxScalarDemodNet=this.elabMaxMod64QAMScalarSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symb64QAMmaxScalarDemodNet.addComment('Input port 64QAM maxModulation Scalar output');

                inports_qam64(1)=qam64dataInDelay;
                inports_qam64(2)=qam64ValidInDelay;
                inports_qam64(3)=qam64modSelInDelay;

                outports_qam64(1)=qam64DataOut;
                outports_qam64(2)=qam64ValidOut;
                outports_qam64(3)=qam64ReadyOut;

                pirelab.instantiateNetwork(topNet,symb64QAMmaxScalarDemodNet,inports_qam64,outports_qam64,'symb64QAMmaxScalarDemodNet_inst');

                if(blockInfo.NoiseVariance)
                    qam64ReadyDelay=newControlSignal(topNet,'qam64ReadyDelay',rate);
                    dataValid=newControlSignal(topNet,'dataValid',rate);
                    nVarInSampled=newDataSignal(topNet,nVarType,'nVarInSampled',rate);
                    pirelab.getUnitDelayComp(topNet,qam64ReadyOut,qam64ReadyDelay,'',1);
                    pirelab.getLogicComp(topNet,[qam64ReadyDelay,validIn],dataValid,'and');
                    pirelab.getUnitDelayEnabledComp(topNet,nVarIn,nVarInSampled,dataValid);
                    nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                    pirelab.getIntDelayComp(topNet,nVarInSampled,nVarInDelayed,14);
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,outTypeNV,'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,outTypeNV,'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        qam64dataDTC=newDataSignal(topNet,divInpType,'qam64dataDTC',rate);
                        pirelab.getDTCComp(topNet,qam64DataOut,qam64dataDTC,'Zero','Saturate');
                        [divOut,latency]=nonRestoreDivision(topNet,qam64dataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,qam64ValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                    else
                        pirelab.getCompareToValueComp(topNet,qam64DataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,qam64ValidOut,validOut);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,qam64DataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,qam64DataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,qam64ValidOut,validOut);
                end

                pirelab.getWireComp(topNet,qam64ReadyOut,readyOut);


            otherwise
                qam256ValidInDelay=newControlSignal(topNet,'qam256ValidInDelay',rate);
                pirelab.getWireComp(topNet,validIn,qam256ValidInDelay);
                qam256dataInDelay=newDataSignal(topNet,inType,'qam256dataInDelay',rate);
                pirelab.getDTCComp(topNet,dataIn,qam256dataInDelay);
                qam256modSelInDelay=newDataSignal(topNet,pir_ufixpt_t(3,0),'qam256modSelInDelay',rate);
                pirelab.getWireComp(topNet,modSelInDelay,qam256modSelInDelay);



                qam256DataOut=newDataSignal(topNet,outType,'qam256DataOut',rate);
                qam256ValidOut=newControlSignal(topNet,'qam256ValidOut',rate);
                qam256ReadyOut=newControlSignal(topNet,'qam256ReadyOut',rate);

                symb256QAMmaxScalarDemodNet=this.elabMaxMod256QAMScalarSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symb256QAMmaxScalarDemodNet.addComment('Input port 256QAM maxModulation Scalar output');

                inports_qam256(1)=qam256dataInDelay;
                inports_qam256(2)=qam256ValidInDelay;
                inports_qam256(3)=qam256modSelInDelay;

                outports_qam256(1)=qam256DataOut;
                outports_qam256(2)=qam256ValidOut;
                outports_qam256(3)=qam256ReadyOut;

                pirelab.instantiateNetwork(topNet,symb256QAMmaxScalarDemodNet,inports_qam256,outports_qam256,'symb256QAMmaxScalarDemodNet_inst');



                if(blockInfo.NoiseVariance)
                    qam256ReadyDelay=newControlSignal(topNet,'qam256ReadyDelay',rate);
                    dataValid=newControlSignal(topNet,'dataValid',rate);
                    nVarInSampled=newDataSignal(topNet,nVarType,'nVarInSampled',rate);
                    pirelab.getUnitDelayComp(topNet,qam256ReadyOut,qam256ReadyDelay,'',1);
                    pirelab.getLogicComp(topNet,[qam256ReadyDelay,validIn],dataValid,'and');
                    pirelab.getUnitDelayEnabledComp(topNet,nVarIn,nVarInSampled,dataValid);
                    nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                    pirelab.getIntDelayComp(topNet,nVarInSampled,nVarInDelayed,14);
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,outTypeNV,'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,outTypeNV,'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        qam256dataDTC=newDataSignal(topNet,divInpType,'qam256dataDTC',rate);
                        pirelab.getDTCComp(topNet,qam256DataOut,qam256dataDTC,'Zero','Saturate');
                        [divOut,latency]=nonRestoreDivision(topNet,qam256dataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,qam256ValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                    else
                        pirelab.getCompareToValueComp(topNet,qam256DataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,qam256ValidOut,validOut);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,qam256DataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,qam256DataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,qam256ValidOut,validOut);
                end

                pirelab.getWireComp(topNet,qam256ReadyOut,readyOut);


            end
        else
            startInp=newControlSignal(topNet,'startInp',rate);
            endInp=newControlSignal(topNet,'endInp',rate);
            validInp=newControlSignal(topNet,'validInp',rate);
            sampleControlNet=this.elabSampleControl(topNet,rate);
            sampleControlNet.addComment('Sample control for valid start and end');
            pirelab.instantiateNetwork(topNet,sampleControlNet,[startIn,endIn,validIn],[startInp,endInp,validInp],'sampleControlNet_inst');
            switch(blockInfo.MaxModulation)
            case 'BPSK'
                bpskDataIn=newDataSignal(topNet,inType,'bpskDataIn',rate);
                bpskValidIn=newControlSignal(topNet,'bpskValidIn',rate);
                pirelab.getWireComp(topNet,validInp,bpskValidIn);
                pirelab.getDTCComp(topNet,dataIn,bpskDataIn);


                bpskDataOut=newDataSignal(topNet,outType,'bpskDataOut',rate);
                bpskValidOut=newControlSignal(topNet,'bpskValidOut',rate);

                symbBPSKVectorDemodNet=this.elabBPSKVectorSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symbBPSKVectorDemodNet.addComment('BPSK vector Demodulation');

                inports_bpsk(1)=bpskDataIn;
                inports_bpsk(2)=bpskValidIn;

                outports_bpsk(1)=bpskDataOut;
                outports_bpsk(2)=bpskValidOut;

                pirelab.instantiateNetwork(topNet,symbBPSKVectorDemodNet,inports_bpsk,outports_bpsk,'symbBPSKDemodNet_inst');

                if(blockInfo.NoiseVariance)
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,outTypeNV,'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,outTypeNV,'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        bpskdataDTC=newDataSignal(topNet,divInpType,'bpskdataDTC',rate);
                        pirelab.getDTCComp(topNet,bpskDataOut,bpskdataDTC,'Zero','Saturate');
                        nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                        pirelab.getIntDelayComp(topNet,nVarIn,nVarInDelayed,6);
                        [divOut,latency]=nonRestoreDivision(topNet,bpskdataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,bpskValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                        pirelab.getIntDelayComp(topNet,endInp,endOut,latency+6);
                        pirelab.getIntDelayComp(topNet,startInp,startOut,latency+6);
                    else
                        pirelab.getCompareToValueComp(topNet,bpskDataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,bpskValidOut,validOut);
                        pirelab.getIntDelayComp(topNet,endInp,endOut,6);
                        pirelab.getIntDelayComp(topNet,startInp,startOut,6);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,bpskDataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,bpskDataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,bpskValidOut,validOut);
                    pirelab.getIntDelayComp(topNet,endInp,endOut,6);
                    pirelab.getIntDelayComp(topNet,startInp,startOut,6);
                end

            case 'QPSK'
                qpskDataIn=newDataSignal(topNet,inType,'qpskDataIn',rate);
                qpskValidIn=newControlSignal(topNet,'qpskValidIn',rate);
                pirelab.getWireComp(topNet,validInp,qpskValidIn);
                pirelab.getDTCComp(topNet,dataIn,qpskDataIn);
                qpskmodSelInDelay=newDataSignal(topNet,pir_ufixpt_t(3,0),'qpskmodSelInDelay',rate);
                pirelab.getWireComp(topNet,modSelInDelay,qpskmodSelInDelay);
                startIndel=newControlSignal(topNet,'startIndel',rate);
                endIndel=newControlSignal(topNet,'endIndel',rate);


                qpskDataOut=newDataSignal(topNet,pirelab.createPirArrayType(outType,[2,0]),'qpskDataOut',rate);
                qpskValidOut=newControlSignal(topNet,'qpskValidOut',rate);

                symbQPSKVectorDemodNet=this.elabMaxModQPSKVectorSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symbQPSKVectorDemodNet.addComment('QPSK vector Demodulation');

                inports_qpsk(1)=qpskDataIn;
                inports_qpsk(2)=qpskValidIn;
                inports_qpsk(3)=qpskmodSelInDelay;
                inports_qpsk(4)=startInp;

                outports_qpsk(1)=qpskDataOut;
                outports_qpsk(2)=qpskValidOut;

                pirelab.instantiateNetwork(topNet,symbQPSKVectorDemodNet,inports_qpsk,outports_qpsk,'symbMaxQPSKDemodNet_inst');

                if(blockInfo.NoiseVariance)
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,pirelab.createPirArrayType(outTypeNV,[2,0]),'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,pirelab.createPirArrayType(outTypeNV,[2,0]),'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        qpskdataDTC=newDataSignal(topNet,pirelab.createPirArrayType(divInpType,[2,0]),'qpskdataDTC',rate);
                        pirelab.getDTCComp(topNet,qpskDataOut,qpskdataDTC,'Zero','Saturate');
                        nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                        pirelab.getIntDelayComp(topNet,nVarIn,nVarInDelayed,8);
                        [divOut,latency]=nonRestoreDivision(topNet,qpskdataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,qpskValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                        pirelab.getIntDelayComp(topNet,endInp,endIndel,latency+8);
                        pirelab.getIntDelayComp(topNet,startInp,startIndel,latency+8);
                    else
                        pirelab.getCompareToValueComp(topNet,qpskDataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,qpskValidOut,validOut);
                        pirelab.getIntDelayComp(topNet,endInp,endIndel,8);
                        pirelab.getIntDelayComp(topNet,startInp,startIndel,8);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,qpskDataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,qpskDataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,qpskValidOut,validOut);
                    pirelab.getIntDelayComp(topNet,endInp,endIndel,8);
                    pirelab.getIntDelayComp(topNet,startInp,startIndel,8);
                end

                outSampleControlNet=this.elabOutputSampleControl(topNet,rate);
                pirelab.instantiateNetwork(topNet,outSampleControlNet,[startIndel,endIndel,validOut],[startOut,endOut],'outSampleControlNet');


            case '8-PSK'
                psk8DataIn=newDataSignal(topNet,inType,'psk8DataIn',rate);
                psk8ValidIn=newControlSignal(topNet,'psk8ValidIn',rate);
                pirelab.getWireComp(topNet,validInp,psk8ValidIn);
                pirelab.getDTCComp(topNet,dataIn,psk8DataIn);
                psk8modSelInDelay=newDataSignal(topNet,pir_ufixpt_t(3,0),'psk8modSelInDelay',rate);
                pirelab.getWireComp(topNet,modSelInDelay,psk8modSelInDelay);
                startIndel=newControlSignal(topNet,'startIndel',rate);
                endIndel=newControlSignal(topNet,'endIndel',rate);


                psk8DataOut=newDataSignal(topNet,pirelab.createPirArrayType(outType,[3,0]),'psk8DataOut',rate);
                psk8ValidOut=newControlSignal(topNet,'psk8ValidOut',rate);

                symbpsk8VectorDemodNet=this.elabMaxMod8PSKVectorSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symbpsk8VectorDemodNet.addComment('8-PSK vector Demodulation');

                inports_psk8(1)=psk8DataIn;
                inports_psk8(2)=psk8ValidIn;
                inports_psk8(3)=psk8modSelInDelay;
                inports_psk8(4)=startInp;

                outports_psk8(1)=psk8DataOut;
                outports_psk8(2)=psk8ValidOut;

                pirelab.instantiateNetwork(topNet,symbpsk8VectorDemodNet,inports_psk8,outports_psk8,'symbMaxpsk8DemodNet_inst');

                if(blockInfo.NoiseVariance)
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,pirelab.createPirArrayType(outTypeNV,[3,0]),'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,pirelab.createPirArrayType(outTypeNV,[3,0]),'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        psk8dataDTC=newDataSignal(topNet,pirelab.createPirArrayType(divInpType,[3,0]),'psk8dataDTC',rate);
                        pirelab.getDTCComp(topNet,psk8DataOut,psk8dataDTC,'Zero','Saturate');
                        nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                        pirelab.getIntDelayComp(topNet,nVarIn,nVarInDelayed,10);
                        [divOut,latency]=nonRestoreDivision(topNet,psk8dataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,psk8ValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                        pirelab.getIntDelayComp(topNet,endInp,endIndel,latency+10);
                        pirelab.getIntDelayComp(topNet,startInp,startIndel,latency+10);
                    else
                        pirelab.getCompareToValueComp(topNet,psk8DataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,psk8ValidOut,validOut);
                        pirelab.getIntDelayComp(topNet,endInp,endIndel,10);
                        pirelab.getIntDelayComp(topNet,startInp,startIndel,10);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,psk8DataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,psk8DataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,psk8ValidOut,validOut);
                    pirelab.getIntDelayComp(topNet,endInp,endIndel,10);
                    pirelab.getIntDelayComp(topNet,startInp,startIndel,10);
                end

                outSampleControlNet=this.elabOutputSampleControl(topNet,rate);
                pirelab.instantiateNetwork(topNet,outSampleControlNet,[startIndel,endIndel,validOut],[startOut,endOut],'outSampleControlNet');
            case '16-PSK'
                psk16DataIn=newDataSignal(topNet,inType,'psk16DataIn',rate);
                psk16ValidIn=newControlSignal(topNet,'psk16ValidIn',rate);
                pirelab.getWireComp(topNet,validInp,psk16ValidIn);
                pirelab.getDTCComp(topNet,dataIn,psk16DataIn);
                psk16modSelInDelay=newDataSignal(topNet,pir_ufixpt_t(3,0),'psk16modSelInDelay',rate);
                pirelab.getWireComp(topNet,modSelInDelay,psk16modSelInDelay);
                startIndel=newControlSignal(topNet,'startIndel',rate);
                endIndel=newControlSignal(topNet,'endIndel',rate);


                psk16DataOut=newDataSignal(topNet,pirelab.createPirArrayType(outType,[4,0]),'psk16DataOut',rate);
                psk16ValidOut=newControlSignal(topNet,'psk16ValidOut',rate);

                symbpsk16VectorDemodNet=this.elabMaxMod16PSKVectorSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symbpsk16VectorDemodNet.addComment('16-PSK vector Demodulation');

                inports_psk16(1)=psk16DataIn;
                inports_psk16(2)=psk16ValidIn;
                inports_psk16(3)=psk16modSelInDelay;
                inports_psk16(4)=startInp;

                outports_psk16(1)=psk16DataOut;
                outports_psk16(2)=psk16ValidOut;

                pirelab.instantiateNetwork(topNet,symbpsk16VectorDemodNet,inports_psk16,outports_psk16,'symbMaxpsk16DemodNet_inst');

                if(blockInfo.NoiseVariance)
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,pirelab.createPirArrayType(outTypeNV,[4,0]),'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,pirelab.createPirArrayType(outTypeNV,[4,0]),'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        psk16dataDTC=newDataSignal(topNet,pirelab.createPirArrayType(divInpType,[4,0]),'psk16dataDTC',rate);
                        pirelab.getDTCComp(topNet,psk16DataOut,psk16dataDTC,'Zero','Saturate');
                        nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                        pirelab.getIntDelayComp(topNet,nVarIn,nVarInDelayed,13);
                        [divOut,latency]=nonRestoreDivision(topNet,psk16dataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,psk16ValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                        pirelab.getIntDelayComp(topNet,endInp,endIndel,latency+13);
                        pirelab.getIntDelayComp(topNet,startInp,startIndel,latency+13);
                    else
                        pirelab.getCompareToValueComp(topNet,psk16DataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,psk16ValidOut,validOut);
                        pirelab.getIntDelayComp(topNet,endInp,endIndel,13);
                        pirelab.getIntDelayComp(topNet,startInp,startIndel,13);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,psk16DataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,psk16DataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,psk16ValidOut,validOut);
                    pirelab.getIntDelayComp(topNet,endInp,endIndel,13);
                    pirelab.getIntDelayComp(topNet,startInp,startIndel,13);
                end

                outSampleControlNet=this.elabOutputSampleControl(topNet,rate);
                pirelab.instantiateNetwork(topNet,outSampleControlNet,[startIndel,endIndel,validOut],[startOut,endOut],'outSampleControlNet');
            case '32-PSK'
                psk32DataIn=newDataSignal(topNet,inType,'psk32DataIn',rate);
                psk32ValidIn=newControlSignal(topNet,'psk32ValidIn',rate);
                pirelab.getWireComp(topNet,validInp,psk32ValidIn);
                pirelab.getDTCComp(topNet,dataIn,psk32DataIn);
                psk32modSelInDelay=newDataSignal(topNet,pir_ufixpt_t(3,0),'psk32modSelInDelay',rate);
                pirelab.getWireComp(topNet,modSelInDelay,psk32modSelInDelay);
                startIndel=newControlSignal(topNet,'startIndel',rate);
                endIndel=newControlSignal(topNet,'endIndel',rate);


                psk32DataOut=newDataSignal(topNet,pirelab.createPirArrayType(outType,[5,0]),'psk32DataOut',rate);
                psk32ValidOut=newControlSignal(topNet,'psk32ValidOut',rate);

                symbpsk32VectorDemodNet=this.elabMaxMod32PSKVectorSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symbpsk32VectorDemodNet.addComment('32-PSK vector Demodulation');

                inports_psk32(1)=psk32DataIn;
                inports_psk32(2)=psk32ValidIn;
                inports_psk32(3)=psk32modSelInDelay;
                inports_psk32(4)=startInp;

                outports_psk32(1)=psk32DataOut;
                outports_psk32(2)=psk32ValidOut;

                pirelab.instantiateNetwork(topNet,symbpsk32VectorDemodNet,inports_psk32,outports_psk32,'symbMaxpsk32DemodNet_inst');

                if(blockInfo.NoiseVariance)
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,pirelab.createPirArrayType(outTypeNV,[5,0]),'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,pirelab.createPirArrayType(outTypeNV,[5,0]),'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        psk32dataDTC=newDataSignal(topNet,pirelab.createPirArrayType(divInpType,[5,0]),'psk32dataDTC',rate);
                        pirelab.getDTCComp(topNet,psk32DataOut,psk32dataDTC,'Zero','Saturate');
                        nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                        pirelab.getIntDelayComp(topNet,nVarIn,nVarInDelayed,15);
                        [divOut,latency]=nonRestoreDivision(topNet,psk32dataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,psk32ValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                        pirelab.getIntDelayComp(topNet,endInp,endIndel,latency+15);
                        pirelab.getIntDelayComp(topNet,startInp,startIndel,latency+15);
                    else
                        pirelab.getCompareToValueComp(topNet,psk32DataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,psk32ValidOut,validOut);
                        pirelab.getIntDelayComp(topNet,endInp,endIndel,15);
                        pirelab.getIntDelayComp(topNet,startInp,startIndel,15);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,psk32DataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,psk32DataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,psk32ValidOut,validOut);
                    pirelab.getIntDelayComp(topNet,endInp,endIndel,15);
                    pirelab.getIntDelayComp(topNet,startInp,startIndel,15);
                end

                outSampleControlNet=this.elabOutputSampleControl(topNet,rate);
                pirelab.instantiateNetwork(topNet,outSampleControlNet,[startIndel,endIndel,validOut],[startOut,endOut],'outSampleControlNet');
            case '16-QAM'
                qam16DataIn=newDataSignal(topNet,inType,'qam16DataIn',rate);
                qam16ValidIn=newControlSignal(topNet,'qam16ValidIn',rate);
                pirelab.getWireComp(topNet,validInp,qam16ValidIn);
                pirelab.getDTCComp(topNet,dataIn,qam16DataIn);
                qam16modSelInDelay=newDataSignal(topNet,pir_ufixpt_t(3,0),'qam16modSelInDelay',rate);
                pirelab.getWireComp(topNet,modSelInDelay,qam16modSelInDelay);
                startIndel=newControlSignal(topNet,'startIndel',rate);
                endIndel=newControlSignal(topNet,'endIndel',rate);


                qam16DataOut=newDataSignal(topNet,pirelab.createPirArrayType(outType,[4,0]),'qam16DataOut',rate);
                qam16ValidOut=newControlSignal(topNet,'qam16ValidOut',rate);

                symbqam16VectorDemodNet=this.elabMaxMod16QAMVectorSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symbqam16VectorDemodNet.addComment('16-QAM vector Demodulation');

                inports_qam16(1)=qam16DataIn;
                inports_qam16(2)=qam16ValidIn;
                inports_qam16(3)=qam16modSelInDelay;
                inports_qam16(4)=startInp;

                outports_qam16(1)=qam16DataOut;
                outports_qam16(2)=qam16ValidOut;

                pirelab.instantiateNetwork(topNet,symbqam16VectorDemodNet,inports_qam16,outports_qam16,'symbMaxqam16DemodNet_inst');

                if(blockInfo.NoiseVariance)
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,pirelab.createPirArrayType(outTypeNV,[4,0]),'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,pirelab.createPirArrayType(outTypeNV,[4,0]),'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        qam16dataDTC=newDataSignal(topNet,pirelab.createPirArrayType(divInpType,[4,0]),'qam16dataDTC',rate);
                        pirelab.getDTCComp(topNet,qam16DataOut,qam16dataDTC,'Zero','Saturate');
                        nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                        pirelab.getIntDelayComp(topNet,nVarIn,nVarInDelayed,13);
                        [divOut,latency]=nonRestoreDivision(topNet,qam16dataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,qam16ValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                        pirelab.getIntDelayComp(topNet,endInp,endIndel,latency+13);
                        pirelab.getIntDelayComp(topNet,startInp,startIndel,latency+13);
                    else
                        pirelab.getCompareToValueComp(topNet,qam16DataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,qam16ValidOut,validOut);
                        pirelab.getIntDelayComp(topNet,endInp,endIndel,13);
                        pirelab.getIntDelayComp(topNet,startInp,startIndel,13);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,qam16DataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,qam16DataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,qam16ValidOut,validOut);
                    pirelab.getIntDelayComp(topNet,endInp,endIndel,13);
                    pirelab.getIntDelayComp(topNet,startInp,startIndel,13);
                end

                outSampleControlNet=this.elabOutputSampleControl(topNet,rate);
                pirelab.instantiateNetwork(topNet,outSampleControlNet,[startIndel,endIndel,validOut],[startOut,endOut],'outSampleControlNet');
            case '64-QAM'
                qam64DataIn=newDataSignal(topNet,inType,'qam64DataIn',rate);
                qam64ValidIn=newControlSignal(topNet,'qam64ValidIn',rate);
                pirelab.getWireComp(topNet,validInp,qam64ValidIn);
                pirelab.getDTCComp(topNet,dataIn,qam64DataIn);
                qam64modSelInDelay=newDataSignal(topNet,pir_ufixpt_t(3,0),'qam64modSelInDelay',rate);
                pirelab.getWireComp(topNet,modSelInDelay,qam64modSelInDelay);
                startIndel=newControlSignal(topNet,'startIndel',rate);
                endIndel=newControlSignal(topNet,'endIndel',rate);


                qam64DataOut=newDataSignal(topNet,pirelab.createPirArrayType(outType,[6,0]),'qam64DataOut',rate);
                qam64ValidOut=newControlSignal(topNet,'qam64ValidOut',rate);

                symbqam64VectorDemodNet=this.elabMaxMod64QAMVectorSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symbqam64VectorDemodNet.addComment('64-QAM vector Demodulation');

                inports_qam64(1)=qam64DataIn;
                inports_qam64(2)=qam64ValidIn;
                inports_qam64(3)=qam64modSelInDelay;
                inports_qam64(4)=startInp;

                outports_qam64(1)=qam64DataOut;
                outports_qam64(2)=qam64ValidOut;

                pirelab.instantiateNetwork(topNet,symbqam64VectorDemodNet,inports_qam64,outports_qam64,'symbMaxqam64DemodNet_inst');

                if(blockInfo.NoiseVariance)
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,pirelab.createPirArrayType(outTypeNV,[6,0]),'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,pirelab.createPirArrayType(outTypeNV,[6,0]),'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        qam64dataDTC=newDataSignal(topNet,pirelab.createPirArrayType(divInpType,[6,0]),'qam64dataDTC',rate);
                        pirelab.getDTCComp(topNet,qam64DataOut,qam64dataDTC,'Zero','Saturate');
                        nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                        pirelab.getIntDelayComp(topNet,nVarIn,nVarInDelayed,17);
                        [divOut,latency]=nonRestoreDivision(topNet,qam64dataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,qam64ValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                        pirelab.getIntDelayComp(topNet,endInp,endIndel,latency+17);
                        pirelab.getIntDelayComp(topNet,startInp,startIndel,latency+17);
                    else
                        pirelab.getCompareToValueComp(topNet,qam64DataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,qam64ValidOut,validOut);
                        pirelab.getIntDelayComp(topNet,endInp,endIndel,17);
                        pirelab.getIntDelayComp(topNet,startInp,startIndel,17);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,qam64DataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,qam64DataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,qam64ValidOut,validOut);
                    pirelab.getIntDelayComp(topNet,endInp,endIndel,17);
                    pirelab.getIntDelayComp(topNet,startInp,startIndel,17);
                end

                outSampleControlNet=this.elabOutputSampleControl(topNet,rate);
                pirelab.instantiateNetwork(topNet,outSampleControlNet,[startIndel,endIndel,validOut],[startOut,endOut],'outSampleControlNet');

            otherwise
                qam256DataIn=newDataSignal(topNet,inType,'qam256DataIn',rate);
                qam256ValidIn=newControlSignal(topNet,'qam256ValidIn',rate);
                pirelab.getWireComp(topNet,validInp,qam256ValidIn);
                pirelab.getDTCComp(topNet,dataIn,qam256DataIn);
                qam256modSelInDelay=newDataSignal(topNet,pir_ufixpt_t(3,0),'qam256modSelInDelay',rate);
                pirelab.getWireComp(topNet,modSelInDelay,qam256modSelInDelay);
                startIndel=newControlSignal(topNet,'startIndel',rate);
                endIndel=newControlSignal(topNet,'endIndel',rate);


                qam256DataOut=newDataSignal(topNet,pirelab.createPirArrayType(outType,[8,0]),'qam256DataOut',rate);
                qam256ValidOut=newControlSignal(topNet,'qam256ValidOut',rate);

                symbqam256VectorDemodNet=this.elabMaxMod256QAMVectorSymDemodNet(topNet,blockInfo,rate,inWL,inFL);
                symbqam256VectorDemodNet.addComment('256-QAM vector Demodulation');

                inports_qam256(1)=qam256DataIn;
                inports_qam256(2)=qam256ValidIn;
                inports_qam256(3)=qam256modSelInDelay;
                inports_qam256(4)=startInp;

                outports_qam256(1)=qam256DataOut;
                outports_qam256(2)=qam256ValidOut;

                pirelab.instantiateNetwork(topNet,symbqam256VectorDemodNet,inports_qam256,outports_qam256,'symbMaxqam256DemodNet_inst');

                if(blockInfo.NoiseVariance)
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        divOutDTC=newDataSignal(topNet,pirelab.createPirArrayType(outTypeNV,[8,0]),'divOutDTC',rate);
                        zeroSig=newDataSignal(topNet,pirelab.createPirArrayType(outTypeNV,[8,0]),'zeroSig',rate);
                        pirelab.getConstComp(topNet,zeroSig,0);
                        qam256dataDTC=newDataSignal(topNet,pirelab.createPirArrayType(divInpType,[8,0]),'qam256dataDTC',rate);
                        pirelab.getDTCComp(topNet,qam256DataOut,qam256dataDTC,'Zero','Saturate');
                        nVarInDelayed=newDataSignal(topNet,nVarType,'nVarInDelayed',rate);
                        pirelab.getIntDelayComp(topNet,nVarIn,nVarInDelayed,17);
                        [divOut,latency]=nonRestoreDivision(topNet,qam256dataDTC,nVarInDelayed,blockInfo,rate);
                        pirelab.getDTCComp(topNet,divOut,divOutDTC,'Zero','Saturate');
                        pirelab.getIntDelayComp(topNet,qam256ValidOut,validOut,latency);
                        pirelab.getSwitchComp(topNet,[zeroSig,divOutDTC],dataOut,validOut);
                        pirelab.getIntDelayComp(topNet,endInp,endIndel,latency+17);
                        pirelab.getIntDelayComp(topNet,startInp,startIndel,latency+17);
                    else
                        pirelab.getCompareToValueComp(topNet,qam256DataOut,dataOut,'<',0);
                        pirelab.getWireComp(topNet,qam256ValidOut,validOut);
                        pirelab.getIntDelayComp(topNet,endInp,endIndel,17);
                        pirelab.getIntDelayComp(topNet,startInp,startIndel,17);
                    end
                else
                    if strcmp(blockInfo.DecisionType,'Approximate log-likelihood ratio')
                        pirelab.getWireComp(topNet,qam256DataOut,dataOut);
                    else
                        pirelab.getCompareToValueComp(topNet,qam256DataOut,dataOut,'<',0);
                    end
                    pirelab.getWireComp(topNet,qam256ValidOut,validOut);
                    pirelab.getIntDelayComp(topNet,endInp,endIndel,17);
                    pirelab.getIntDelayComp(topNet,startInp,startIndel,17);
                end

                outSampleControlNet=this.elabOutputSampleControl(topNet,rate);
                pirelab.instantiateNetwork(topNet,outSampleControlNet,[startIndel,endIndel,validOut],[startOut,endOut],'outSampleControlNet');
            end

        end
    end


end

function signal=newControlSignal(topNet,name,rate)
    controlType=pir_ufixpt_t(1,0);
    signal=topNet.addSignal(controlType,name);
    signal.SimulinkRate=rate;
end

function signal=newDataSignal(topNet,inType,name,rate)
    signal=topNet.addSignal(inType,name);
    signal.SimulinkRate=rate;
end

function[divideOut,latency]=nonRestoreDivision(topNet,llrOut,nVariance,blockInfo,rate)
    divideInfo.pipeline='on';
    divideInfo.customLatency=0;
    divideInfo.ovMode='Saturate';
    divideInfo.inputSigns='*/';
    divideInfo.latencyStrategy='MAX';
    divideInfo.rndMode='Zero';
    divideInfo.networkName='DividingBlock';
    divideInfo.firstInputSignDivide=false;
    divideInfo.numeratorTypeInfo.zType=llrOut.Type.BaseType;
    divideInfo.numeratorTypeInfo.zWL=llrOut.Type.BaseType.WordLength;
    divideInfo.numeratorTypeInfo.zSign=1;
    divideInfo.denominatorTypeInfo.dType=nVariance.Type;
    divideInfo.denominatorTypeInfo.dWL=nVariance.Type.BaseType.WordLength;
    divideInfo.denominatorTypeInfo.dSign=0;
    divideInfo.quotientTypeInfo.QWL=max(llrOut.Type.BaseType.WordLength,nVariance.Type.BaseType.WordLength);
    divideInfo.quotientTypeInfo.QFL=llrOut.Type.BaseType.FractionLength-nVariance.Type.BaseType.FractionLength;
    divideInfo.fractiondiff=-divideInfo.quotientTypeInfo.QFL;
    divideInfo.OutType='Inherit: Inherit via internal rule';
    divOutType=pir_sfixpt_t(llrOut.Type.BaseType.WordLength+9+nVariance.Type.BaseType.FractionLength,llrOut.Type.BaseType.FractionLength-nVariance.Type.BaseType.FractionLength);
    if(strcmpi(blockInfo.OutputType,'Scalar'))
        divideOut=topNet.addSignal(divOutType,'divideOut');
    else
        if(strcmpi(blockInfo.ModulationSource,'Input port'))
            if strcmpi(blockInfo.MaxModulation,'BPSK')
                divideOut=topNet.addSignal(divOutType,'divideOut');
            elseif strcmpi(blockInfo.MaxModulation,'QPSK')
                outSize=2;
                divideOut=topNet.addSignal(pirelab.createPirArrayType(divOutType,[outSize,0]),'divideOut');
            elseif strcmpi(blockInfo.MaxModulation,'8-PSK')
                outSize=3;
                divideOut=topNet.addSignal(pirelab.createPirArrayType(divOutType,[outSize,0]),'divideOut');
            elseif strcmpi(blockInfo.MaxModulation,'16-PSK')
                outSize=4;
                divideOut=topNet.addSignal(pirelab.createPirArrayType(divOutType,[outSize,0]),'divideOut');
            elseif strcmpi(blockInfo.MaxModulation,'16-QAM')
                outSize=4;
                divideOut=topNet.addSignal(pirelab.createPirArrayType(divOutType,[outSize,0]),'divideOut');
            elseif strcmpi(blockInfo.MaxModulation,'32-PSK')
                outSize=5;
                divideOut=topNet.addSignal(pirelab.createPirArrayType(divOutType,[outSize,0]),'divideOut');
            elseif strcmpi(blockInfo.MaxModulation,'64-QAM')
                outSize=6;
                divideOut=topNet.addSignal(pirelab.createPirArrayType(divOutType,[outSize,0]),'divideOut');
            else
                outSize=8;
                divideOut=topNet.addSignal(pirelab.createPirArrayType(divOutType,[outSize,0]),'divideOut');
            end
        else
            if strcmpi(blockInfo.ModulationScheme,'BPSK')
                divideOut=topNet.addSignal(divOutType,'divideOut');
            elseif strcmpi(blockInfo.ModulationScheme,'QPSK')
                outSize=2;
                divideOut=topNet.addSignal(pirelab.createPirArrayType(divOutType,[outSize,0]),'divideOut');
            elseif strcmpi(blockInfo.ModulationScheme,'8-PSK')
                outSize=3;
                divideOut=topNet.addSignal(pirelab.createPirArrayType(divOutType,[outSize,0]),'divideOut');
            elseif strcmpi(blockInfo.ModulationScheme,'16-PSK')
                outSize=4;
                divideOut=topNet.addSignal(pirelab.createPirArrayType(divOutType,[outSize,0]),'divideOut');
            elseif strcmpi(blockInfo.ModulationScheme,'16-QAM')
                outSize=4;
                divideOut=topNet.addSignal(pirelab.createPirArrayType(divOutType,[outSize,0]),'divideOut');
            elseif strcmpi(blockInfo.ModulationScheme,'32-PSK')
                outSize=5;
                divideOut=topNet.addSignal(pirelab.createPirArrayType(divOutType,[outSize,0]),'divideOut');
            elseif strcmpi(blockInfo.ModulationScheme,'64-QAM')
                outSize=6;
                divideOut=topNet.addSignal(pirelab.createPirArrayType(divOutType,[outSize,0]),'divideOut');
            else
                outSize=8;
                divideOut=topNet.addSignal(pirelab.createPirArrayType(divOutType,[outSize,0]),'divideOut');
            end
        end
    end

    divideOut.SimulinkRate=rate;
    pirelab.getNonRestoreDivideComp(topNet,[llrOut;nVariance],divideOut,divideInfo);
    latency=max(llrOut.Type.BaseType.WordLength,nVariance.Type.BaseType.WordLength)+5;
end
