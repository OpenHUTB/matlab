

function gaussJordanDiagDataInpGen(~,hN,LTDiagDataComputationInSigs,LTDiagDataComputationOutSigs,...
    hInputDataT,hBoolT,slRate)



    hgaussJordanRecipN=pirelab.createNewNetwork(...
    'Name','gaussJordanDiagDataInpGen',...
    'InportNames',{'diagValidIn','diagDataIn','swapDone'},...
    'InportTypes',[hBoolT,hInputDataT,hBoolT],...
    'InportRates',slRate*ones(1,3),...
    'OutportNames',{'reciprocalValid','reciprocalData'},...
    'OutportTypes',[hBoolT,hInputDataT]);

    hgaussJordanRecipN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hgaussJordanRecipN.PirOutputSignals)
        hgaussJordanRecipN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hgaussJordanRecipNinSigs=hgaussJordanRecipN.PirInputSignals;
    hgaussJordanRecipNoutSigs=hgaussJordanRecipN.PirOutputSignals;

    diagValidIn=hgaussJordanRecipNinSigs(1);
    diagDataIn=hgaussJordanRecipNinSigs(2);
    swapDone=hgaussJordanRecipNinSigs(3);

    reciprocalValid=hgaussJordanRecipNoutSigs(1);
    reciprocalData=hgaussJordanRecipNoutSigs(2);


    pirTyp1=pir_boolean_t;
    pirTyp2=LTDiagDataComputationInSigs(2).Type;




    Constant_out1_s3=l_addSignal(hgaussJordanRecipN,'Constant_out1',pirTyp2,slRate);
    Delay_out1_s4=l_addSignal(hgaussJordanRecipN,'Delay_out1',pirTyp2,slRate);
    Delay6_out1_s6=l_addSignal(hgaussJordanRecipN,'Delay6_out1',pirTyp1,slRate);
    LogicalOperator_out1_s7=l_addSignal(hgaussJordanRecipN,sprintf('Logical\nOperator_out1'),pirTyp1,slRate);


    pirelab.getConstComp(hgaussJordanRecipN,...
    Constant_out1_s3,...
    0,...
    'Constant','on',1,'','','');


    pirelab.getWireComp(hgaussJordanRecipN,...
    diagDataIn,...
    Delay_out1_s4,...
    'Delay');


    pirelab.getWireComp(hgaussJordanRecipN,...
    LogicalOperator_out1_s7,...
    reciprocalValid,...
    'Delay1');




    pirelab.getIntDelayComp(hgaussJordanRecipN,...
    swapDone,...
    Delay6_out1_s6,...
    2,'Delay6',...
    false,...
    0,0,[],0,0);



    pirelab.getLogicComp(hgaussJordanRecipN,...
    [Delay6_out1_s6,diagValidIn],...
    LogicalOperator_out1_s7,...
    'and',sprintf('Logical\nOperator'));



    pirelab.getSwitchComp(hgaussJordanRecipN,...
    [Delay_out1_s4,Constant_out1_s3],...
    reciprocalData,...
    reciprocalValid,'Switch',...
    '~=',0,'Floor','Wrap');


    pirelab.instantiateNetwork(hN,hgaussJordanRecipN,LTDiagDataComputationInSigs,...
    LTDiagDataComputationOutSigs,[hgaussJordanRecipN.Name,'_inst']);

end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end
