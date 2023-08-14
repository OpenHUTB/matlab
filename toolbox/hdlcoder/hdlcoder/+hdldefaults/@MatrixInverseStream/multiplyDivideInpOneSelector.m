
function multiplyDivideInpOneSelector(~,hN,multiplyDivideInpOneSelInSigs,multiplyDivideInpOneSelOutSigs,...
    hCounterT,hInputDataT,hBoolT,slRate,blockInfo)





    hmulDivInpOneN=pirelab.createNewNetwork(...
    'Name','multiplyDivideInpOneSelector',...
    'InportNames',{'rowCountReg','reciprocalValidOutReg','diagReciprocalDataReg','readDataReg'},...
    'InportTypes',[hCounterT,hBoolT,hInputDataT,multiplyDivideInpOneSelInSigs(4).Type],...
    'InportRates',slRate*ones(1,4),...
    'OutportNames',{'multiplyDivideInpOne'},...
    'OutportTypes',hInputDataT);

    hmulDivInpOneN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hmulDivInpOneN.PirOutputSignals)
        hmulDivInpOneN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hmulDivInpOneNinSigs=hmulDivInpOneN.PirInputSignals;
    hmulDivInpOneNoutSigs=hmulDivInpOneN.PirOutputSignals;

    rowCountReg=hmulDivInpOneNinSigs(1);
    reciprocalValidOutReg=hmulDivInpOneNinSigs(2);
    diagReciprocalDataReg=hmulDivInpOneNinSigs(3);
    readDataReg=hmulDivInpOneNinSigs(4);

    multiplyDivideInpOne=hmulDivInpOneNoutSigs(1);



    pirTyp3=multiplyDivideInpOneSelInSigs(4).Type.BaseType;
    pirTyp4=pir_unsigned_t(8);

    if blockInfo.MatrixSize==1
        hArrayT=pirTyp3;
    else
        hArrayT=pirelab.createPirArrayType(pirTyp3,[blockInfo.MatrixSize,0]);
    end

    DataTypeConversion_out1_s4=l_addSignal(hmulDivInpOneN,'Data Type Conversion_out1',pirTyp4,slRate);
    Selector_out1_s5=l_addSignal(hmulDivInpOneN,'Selector_out1',hArrayT,slRate);
    Selector1_out1_s6=l_addSignal(hmulDivInpOneN,'Selector1_out1',pirTyp3,slRate);


    pirelab.getDTCComp(hmulDivInpOneN,...
    rowCountReg,...
    DataTypeConversion_out1_s4,...
    'Floor','Wrap','RWV','Data Type Conversion');






    pirelab.getSelectorComp(hmulDivInpOneN,...
    readDataReg,...
    Selector_out1_s5,...
    'One-based',{'Index vector (dialog)'},...
    {1:blockInfo.MatrixSize},...
    {'1'},'1',...
    'Selector');

    if blockInfo.MatrixSize==1
        pirelab.getWireComp(hmulDivInpOneN,Selector_out1_s5,Selector1_out1_s6,'SelectorOut1');
    else
        pirelab.getSelectorComp(hmulDivInpOneN,...
        [Selector_out1_s5,DataTypeConversion_out1_s4],...
        Selector1_out1_s6,...
        'One-based',{'Index vector (port)'},...
        {1:3},...
        {'1'},'1',...
        'Selector1');
    end



    pirelab.getSwitchComp(hmulDivInpOneN,...
    [diagReciprocalDataReg,Selector1_out1_s6],...
    multiplyDivideInpOne,...
    reciprocalValidOutReg,'Switch',...
    '~=',0,'Floor','Wrap');



    pirelab.instantiateNetwork(hN,hmulDivInpOneN,multiplyDivideInpOneSelInSigs,...
    multiplyDivideInpOneSelOutSigs,[hmulDivInpOneN.Name,'_inst']);


end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


