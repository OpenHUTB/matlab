function varSelComp=getVariableSelectorComp(hN,hInputSignals,hOutputSignals,...
    zerOneIdxMode,idxMode,elements,fillValues,rowsOrCols,numInputs,compName)


    if strcmp(zerOneIdxMode,'Zero-based')
        zeroBasedIndex=1;
    else
        zeroBasedIndex=0;
    end
    if strcmp(idxMode,'Variable')
        indexMode=1;
    else
        indexMode=0;
    end
    if strcmp(rowsOrCols,'Rows')
        rowsOrCols=1;
    else
        rowsOrCols=0;
    end

    if indexMode==1
        selSig=hInputSignals(end);
        if selSig.Type.isArrayType
            selType=selSig.Type.getLeafType;
        else
            selType=selSig.Type;
        end
        if selType.isDoubleType
            selSize=64;
        elseif selType.isSingleType
            selSize=32;
        else
            selSize=selType.WordLength;
        end
    end

    for ii=1:numInputs
        inSig=hInputSignals(ii);
        invec=hdlsignalvector(inSig);
        outSig=hOutputSignals(ii);
        outvec=hdlsignalvector(outSig);

        if~isempty(elements)


            maxIndex=max(invec)-zeroBasedIndex;
            elements(elements>maxIndex)=maxIndex;
            oneBased=1-zeroBasedIndex;
            elements(elements<oneBased)=oneBased;
            if ii==1

                elements=elements+zeroBasedIndex;
            end
        end

        selectEntireInput=false;
        if(invec(1)==1&&rowsOrCols==1)||...
            (length(invec)>1&&invec(2)==1&&rowsOrCols==0)
            selectEntireInput=true;
        end

        if indexMode==1&&selSize==1


            fillVal=fillValues(ii);
            if inSig.Type.isArrayType
                constType=inSig.Type.baseType;
            else
                constType=inSig.Type;
            end
            indexZeroName=[outSig.Name,'_index_zero'];
            fillSig=hN.addSignal(constType,indexZeroName);
            newConst=pireml.getConstComp(hN,fillSig,fillVal);%#ok<NASGU>

            inputDemuxSigs=pirelab.demuxSignal(hN,inSig);
            outputMux=pirelab.getMuxOnOutput(hN,outSig);
            outputMuxSigs=outputMux.PirInputSignals;
            signalLen=length(outputMuxSigs);
            if selSig.Type.isArrayType
                selDemuxSigs=pirelab.demuxSignal(hN,selSig);
            else
                selDemuxSigs=repmat(selSig,signalLen,1);
            end
            for jj=1:signalLen
                newComp=pireml.getSwitchComp(hN,[selDemuxSigs(jj),inputDemuxSigs(jj),fillSig],...
                outputMuxSigs(jj));
            end
        elseif(all(~invec)&&all(~outvec))||...
selectEntireInput
            newComp=pirelab.getWireComp(hN,inSig,outSig);
        elseif all(~invec)
            outputMux=pirelab.getMuxOnOutput(hN,outSig);
            outputMuxSigs=outputMux.PirInputSignals;
            for jj=1:max(outvec)
                newComp=pirelab.getWireComp(hN,inSig,outputMuxSigs(jj));
            end
        elseif indexMode==1

            if selType.isUnsignedType&&zeroBasedIndex
                clipToRange=false;
            else
                clipToRange=true;
            end
            if~selSig.Type.isArrayType
                newComp=makeOneVarSelComp(hN,[selSig,inSig],outSig,...
                zeroBasedIndex,clipToRange,compName);
            else
                selDemuxSigs=pirelab.demuxSignal(hN,selSig);
                outputMux=pirelab.getMuxOnOutput(hN,outSig);
                outputMuxSigs=outputMux.PirInputSignals;
                for jj=1:selSig.Type.getDimensions
                    newComp=makeOneVarSelComp(hN,[selDemuxSigs(jj),inSig],...
                    outputMuxSigs(jj),zeroBasedIndex,clipToRange,compName);
                end
            end
        else

            inputDemuxSigs=pirelab.demuxSignal(hN,inSig);
            outputMux=pirelab.getMuxOnOutput(hN,outSig);
            outputMuxSigs=outputMux.PirInputSignals;
            for jj=1:length(elements)
                newComp=pirelab.getWireComp(hN,inputDemuxSigs(elements(jj)),outputMuxSigs(jj));
            end
        end

    end
    varSelComp=newComp;
end

function varSelComp=makeOneVarSelComp(hN,hInputSignals,hOutputSignals,...
    zeroBasedIndex,clipToRange,compName)
    varSelComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',hInputSignals,...
    'OutputSignals',hOutputSignals,...
    'EMLFileName','hdleml_switch_varsel',...
    'EMLParams',{zeroBasedIndex,clipToRange},...
    'EMLFlag_RunLoopUnrolling',true,...
    'EMLFlag_ParamsFollowInputs',false,...
    'EMLFlag_TreatInputIntsAsFixpt',false);
    varSelComp.runWebRenaming(false);
    if targetmapping.isValidDataType(hInputSignals(1).Type)
        varSelComp.setSupportTargetCodGenWithoutMapping(true);
    end
end
