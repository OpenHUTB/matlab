

function LowerTriangularMatrixMultiplication(this,hN,MatMultInSigs,MatMultOutSigs,...
    hBoolT,hInputDataT,hCounterT,slRate,blockInfo)



    hMatMultN=pirelab.createNewNetwork(...
    'Name','LowerTriangularMatrixMultiplication',...
    'InportNames',{'fwdSubDone','rdData'},...
    'InportTypes',[hBoolT,pirelab.createPirArrayType(hInputDataT,[blockInfo.RowSize+1,0])],...
    'InportRates',slRate*ones(1,2),...
    'OutportNames',{'matMultEnb','invDone','wrEnbMatMult','wrAddrMatMult','wrDataMatMult','rdAddrMatMult'},...
    'OutportTypes',[hBoolT,hBoolT,MatMultOutSigs(3).Type,...
    MatMultOutSigs(4).Type,...
    MatMultOutSigs(5).Type,...
    MatMultOutSigs(6).Type]);

    hMatMultN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hMatMultN.PirOutputSignals)
        hMatMultN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hMatMultNinSigs=hMatMultN.PirInputSignals;
    hMatMultNoutSigs=hMatMultN.PirOutputSignals;


    colCountS=l_addSignal(hMatMultN,'colCount',hCounterT,slRate);
    matMultRdEnbS=l_addSignal(hMatMultN,'matMultRdEnb',hBoolT,slRate);
    rowCountRegS=l_addSignal(hMatMultN,'rowCountReg',hCounterT,slRate);
    colCountRegS=l_addSignal(hMatMultN,'colCountReg',hCounterT,slRate);
    matMultEnbRegS=l_addSignal(hMatMultN,'matMultEnbReg',hBoolT,slRate);
    prodDataS=l_addSignal(hMatMultN,'prodData',hInputDataT,slRate);
    prodValidS=l_addSignal(hMatMultN,'prodValid',hBoolT,slRate);
    colCountOutS=l_addSignal(hMatMultN,'colCountOut',hCounterT,slRate);
    rowCountOutS=l_addSignal(hMatMultN,'rowCountOut',hCounterT,slRate);





    MatMultEnbInSigs=[hMatMultNinSigs(1),hMatMultNoutSigs(2)];
    MatMultEnbOutSigs=hMatMultNoutSigs(1);

    this.MatMultEnableBlock(hMatMultN,MatMultEnbInSigs,MatMultEnbOutSigs,hBoolT,...
    slRate);


    LTMultControlInSigs=[hMatMultNinSigs(1),hMatMultNoutSigs(2)];
    LTMultControlOutSigs=[colCountS,matMultRdEnbS,rowCountRegS,colCountRegS,...
    matMultEnbRegS];

    this.LTMultController(hMatMultN,LTMultControlInSigs,LTMultControlOutSigs,...
    hBoolT,hCounterT,slRate,blockInfo);


    LTMultMACInSigs=[rowCountRegS,colCountRegS,matMultEnbRegS,hMatMultNinSigs(2)];
    LTMultMACOutSigs=[prodDataS,prodValidS,colCountOutS,rowCountOutS,hMatMultNoutSigs(2)];

    this.LTMultMAC(hMatMultN,LTMultMACInSigs,LTMultMACOutSigs,hBoolT,hCounterT,...
    hInputDataT,slRate,blockInfo);



    MatMultMemControlInSigs=[colCountS,matMultRdEnbS,prodDataS,prodValidS,...
    colCountOutS,rowCountOutS];
    MatMultMemControlOutSigs=[hMatMultNoutSigs(6),hMatMultNoutSigs(3),...
    hMatMultNoutSigs(4),hMatMultNoutSigs(5)];

    this.MatMultMemoryControl(hMatMultN,MatMultMemControlInSigs,MatMultMemControlOutSigs,...
    hBoolT,hCounterT,hInputDataT,slRate,blockInfo);

    pirelab.instantiateNetwork(hN,hMatMultN,MatMultInSigs,MatMultOutSigs,...
    [hMatMultN.Name,'_inst']);
end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end
