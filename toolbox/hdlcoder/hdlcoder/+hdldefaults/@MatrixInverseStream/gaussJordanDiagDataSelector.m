
function gaussJordanDiagDataSelector(~,hN,DiagDataSelectorInSigs,DiagDataSelectorOutSigs,...
    hCounterT,hInputDataT,slRate,blockInfo)



    hDiagDataSelN=pirelab.createNewNetwork(...
    'Name','gaussJordanDiagDataSelector',...
    'InportNames',{'rowCount','readDataIn'},...
    'InportTypes',[hCounterT,DiagDataSelectorInSigs(2).Type],...
    'InportRates',slRate*ones(1,2),...
    'OutportNames',{'diagDataIn'},...
    'OutportTypes',hInputDataT);

    hDiagDataSelN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hDiagDataSelN.PirOutputSignals)
        hDiagDataSelN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hDiagDataSelNinSigs=hDiagDataSelN.PirInputSignals;
    hDiagDataSelNoutSigs=hDiagDataSelN.PirOutputSignals;

    rowCount=hDiagDataSelNinSigs(1);
    readDataIn=hDiagDataSelNinSigs(2);

    diagDataIn=hDiagDataSelNoutSigs(1);

    pirTyp3=pir_unsigned_t(8);






    DataTypeConversion_out1_s2=l_addSignal(hDiagDataSelN,'Data Type Conversion_out1',pirTyp3,slRate);


    pirelab.getDTCComp(hDiagDataSelN,...
    rowCount,...
    DataTypeConversion_out1_s2,...
    'Floor','Wrap','RWV','Data Type Conversion');

    if blockInfo.MatrixSize==1
        pirelab.getWireComp(hDiagDataSelN,readDataIn,diagDataIn,'diagDataIn');

    else
        pirelab.getSelectorComp(hDiagDataSelN,...
        [readDataIn,DataTypeConversion_out1_s2],...
        diagDataIn,...
        'One-based',{'Index vector (port)'},...
        {1:3},...
        {'1'},'1',...
        'Selector');
    end





    pirelab.instantiateNetwork(hN,hDiagDataSelN,DiagDataSelectorInSigs,...
    DiagDataSelectorOutSigs,[hDiagDataSelN.Name,'_inst']);


end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


