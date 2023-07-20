
function subtractFirstInputSelector(~,hN,subtractFirstInpSelInSigs,subtractFirstInpSelOutSigs,...
    hCounterT,hInputDataT,slRate,blockInfo)





    hsubFirstInpN=pirelab.createNewNetwork(...
    'Name','subtractFirstInputSelector',...
    'InportNames',{'nonDiagValidInCount','readDataReg'},...
    'InportTypes',[hCounterT,subtractFirstInpSelInSigs(2).Type],...
    'InportRates',slRate*ones(1,2),...
    'OutportNames',{'subtractFirstInp','subtractFirstInpEyeMem'},...
    'OutportTypes',[hInputDataT,hInputDataT]);

    hsubFirstInpN.setTargetCompReplacementCandidate(true);

    for ii=1:numel(hsubFirstInpN.PirOutputSignals)
        hsubFirstInpN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hsubFirstInpNinSigs=hsubFirstInpN.PirInputSignals;
    hsubFirstInpNoutSigs=hsubFirstInpN.PirOutputSignals;

    nonDiagValidInCount=hsubFirstInpNinSigs(1);
    readDataReg=hsubFirstInpNinSigs(2);

    subtractFirstInp=hsubFirstInpNoutSigs(1);
    subtractFirstInpEyeMem=hsubFirstInpNoutSigs(2);


    pirTyp2=subtractFirstInpSelInSigs(2).Type.BaseType;
    pirTyp3=pir_unsigned_t(8);

    if blockInfo.MatrixSize==1
        hArrayT=pirTyp2;
    else
        hArrayT=pirelab.createPirArrayType(pirTyp2,[blockInfo.MatrixSize,0]);
    end



    DataTypeConversion_out1_s2=l_addSignal(hsubFirstInpN,'Data Type Conversion_out1',pirTyp3,slRate);
    Selector2_out1_s5=l_addSignal(hsubFirstInpN,'Selector2_out1',hArrayT,slRate);
    Selector3_out1_s6=l_addSignal(hsubFirstInpN,'Selector3_out1',hArrayT,slRate);


    pirelab.getDTCComp(hsubFirstInpN,...
    nonDiagValidInCount,...
    DataTypeConversion_out1_s2,...
    'Floor','Wrap','RWV','Data Type Conversion');


    if blockInfo.MatrixSize==1
        pirelab.getWireComp(hsubFirstInpN,Selector2_out1_s5,subtractFirstInp,'subtractFirstInp');
        pirelab.getWireComp(hsubFirstInpN,Selector3_out1_s6,subtractFirstInpEyeMem,'subtractFirstInpEyeMem');
    else

        pirelab.getSelectorComp(hsubFirstInpN,...
        [Selector2_out1_s5,DataTypeConversion_out1_s2],...
        subtractFirstInp,...
        'One-based',{'Index vector (port)'},...
        {1:3},...
        {'1'},'1',...
        'Selector');



        pirelab.getSelectorComp(hsubFirstInpN,...
        [Selector3_out1_s6,DataTypeConversion_out1_s2],...
        subtractFirstInpEyeMem,...
        'One-based',{'Index vector (port)'},...
        {1:3},...
        {'1'},'1',...
        'Selector1');
    end




    pirelab.getSelectorComp(hsubFirstInpN,...
    readDataReg,...
    Selector2_out1_s5,...
    'One-based',{'Index vector (dialog)'},...
    {1:blockInfo.MatrixSize},...
    {'1'},'1',...
    'Selector2');





    pirelab.getSelectorComp(hsubFirstInpN,...
    readDataReg,...
    Selector3_out1_s6,...
    'One-based',{'Index vector (dialog)'},...
    {blockInfo.MatrixSize+1:blockInfo.MatrixSize*2},...
    {'1'},'1',...
    'Selector3');





    pirelab.instantiateNetwork(hN,hsubFirstInpN,subtractFirstInpSelInSigs,...
    subtractFirstInpSelOutSigs,[hsubFirstInpN.Name,'_inst']);


end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


