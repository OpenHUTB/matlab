function[validOut,validInDelayed]=createEnabledDelayCounters(validIn,delayLength)




    hN=validIn.Owner;
    rate=validIn.SimulinkRate;
    numImgSamples=getNumImgSamples(hN);

    validInDelayed=hN.addSignal(validIn);


    pirelab.getIntDelayComp(hN,validIn,validInDelayed,1,'delayValid');



    imgCtrType=pir_ufixpt_t(ceil(log2(numImgSamples))+1,0);
    imgCtr=addSignal(hN,imgCtrType,'imgCtr',rate);


    pirelab.getCounterComp(hN,...
    validIn,...
    imgCtr,...
    'Count limited',...
    numImgSamples,...
    1,...
    numImgSamples,...
    false,...
    false,...
    true,...
    false,...
    'imgCtr',...
    1);



    countIsLast=addSignal(hN,pir_boolean_t,'countIsLast',rate);
    pirelab.getCompareToValueComp(hN,imgCtr,countIsLast,'==',numImgSamples,'countIsLast');

    isLastSample=addSignal(hN,pir_boolean_t,'isLastSample',rate);
    pirelab.getLogicComp(hN,[validInDelayed,countIsLast],isLastSample,'and','isLastSample');

    if delayLength<numImgSamples
        validOut=getValidOut_delayLtImgSize(validInDelayed,imgCtr,isLastSample,delayLength);
    else
        validOut=getValidOut_delayGeImgSize(isLastSample,delayLength,numImgSamples);
    end
end

function validOut=getValidOut_delayLtImgSize(validInDelayed,imgCtr,isLastSample,delayLength)











    hN=validInDelayed.Owner;
    rate=validInDelayed.SimulinkRate;



    samplesGTDelay=addSignal(hN,pir_boolean_t,'samplesGTDelay',rate);
    pirelab.getCompareToValueComp(hN,imgCtr,samplesGTDelay,'>',delayLength,'samplesGTDelay');

    validOutBegin=addSignal(hN,pir_boolean_t,'validOutBegin',rate);
    pirelab.getLogicComp(hN,[validInDelayed,samplesGTDelay],validOutBegin,'and','validOutBegin');






    endCtrType=pir_ufixpt_t(ceil(log2(delayLength))+1,0);
    endCtr=addSignal(hN,endCtrType,'endCtr',rate);

    one=addSignal(hN,endCtrType,'one',rate);
    pirelab.getConstComp(hN,one,1,'one');



    validOutEnd=addSignal(hN,pir_boolean_t,'validOutEnd',rate);
    pirelab.getCompareToValueComp(hN,endCtr,validOutEnd,'~=',0,'validOutEnd');

    pirelab.getCounterComp(hN,...
    [isLastSample,one,validOutEnd],...
    endCtr,...
    'Count limited',...
    0,...
    1,...
    delayLength,...
    false,...
    true,...
    true,...
    false,...
    'endCtr',...
    0);





    validOut=addSignal(hN,pir_boolean_t,'validOut',rate);
    pirelab.getLogicComp(hN,[validOutBegin,validOutEnd],validOut,'or','validOut');
end

function validOut=getValidOut_delayGeImgSize(isLastSample,delayLength,numImgSamples)














    hN=isLastSample.Owner;
    rate=isLastSample.SimulinkRate;

    cyclesToDelay=delayLength-numImgSamples;

    while cyclesToDelay>0



        maxCtrVal=min(cyclesToDelay,numImgSamples);

        waitCtrType=pir_ufixpt_t(ceil(log2(maxCtrVal))+1,0);
        waitCtrOne=addSignal(hN,waitCtrType,'one',rate);
        pirelab.getConstComp(hN,waitCtrOne,1,'one');

        waitCtr=addSignal(hN,waitCtrType,'waitCtr',rate);

        waitCtrNonzero=addSignal(hN,pir_boolean_t,'waitCtrNonzero',rate);
        pirelab.getCompareToValueComp(hN,waitCtr,waitCtrNonzero,'~=',0,'waitCtrNonzero');

        pirelab.getCounterComp(hN,...
        [isLastSample,waitCtrOne,waitCtrNonzero],...
        waitCtr,...
        'Count limited',...
        0,...
        1,...
        maxCtrVal,...
        false,...
        true,...
        true,...
        false,...
        'waitCtr',...
        0);


        isLastSample=addSignal(hN,pir_boolean_t,'waitCtrMax',rate);
        pirelab.getCompareToValueComp(hN,waitCtr,isLastSample,'==',maxCtrVal,'waitCtrMax');

        cyclesToDelay=cyclesToDelay-maxCtrVal;
    end




    endCtrType=pir_ufixpt_t(ceil(log2(numImgSamples))+1,0);
    endCtrOne=addSignal(hN,endCtrType,'one',rate);
    pirelab.getConstComp(hN,endCtrOne,1,'one');

    endCtr=addSignal(hN,endCtrType,'endCtr',rate);

    validOut=addSignal(hN,pir_boolean_t,'validOut',rate);
    pirelab.getCompareToValueComp(hN,endCtr,validOut,'~=',0,'endCtrNonzero');

    pirelab.getCounterComp(hN,...
    [isLastSample,endCtrOne,validOut],...
    endCtr,...
    'Count limited',...
    0,...
    1,...
    numImgSamples,...
    false,...
    true,...
    true,...
    false,...
    'endCtr',...
    0);
end

function hSig=addSignal(hN,type,name,rate)
    hSig=hN.addSignal(type,name);
    hSig.SimulinkRate=rate;
end

function numImgSamples=getNumImgSamples(hN)
    hNICs=hN.instances;
    assert(~isempty(hNICs),'unexpectedly found non-instantiated network');

    numImgSamples=getNumImgSamplesForNIC(hNICs(1));
    for i=2:numel(hNICs)
        assert(numImgSamples==getNumImgSamplesForNIC(hNICs(i)),...
        'found ambiguous number of image samples');
    end
end

function numImgSamples=getNumImgSamplesForNIC(hNIC)
    hN=hNIC.Owner;

    if hNIC.isNetworkInstance&&hNIC.ReferenceNetwork.isStreamingMatrixPartition


        smt=[];
        samplesPerCycle=0;

        for i=1:numel(hNIC.PirInputSignals)
            sig=hNIC.PirInputSignals(i);
            pt=sig.getDrivers;

            if pt.hasStreamingMatrixTag
                smt=pt.getStreamingMatrixTag;
                [samplesPerCycle,~]=pirelab.getVectorTypeInfo(sig);
                break;
            end
        end

        assert(~isempty(smt));

        numelMatrix=smt.getOrigNumRows*smt.getOrigNumCols;
        numImgSamples=numelMatrix/samplesPerCycle;
    else
        numImgSamples=getNumImgSamples(hN);
    end
end
