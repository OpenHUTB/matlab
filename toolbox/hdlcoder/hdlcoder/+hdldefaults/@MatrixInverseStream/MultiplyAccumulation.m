

function MultiplyAccumulation(~,hN,MACInSigs,MACOutSigs,slRate,blockInfo)


    hMACN=pirelab.createNewNetwork(...
    'Name','MultiplyAccumulation',...
    'InportNames',{'MultDataIn','dataValidIn'},...
    'InportTypes',[MACInSigs(1).Type,MACInSigs(2).Type],...
    'InportRates',slRate*ones(1,2),...
    'OutportNames',{'prodData','prodValid'},...
    'OutportTypes',[MACOutSigs(1).Type,MACOutSigs(2).Type]);

    hMACN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hMACN.PirOutputSignals)
        hMACN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hMACNinSigs=hMACN.PirInputSignals;
    hMACNoutSigs=hMACN.PirOutputSignals;



    MultDataIn=hMACNinSigs(1);
    dataValidIn=hMACNinSigs(2);

    prodData=hMACNoutSigs(1);
    prodValid=hMACNoutSigs(2);


    hInputDataT=pir_single_t;


    MultDataInSplitS=MultDataIn.split;

    MultOutArray=hdlhandles(blockInfo.RowSize,1);

    ProdOutS=hdlhandles(blockInfo.RowSize,1);
    DelayProdOutS=hdlhandles(blockInfo.RowSize,1);


    numMult=0;


    for itr=1:2:(blockInfo.RowSize*2)
        suffix=['_',int2str(numMult+1)];

        ProdOutS(itr)=l_addSignal(hMACN,['ProdOut',suffix],hInputDataT,slRate);
        DelayProdOutS(itr)=l_addSignal(hMACN,['DelayProdOut',suffix],hInputDataT,slRate);

        hMultC=pirelab.getMulComp(hMACN,...
        [MultDataInSplitS.PirOutputSignals(itr),MultDataInSplitS.PirOutputSignals(itr+1)],...
        ProdOutS(itr),...
        'Floor','Wrap',['Product',suffix],'**','',-1,0);

        pirelab.getIntDelayComp(hMACN,...
        ProdOutS(itr),...
        DelayProdOutS(itr),...
        resolveLatencyForIPType(hMultC,'MUL'),['Delay',suffix],...
        single(0),...
        0,0,[],0,0);

        numMult=numMult+1;
        MultOutArray(numMult)=DelayProdOutS(itr);

    end




    numStages=ceil(log2(blockInfo.RowSize));


    if(bitand(numMult,1)==1)
        endVal=numMult-2;
    else
        endVal=numMult-1;
    end



    AddInArray=hdlhandles(blockInfo.RowSize,numStages);


    AddInArray(:,1)=MultOutArray;



    prevLenAdd=numMult;
    prsntLenAdd=0;

    addCount=0;



    for i=1:numStages
        for j=1:2:endVal

            prsntLenAdd=prsntLenAdd+1;
            suffix1=['_',int2str(i)];
            suffix2=['_',int2str(prsntLenAdd)];

            addCount=addCount+1;
            AddOutS=l_addSignal(hMACN,['AddOut',suffix1,suffix2],hInputDataT,slRate);
            DelayOutS=l_addSignal(hMACN,['DelayOut',suffix1,suffix2],hInputDataT,slRate);


            hAddC=pirelab.getAddComp(hMACN,...
            [AddInArray(j,i),AddInArray(j+1,i)],...
            AddOutS,...
            'Floor','Wrap',['Add',suffix1,suffix2],hInputDataT,'++');



            pirelab.getIntDelayComp(hMACN,...
            AddOutS,...
            DelayOutS,...
            resolveLatencyForIPType(hAddC,'ADDSUB'),['Delay',suffix1,suffix2],...
            single(0),...
            0,0,[],0,0);



            if(i+1<=numStages)
                AddInArray(prsntLenAdd,i+1)=DelayOutS;
            end



            if(i+1>numStages)
                pirelab.getWireComp(hMACN,...
                DelayOutS,...
                prodData,...
                'prodOutput');
            end
        end



        if(bitand(prevLenAdd,1)==1)

            DelayLastS=l_addSignal(hMACN,['DelayLast',suffix1,int2str(prsntLenAdd)],hInputDataT,slRate);
            prsntLenAdd=prsntLenAdd+1;

            pirelab.getIntDelayComp(hMACN,...
            AddInArray(prevLenAdd,i),...
            DelayLastS,...
            resolveLatencyForIPType(hAddC,'ADDSUB'),['Delay',suffix1,int2str(prsntLenAdd)],...
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



    if(blockInfo.RowSize==1)

        pirelab.getWireComp(hMACN,...
        MultOutArray(numMult),...
        prodData,...
        'prodOutput');


        pirelab.getIntDelayComp(hMACN,...
        dataValidIn,...
        prodValid,...
        (resolveLatencyForIPType(hMultC,'MUL')),...
        'prodValid',...
        false,...
        0,0,[],0,0);
    else

        pirelab.getIntDelayComp(hMACN,...
        dataValidIn,...
        prodValid,...
        ((numStages*resolveLatencyForIPType(hAddC,'ADDSUB'))+resolveLatencyForIPType(hMultC,'MUL')),...
        'prodValid',...
        false,...
        0,0,[],0,0);
    end










    pirelab.instantiateNetwork(hN,hMACN,MACInSigs,MACOutSigs,...
    [hMACN.Name,'_inst']);

end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end

function latency=resolveLatencyForIPType(hC,targetIPType)

    hDriver=hdlcurrentdriver;

    p=pir(hC.Owner.getCtxName);
    targetCompDataType='SINGLE';
    targetDriver=hDriver.getTargetCodeGenDriver(p);
    if isempty(targetDriver)||~strcmpi(class(targetDriver),'targetcodegen.nfpdriver')
        latency=-1;
        return;
    end
    latency=targetDriver.getDefaultLatency(targetIPType,targetCompDataType,hC);
end


