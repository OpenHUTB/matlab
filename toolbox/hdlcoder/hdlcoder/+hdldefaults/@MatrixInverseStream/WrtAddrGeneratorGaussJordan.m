

function WrtAddrGeneratorGaussJordan(~,hN,WrtAddrGenInSigs,WrtAddrGenOutSigs,hBoolT,hAddrT,...
    slRate,blockInfo)




    hWrtAddrGenN=pirelab.createNewNetwork(...
    'Name','WrtAddrGeneratorGaussJordan',...
    'InportNames',{'validIn','ready','processingEnb','wrtAddrStore',...
    'wrtAddrLT'},...
    'InportTypes',[hBoolT,hBoolT,hBoolT,...
    WrtAddrGenInSigs(4).Type,...
    WrtAddrGenInSigs(5).Type],...
    'InportRates',slRate*ones(1,5),...
    'OutportNames',{'wrtAddr'},...
    'OutportTypes',pirelab.createPirArrayType(hAddrT,[blockInfo.RowSize*2,0]));

    hWrtAddrGenN.setTargetCompReplacementCandidate(true);

    for ii=1:numel(hWrtAddrGenN.PirOutputSignals)
        hWrtAddrGenN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hWrtAddrGenNinSigs=hWrtAddrGenN.PirInputSignals;
    hWrtAddrGenNoutSigs=hWrtAddrGenN.PirOutputSignals;

    validIn=hWrtAddrGenNinSigs(1);
    ready=hWrtAddrGenNinSigs(2);
    processingEnb=hWrtAddrGenNinSigs(3);
    wrtAddrStore=hWrtAddrGenNinSigs(4);
    wrtAddrLT=hWrtAddrGenNinSigs(5);

    wrtAddr=hWrtAddrGenNoutSigs(1);

    pirTyp1=pir_boolean_t;
    pirTyp2=hAddrT;

    Constant_out1_s5=l_addSignal(hWrtAddrGenN,'Constant_out1',pirelab.createPirArrayType(pirTyp2,[blockInfo.MatrixSize*2,0]),slRate);
    LogicalOperator_out1_s6=l_addSignal(hWrtAddrGenN,sprintf('Logical\nOperator_out1'),pirTyp1,slRate);
    Switch1_out1_s8=l_addSignal(hWrtAddrGenN,'Switch1_out1',pirelab.createPirArrayType(pirTyp2,[blockInfo.MatrixSize*2,0]),slRate);


    pirelab.getConstComp(hWrtAddrGenN,...
    Constant_out1_s5,...
    zeros(1,blockInfo.MatrixSize*2),...
    'Constant','on',1,'','','');


    pirelab.getLogicComp(hWrtAddrGenN,...
    [validIn,ready],...
    LogicalOperator_out1_s6,...
    'and',sprintf('Logical\nOperator'));



    pirelab.getSwitchComp(hWrtAddrGenN,...
    [wrtAddrStore,Switch1_out1_s8],...
    wrtAddr,...
    LogicalOperator_out1_s6,'Switch',...
    '~=',0,'Floor','Wrap');


    pirelab.getSwitchComp(hWrtAddrGenN,...
    [wrtAddrLT,Constant_out1_s5],...
    Switch1_out1_s8,...
    processingEnb,'Switch1',...
    '~=',0,'Floor','Wrap');


    pirelab.instantiateNetwork(hN,hWrtAddrGenN,WrtAddrGenInSigs,WrtAddrGenOutSigs,...
    [hWrtAddrGenN.Name,'_inst']);

end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end
