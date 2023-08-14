function hdotN=dotProduct(~,hProcN,hInSigs,hOutSigs,slRate,blockInfo)



    hBoolT=pir_boolean_t;
    if(blockInfo.dotProductSize~=1)
        inputDataT=hInSigs(1).Type.BaseType;
    else
        inputDataT=hInSigs(1).Type;
    end
    if(blockInfo.dotProductSize~=1)
        hdpSizeArrayT=hProcN.getType('Array','BaseType',inputDataT,'Dimensions',blockInfo.dotProductSize);
    else
        hdpSizeArrayT=hInSigs(1).Type;
    end

    hdotN=pirelab.createNewNetwork(...
    'Name','dotProduct',...
    'InportNames',{'aRdData','dataValid','bRdData'},...
    'InportTypes',[hdpSizeArrayT,hBoolT,hdpSizeArrayT],...
    'InportRates',slRate*ones(1,3),...
    'OutportNames',{'sumValid','sum'},...
    'OutportTypes',[hBoolT,inputDataT]);
    hdotN.setTargetCompReplacementCandidate(true);
    for ii=1:numel(hdotN.PirOutputSignals)
        hdotN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    pirelab.instantiateNetwork(hProcN,hdotN,hInSigs,hOutSigs,...
    [hdotN.Name,'_inst']);


    aRdDataS=hdotN.PirInputSignals(1);
    dataValidInS=hdotN.PirInputSignals(2);
    bRdDataS=hdotN.PirInputSignals(3);
    sumValidS=hdotN.PirOutputSignals(1);
    tempSumS=hdotN.PirOutputSignals(2);
    sumS=l_addSignal(hdotN,'tempSumS',inputDataT,slRate);


    if(blockInfo.dotProductSize~=1)
        aRdDataSplitS=aRdDataS.split;
        aRdDataSplitSigS=aRdDataSplitS.PirOutputSignals;

        bRdDataSplitS=bRdDataS.split;
        bRdDataSplitSigS=bRdDataSplitS.PirOutputSignals;

    else
        aRdDataSplitSigS=aRdDataS;
        bRdDataSplitSigS=bRdDataS;
    end


    MultOutArray=hdlhandles(blockInfo.dotProductSize,1);


    numMult=0;


    for itr=1:blockInfo.dotProductSize
        suffix=['_',int2str(numMult+1)];

        ProdOutS=l_addSignal(hdotN,['ProdOut',suffix],inputDataT,slRate);
        DelayProdOutS=l_addSignal(hdotN,['DelayProdOut',suffix],inputDataT,slRate);

        hC=pirelab.getMulComp(hdotN,...
        [aRdDataSplitSigS(itr),bRdDataSplitSigS(itr)],...
        ProdOutS,...
        'Floor','Wrap',['Product',suffix],'**','',-1,0);

        pirelab.getIntDelayComp(hdotN,...
        ProdOutS,...
        DelayProdOutS,...
        resolveLatencyForIPType(hC,'MUL'),['Delay',suffix],...
        single(0),...
        0,0,[],0,0);

        numMult=numMult+1;
        MultOutArray(numMult)=DelayProdOutS;

    end




    numStages=ceil(log2(blockInfo.dotProductSize));


    if(bitand(numMult,1)==1)
        endVal=numMult-2;
    else
        endVal=numMult-1;
    end

    if(blockInfo.dotProductSize>1)

        AddInArray=hdlhandles(blockInfo.dotProductSize,numStages);
    else
        AddInArray=hdlhandles(blockInfo.dotProductSize,1);
    end

    AddInArray(:,1)=MultOutArray;



    prevLenAdd=numMult;
    prsntLenAdd=0;

    addCount=0;

    if blockInfo.dotProductSize==1
        pirelab.getWireComp(hdotN,...
        MultOutArray(numMult),...
        sumS,...
        'prodDp1Output');
    end


    for i=1:numStages
        for j=1:2:endVal
            prsntLenAdd=prsntLenAdd+1;
            suffix1=['_',int2str(i)];
            suffix2=['_',int2str(prsntLenAdd)];
            addCount=addCount+1;
            AddOutS=l_addSignal(hdotN,['AddOut',suffix1,suffix2],inputDataT,slRate);
            DelayOutS=l_addSignal(hdotN,['DelayOut',suffix1,suffix2],inputDataT,slRate);
            hA=pirelab.getAddComp(hdotN,...
            [AddInArray(j,i),AddInArray(j+1,i)],...
            AddOutS,...
            'Floor','Wrap',['Add',suffix1,suffix2],inputDataT,'++');
            pirelab.getIntDelayComp(hdotN,...
            AddOutS,...
            DelayOutS,...
            resolveLatencyForIPType(hA,'ADDSUB'),['Delay',suffix1,suffix2],...
            single(0),...
            0,0,[],0,0);



            if(i+1<=numStages)
                AddInArray(prsntLenAdd,i+1)=DelayOutS;
            end



            if(i+1>numStages)
                pirelab.getWireComp(hdotN,...
                DelayOutS,...
                sumS,...
                'prodOutput');
            end
        end



        if(bitand(prevLenAdd,1)==1)

            DelayLastS=l_addSignal(hdotN,['DelayLast',suffix1,int2str(prsntLenAdd)],inputDataT,slRate);
            prsntLenAdd=prsntLenAdd+1;

            pirelab.getIntDelayComp(hdotN,...
            AddInArray(prevLenAdd,i),...
            DelayLastS,...
            11,['Delay',suffix1,int2str(prsntLenAdd)],...
            single(0),...
            0,0,[],0,0);

            AddInArray(prsntLenAdd,i+1)=DelayLastS;
        end


        if(bitand(prsntLenAdd,1)==1)
            endVal=prsntLenAdd-2;
        else
            endVal=prsntLenAdd-1;
        end



        prevLenAdd=prsntLenAdd;
        prsntLenAdd=0;

    end
    dimLen=blockInfo.dotProductSize;
    numStages=ceil(log2(dimLen));
    mulLatency=resolveLatencyForIPType(hC,'MUL');
    if(blockInfo.dotProductSize~=1)
        addLatency=resolveLatencyForIPType(hA,'ADDSUB');
    else
        addLatency=0;
    end

    latency=mulLatency+((numStages)*addLatency);


    pirelab.getWireComp(hdotN,...
    sumS,...
    tempSumS,...
    'tempSumS');


    pirelab.getIntDelayComp(hdotN,...
    dataValidInS,...
    sumValidS,...
    latency,'sumValid',...
    false,...
    0,0,[],0,0);

end

function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end
function componentLatency=resolveLatencyForIPType(hC,targetIPType)

    hDriver=hdlcurrentdriver;

    p=pir(hC.Owner.getCtxName);
    targetCompDataType='SINGLE';
    targetDriver=hDriver.getTargetCodeGenDriver(p);
    if isempty(targetDriver)||~strcmpi(class(targetDriver),'targetcodegen.nfpdriver')
        componentLatency=-1;
        return;
    end

    componentLatency=targetDriver.getDefaultLatency(targetIPType,targetCompDataType,[]);
end

