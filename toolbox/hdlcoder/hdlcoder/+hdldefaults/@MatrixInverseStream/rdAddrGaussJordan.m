

function rdAddrGaussJordan(~,hN,RdAddrLTInSigs,RdAddrLTOutSigs,hBoolT,hCounterT,...
    hAddrT,slRate,blockInfo)




    hRdAddrLTN=pirelab.createNewNetwork(...
    'Name','rdAddrGaussJordan',...
    'InportNames',{'processingEnb','colCount'},...
    'InportTypes',[hBoolT,hCounterT],...
    'InportRates',slRate*ones(1,2),...
    'OutportNames',{'rdAddrGJ'},...
    'OutportTypes',pirelab.createPirArrayType(hAddrT,[blockInfo.MatrixSize*2,0]));

    hRdAddrLTN.setTargetCompReplacementCandidate(true);

    for ii=1:numel(hRdAddrLTN.PirOutputSignals)
        hRdAddrLTN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hRdAddrLTNinSigs=hRdAddrLTN.PirInputSignals;
    hRdAddrLTNoutSigs=hRdAddrLTN.PirOutputSignals;

    processingEnb=hRdAddrLTNinSigs(1);
    colCount=hRdAddrLTNinSigs(2);

    rdAddrGJ=hRdAddrLTNoutSigs(1);

    pirTyp4=pir_sfixpt_t(ceil(log2(blockInfo.MatrixSize))+2,0);
    pirTyp3=hAddrT;
    pirTyp2=hCounterT;

    Constant_out1_s3=l_addSignal(hRdAddrLTN,'Constant_out1',pirTyp2,slRate);
    Constant1_out1_s4=l_addSignal(hRdAddrLTN,'Constant1_out1',pirTyp3,slRate);
    Constant2_out1_s5=l_addSignal(hRdAddrLTN,'Constant2_out1',pirelab.createPirArrayType(pirTyp3,[blockInfo.MatrixSize*2,0]),slRate);
    Subtract_out1_s6=l_addSignal(hRdAddrLTN,'Subtract_out1',pirTyp3,slRate);
    Switch_out1_s7=l_addSignal(hRdAddrLTN,'Switch_out1',pirTyp3,slRate);


    pirelab.getConstComp(hRdAddrLTN,...
    Constant_out1_s3,...
    1,...
    'Constant','on',0,'','','');



    pirelab.getConstComp(hRdAddrLTN,...
    Constant1_out1_s4,...
    0,...
    'Constant1','on',1,'','','');



    pirelab.getConstComp(hRdAddrLTN,...
    Constant2_out1_s5,...
    zeros(1,blockInfo.MatrixSize*2),...
    'Constant2','on',1,'','','');


    pirelab.getAssignmentComp(hRdAddrLTN,...
    [Constant2_out1_s5,Switch_out1_s7],...
    rdAddrGJ,...
    'One-based',{'Assign all'},...
    {1},...
    {'1'},'1',...
    'Assignment1');




    pirelab.getAddComp(hRdAddrLTN,...
    [colCount,Constant_out1_s3],...
    Subtract_out1_s6,...
    'Floor','Wrap','Subtract',pirTyp4,'+-');



    pirelab.getSwitchComp(hRdAddrLTN,...
    [Subtract_out1_s6,Constant1_out1_s4],...
    Switch_out1_s7,...
    processingEnb,'Switch',...
    '~=',0,'Floor','Wrap');



    pirelab.instantiateNetwork(hN,hRdAddrLTN,RdAddrLTInSigs,RdAddrLTOutSigs,...
    [hRdAddrLTN.Name,'_inst']);

end

function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


