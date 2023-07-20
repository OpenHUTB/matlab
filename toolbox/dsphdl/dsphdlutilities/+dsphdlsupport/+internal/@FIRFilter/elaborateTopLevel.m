function newNet=elaborateTopLevel(this,hN,hC,blockInfo)








    hDriver=hdlcurrentdriver;
    blockInfo.synthesisTool=hDriver.getParameter('SynthesisTool');
    if blockInfo.ResetInputPort&&strcmpi(blockInfo.NumeratorSource,'Input port (Parallel interface)')
        inportNames={'dataIn','validIn','Coeff','syncReset'};
    elseif blockInfo.ResetInputPort
        inportNames={'dataIn','validIn','syncReset'};
    elseif strcmpi(blockInfo.NumeratorSource,'Input port (Parallel interface)')
        inportNames={'dataIn','validIn','Coeff'};
    else
        inportNames={'dataIn','validIn'};
    end

    outportNames={'dataOut','validOut'};
    if length(hC.PirOutputPorts)==3
        outportNames={'dataOut','validOut','ready'};
    end

    newNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC,...
    'InportNames',inportNames,...
    'OutportNames',outportNames);





    dataIn=newNet.PirInputSignals(1);
    validIn=newNet.PirInputSignals(2);
    dataRate=dataIn.simulinkRate;
    dinType=pirgetdatatypeinfo(dataIn.Type);
    isInputComplex=dinType.iscomplex;


    if blockInfo.inMode(2)&&~blockInfo.inResetSS
        if strcmpi(blockInfo.NumeratorSource,'Input port (Parallel interface)')
            syncReset=newNet.PirInputSignals(4);
        else
            syncReset=newNet.PirInputSignals(3);
        end

    else
        syncReset=newNet.addSignal2('Type',pir_boolean_t,'Name','syncReset');
        syncReset.SimulinkRate=dataRate;
        pirelab.getConstComp(newNet,syncReset,false);

        if blockInfo.inResetSS


            syncReset.setSynthResetInsideResetSS;

            blockInfo.inMode(2)=true;




        end
    end

    if strcmpi(blockInfo.NumeratorSource,'Input port (Parallel interface)')
        coeff=newNet.PirInputSignals(3);
    end

    dataOut=newNet.PirOutputSignals(1);
    validOut=newNet.PirOutputSignals(2);
    if length(newNet.PirOutputSignals)>2
        ready=newNet.PirOutputSignals(3);
    else

        ready=newNet.addSignal(pir_boolean_t,'ready');
        ready.SimulinkRate=dataRate;
    end






    inputRate=dataIn.SimulinkRate;
    dataOut.SimulinkRate=inputRate;
    validOut.SimulinkRate=inputRate;
    ready.SimulinkRate=inputRate;






    [~,blockInfo.isSymmetry]=getCoefficientsSymmetry(this,blockInfo);
    if~strcmpi(blockInfo.FilterStructure,'Partly serial systolic')
        if strcmpi(blockInfo.NumeratorSource,'Input port (Parallel interface)')
            inSignals=[dataIn,validIn,coeff,syncReset];
        else
            inSignals=[dataIn,validIn,syncReset];
        end
        outSignals=[dataOut,validOut];
    elseif getSerializationFactor(blockInfo,isInputComplex)>1
        inSignals=[dataIn,validIn,syncReset];
        outSignals=[dataOut,validOut,ready];
    else
        inSignals=[dataIn,validIn,syncReset];
        outSignals=[dataOut,validOut];
        readyS=newNet.addSignal2('Type',pir_boolean_t,'Name','readyS');
        readyS.SimulinkRate=dataRate;
        pirelab.getBitwiseOpComp(newNet,syncReset,readyS,'NOT');
        pirelab.getUnitDelayComp(newNet,readyS,ready,'',1);

    end

    blockInfo.SharingFactor=getSerializationFactor(blockInfo,isInputComplex);

    filterBankArch=true;


    if isnumerictype(blockInfo.CoefficientsDataType)
        if~any(any(fi(blockInfo.Numerator,blockInfo.CoefficientsDataType)))&&~strcmpi(blockInfo.NumeratorSource,'Input port (Parallel interface)')
            pirelab.getConstComp(newNet,dataOut,0);
            pirelab.getUnitDelayComp(newNet,validIn,validOut);
            pirelab.getConstComp(newNet,ready,1);
        elseif strcmpi(blockInfo.FilterStructure,'Partly serial systolic')&&blockInfo.SharingFactor>1

            this.elaborateSystolicFIRSharing(newNet,inSignals,outSignals,blockInfo)
        elseif filterBankArch
            FilterImpl=this.elabHDLFIRFilter(newNet,blockInfo,inSignals,outSignals);
            pirelab.instantiateNetwork(newNet,FilterImpl,inSignals,outSignals,'FilterBank');
        else

        end
    else
        if~any(any(blockInfo.Numerator))&&~strcmpi(blockInfo.NumeratorSource,'Input port (Parallel interface)')
            pirelab.getConstComp(newNet,dataOut,0);
            pirelab.getUnitDelayComp(newNet,validIn,validOut);
            pirelab.getConstComp(newNet,ready,1);

        elseif strcmpi(blockInfo.FilterStructure,'Partly serial systolic')&&blockInfo.SharingFactor>1

            this.elaborateSystolicFIRSharing(newNet,inSignals,outSignals,blockInfo)
        elseif filterBankArch
            FilterImpl=this.elabHDLFIRFilter(newNet,blockInfo,inSignals,outSignals);
            pirelab.instantiateNetwork(newNet,FilterImpl,inSignals,outSignals,'FilterBank');
        else

        end
    end


end

function sharing=getSerializationFactor(blockInfo,isInputComplex)
    isCoeffComplex=~isreal(blockInfo.Numerator);
    nTaps=length(blockInfo.Numerator);

    if strcmpi(blockInfo.FilterStructure,'Partly serial systolic')
        if strcmpi(blockInfo.SerializationOption,'Maximum number of multipliers')
            oddSymm=mod(nTaps,2);
            if blockInfo.isSymmetry
                nTaps=ceil(nTaps/2);
            end

            if isInputComplex&&isCoeffComplex
                oddSymSharingFactor=blockInfo.SharingFactor-3*oddSymm;
                sharing=ceil(nTaps/(floor(oddSymSharingFactor/3)));
            elseif xor(isInputComplex,isCoeffComplex)
                oddSymSharingFactor=blockInfo.SharingFactor-2*oddSymm;
                sharing=ceil(nTaps/(floor(oddSymSharingFactor/2)));
            else
                oddSymSharingFactor=blockInfo.SharingFactor-oddSymm;
                sharing=ceil(nTaps/oddSymSharingFactor);
            end
            if isinf(sharing)||sharing>=nTaps
                sharing=nTaps;
            end
        else
            sharing=blockInfo.SharingFactor;
        end
    else
        sharing=1;
    end
end










