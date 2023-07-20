

function MatMultSubsystem(this,hN,MatMultSubInSigs,MatMultSubOutSigs,...
    slRate,blockInfo)


    hMatMultSubN=pirelab.createNewNetwork(...
    'Name','MatMultSubsystem',...
    'InportNames',{'colCount','rowCount','dataValidIn','rdData'},...
    'InportTypes',[MatMultSubInSigs(1).Type,MatMultSubInSigs(2).Type,...
    MatMultSubInSigs(3).Type,MatMultSubInSigs(4).Type],...
    'InportRates',slRate*ones(1,4),...
    'OutportNames',{'prodData','prodValid'},...
    'OutportTypes',[MatMultSubOutSigs(1).Type,MatMultSubOutSigs(2).Type]);

    hMatMultSubN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hMatMultSubN.PirOutputSignals)
        hMatMultSubN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hMatMultSubNinSigs=hMatMultSubN.PirInputSignals;
    hMatMultSubNoutSigs=hMatMultSubN.PirOutputSignals;


    hBoolT=pir_boolean_t;
    hInputDataT=pir_single_t;


    compareIndexS=l_addSignal(hMatMultSubN,'compareIndex',hBoolT,slRate);

    if blockInfo.RowSize>1
        colDataS=l_addSignal(hMatMultSubN,'colData',...
        pirelab.createPirArrayType(hInputDataT,[blockInfo.RowSize,0]),slRate);
    else
        colDataS=l_addSignal(hMatMultSubN,'colData',...
        hInputDataT,slRate);
    end


    MultDataInS=l_addSignal(hMatMultSubN,'MultDataIn',...
    pirelab.createPirArrayType(hInputDataT,[blockInfo.RowSize*2,0]),slRate);


    pirelab.getRelOpComp(hMatMultSubN,...
    [hMatMultSubNinSigs(1),hMatMultSubNinSigs(2)],...
    compareIndexS,...
    '==',0,'compareIndex');


    ColDataSelInSigs=[hMatMultSubNinSigs(1),hMatMultSubNinSigs(4)];
    ColDataSelOutSigs=colDataS;

    this.ColDataSelector(hMatMultSubN,ColDataSelInSigs,ColDataSelOutSigs,...
    slRate,blockInfo);


    MultBufInSigs=[compareIndexS,colDataS];
    MultBufOutSigs=MultDataInS;

    this.MultBuffer(hMatMultSubN,MultBufInSigs,MultBufOutSigs,slRate,blockInfo);


    MACInSigs=[MultDataInS,hMatMultSubNinSigs(3)];
    MACOutSigs=[hMatMultSubNoutSigs(1),hMatMultSubNoutSigs(2)];

    this.MultiplyAccumulation(hMatMultSubN,MACInSigs,MACOutSigs,slRate,blockInfo);

    pirelab.instantiateNetwork(hN,hMatMultSubN,MatMultSubInSigs,MatMultSubOutSigs,...
    [hMatMultSubN.Name,'_inst']);
end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end
