

function WrtEnbStoreGJordan(~,hN,WrtEnbStoreInSigs,WrtEnbStoreOutSigs,...
    slRate,blockInfo)





    hWrtEnbStoreN=pirelab.createNewNetwork(...
    'Name','WrtEnbStoreGJordan',...
    'InportNames',{'validIn','rowCount'},...
    'InportTypes',[WrtEnbStoreInSigs(1).Type,WrtEnbStoreInSigs(2).Type],...
    'InportRates',slRate*ones(1,2),...
    'OutportNames',{'wrtEnbStore'},...
    'OutportTypes',WrtEnbStoreOutSigs(1).Type);

    hWrtEnbStoreN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hWrtEnbStoreN.PirOutputSignals)
        hWrtEnbStoreN.PirOutputSignals(ii).SimulinkRate=slRate;
    end


    hWrtEnbStoreNinSigs=hWrtEnbStoreN.PirInputSignals;
    hWrtEnbStoreNoutSigs=hWrtEnbStoreN.PirOutputSignals;


    ValidRdy=hWrtEnbStoreNinSigs(1);
    rowCount=hWrtEnbStoreNinSigs(2);

    wrtEnbStore=hWrtEnbStoreNoutSigs(1);

    pirTyp1=pir_boolean_t;

    pirTyp3=pir_unsigned_t(8);

    if blockInfo.MatrixSize==1
        hArrayT=pirTyp1;
    else
        hArrayT=pirelab.createPirArrayType(pirTyp1,[blockInfo.MatrixSize,0]);
    end

    Assignment_out1_s2=l_addSignal(hWrtEnbStoreN,'Assignment_out1',hArrayT,slRate);
    Constant_out1_s3=l_addSignal(hWrtEnbStoreN,'Constant_out1',hArrayT,slRate);
    DataTypeConversion_out1_s4=l_addSignal(hWrtEnbStoreN,'Data Type Conversion_out1',pirTyp3,slRate);



    pirelab.getConstComp(hWrtEnbStoreN,...
    Constant_out1_s3,...
    zeros(1,blockInfo.MatrixSize),...
    'Constant','on',1,'','','');



    if blockInfo.MatrixSize==1
        pirelab.getWireComp(hWrtEnbStoreN,ValidRdy,Assignment_out1_s2,'AssignmentOut');

    else
        pirelab.getAssignmentComp(hWrtEnbStoreN,...
        [Constant_out1_s3,ValidRdy,DataTypeConversion_out1_s4],...
        Assignment_out1_s2,...
        'One-based',{'Index vector (port)'},...
        {1},...
        {'1'},'1',...
        'Assignment');
    end



    pirelab.getDTCComp(hWrtEnbStoreN,...
    rowCount,...
    DataTypeConversion_out1_s4,...
    'Floor','Wrap','RWV','Data Type Conversion');



    pirelab.getMuxComp(hWrtEnbStoreN,...
    [Assignment_out1_s2,Assignment_out1_s2],...
    wrtEnbStore,...
    'concatenate');



    pirelab.instantiateNetwork(hN,hWrtEnbStoreN,WrtEnbStoreInSigs,...
    WrtEnbStoreOutSigs,[hWrtEnbStoreN.Name,'_inst']);
end

function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


