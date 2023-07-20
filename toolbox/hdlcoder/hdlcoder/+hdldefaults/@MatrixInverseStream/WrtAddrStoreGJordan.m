
function WrtAddrStoreGJordan(~,hN,WrtAddrStoreInSigs,WrtAddrStoreOutSigs,...
    slRate,blockInfo)





    hWrtAddrStoreN=pirelab.createNewNetwork(...
    'Name','WrtAddrStoreGJordan',...
    'InportNames',{'colCount','validRdy'},...
    'InportTypes',[WrtAddrStoreInSigs(1).Type,WrtAddrStoreInSigs(2).Type],...
    'InportRates',slRate*ones(1,2),...
    'OutportNames',{'wrtAddrStore'},...
    'OutportTypes',WrtAddrStoreOutSigs(1).Type);

    hWrtAddrStoreN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hWrtAddrStoreN.PirOutputSignals)
        hWrtAddrStoreN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hWrtAddrStoreNinSigs=hWrtAddrStoreN.PirInputSignals;
    hWrtAddrStoreNoutSigs=hWrtAddrStoreN.PirOutputSignals;


    colCount=hWrtAddrStoreNinSigs(1);
    validRdy=hWrtAddrStoreNinSigs(2);

    wrtAddrStore=hWrtAddrStoreNoutSigs(1);

    pirTyp4=pir_sfixpt_t(ceil(log2(blockInfo.MatrixSize))+2,0);
    if blockInfo.MatrixSize==1
        pirTyp3=pir_ufixpt_t(1,0);
    else
        pirTyp3=pir_ufixpt_t(ceil(log2(blockInfo.MatrixSize)),0);
    end
    pirTyp1=pir_ufixpt_t(ceil(log2(blockInfo.MatrixSize))+1,0);




    Constant_out1_s3=l_addSignal(hWrtAddrStoreN,'Constant_out1',pirTyp1,slRate);
    Constant1_out1_s4=l_addSignal(hWrtAddrStoreN,'Constant1_out1',pirTyp3,slRate);
    Constant2_out1_s5=l_addSignal(hWrtAddrStoreN,'Constant2_out1',pirelab.createPirArrayType(pirTyp3,[blockInfo.MatrixSize*2,0]),slRate);
    Subtract_out1_s6=l_addSignal(hWrtAddrStoreN,'Subtract_out1',pirTyp3,slRate);
    Switch_out1_s7=l_addSignal(hWrtAddrStoreN,'Switch_out1',pirTyp3,slRate);


    pirelab.getConstComp(hWrtAddrStoreN,...
    Constant_out1_s3,...
    1,...
    'Constant','on',0,'','','');




    pirelab.getConstComp(hWrtAddrStoreN,...
    Constant1_out1_s4,...
    0,...
    'Constant1','on',1,'','','');



    pirelab.getConstComp(hWrtAddrStoreN,...
    Constant2_out1_s5,...
    zeros(1,blockInfo.MatrixSize*2),...
    'Constant2','on',1,'','','');



    pirelab.getAssignmentComp(hWrtAddrStoreN,...
    [Constant2_out1_s5,Switch_out1_s7],...
    wrtAddrStore,...
    'One-based',{'Assign all'},...
    {1},...
    {'1'},'1',...
    'Assignment1');




    pirelab.getAddComp(hWrtAddrStoreN,...
    [colCount,Constant_out1_s3],...
    Subtract_out1_s6,...
    'Floor','Wrap','Subtract',pirTyp4,'+-');




    pirelab.getSwitchComp(hWrtAddrStoreN,...
    [Subtract_out1_s6,Constant1_out1_s4],...
    Switch_out1_s7,...
    validRdy,'Switch',...
    '~=',0,'Floor','Wrap');


    pirelab.instantiateNetwork(hN,hWrtAddrStoreN,WrtAddrStoreInSigs,...
    WrtAddrStoreOutSigs,[hWrtAddrStoreN.Name,'_inst']);
end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end


