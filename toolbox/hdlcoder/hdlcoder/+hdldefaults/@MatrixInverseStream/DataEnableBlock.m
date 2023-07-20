

function DataEnableBlock(this,hN,DataEnbInSigs,DataEnbOutSigs,hBoolT,hCounterT,...
    slRate,blockInfo)


    hDataEnbN=pirelab.createNewNetwork(...
    'Name','DataEnableBlock',...
    'InportNames',{'fwdSubEnb','startPulse','rowProcDone','fwdSubDone'},...
    'InportTypes',[hBoolT,hBoolT,hBoolT,hBoolT],...
    'InportRates',slRate*ones(1,4),...
    'OutportNames',{'rowCount','colCount','diagonalEn','nonDiagonalEn'},...
    'OutportTypes',[hCounterT,hCounterT,hBoolT,hBoolT]);

    hDataEnbN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hDataEnbN.PirOutputSignals)
        hDataEnbN.PirOutputSignals(ii).SimulinkRate=slRate;
    end


    colCountS=l_addSignal(hDataEnbN,'colCount',hCounterT,slRate);
    rowCountEnS=l_addSignal(hDataEnbN,'rowCountEn',hBoolT,slRate);
    colCountEnS=l_addSignal(hDataEnbN,'colCountEn',hBoolT,slRate);
    validS=l_addSignal(hDataEnbN,'valid',hBoolT,slRate);



    hDataEnbNinSigs=hDataEnbN.PirInputSignals;
    hDataEnbNoutSigs=hDataEnbN.PirOutputSignals;



    DataVldGenInSigs=[hDataEnbNinSigs(2),hDataEnbNinSigs(1),hDataEnbNinSigs(3),...
    colCountS];
    DataVldGenOutSigs=[rowCountEnS,colCountEnS,validS];

    this.DataValidGenerator(hDataEnbN,DataVldGenInSigs,DataVldGenOutSigs,hBoolT,...
    hCounterT,slRate,blockInfo);



    CntVldDecoderInSigs=[hDataEnbNinSigs(2),rowCountEnS,colCountEnS,validS,hDataEnbNinSigs(4)];
    CntVldDecoderOutSigs=[hDataEnbNoutSigs(1),hDataEnbNoutSigs(2),...
    hDataEnbNoutSigs(3),hDataEnbNoutSigs(4),colCountS];

    this.DataCounterAndValidDecoder(hDataEnbN,CntVldDecoderInSigs,CntVldDecoderOutSigs,...
    hBoolT,hCounterT,slRate,blockInfo);


    pirelab.instantiateNetwork(hN,hDataEnbN,DataEnbInSigs,DataEnbOutSigs,...
    [hDataEnbN.Name,'_inst']);

end



function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


