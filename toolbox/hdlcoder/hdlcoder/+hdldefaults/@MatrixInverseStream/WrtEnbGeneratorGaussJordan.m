

function WrtEnbGeneratorGaussJordan(~,hN,WrtEnbGenInSigs,WrtEnbGenOutSigs,hBoolT,slRate,...
    blockInfo)




    hWrtEnbGenN=pirelab.createNewNetwork(...
    'Name','WrtEnbGeneratorGaussJordan',...
    'InportNames',{'validIn','ready','processingEnb','wrtEnbStore','wrtEnbLT'},...
    'InportTypes',[hBoolT,hBoolT,hBoolT,WrtEnbGenInSigs(4).Type,WrtEnbGenInSigs(5).Type],...
    'InportRates',slRate*ones(1,5),...
    'OutportNames',{'wrtEnb'},...
    'OutportTypes',pirelab.createPirArrayType(hBoolT,[blockInfo.RowSize*2,0]));

    hWrtEnbGenN.setTargetCompReplacementCandidate(true);

    for ii=1:numel(hWrtEnbGenN.PirOutputSignals)
        hWrtEnbGenN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hWrtEnbGenNinSigs=hWrtEnbGenN.PirInputSignals;
    hWrtEnbGenNoutSigs=hWrtEnbGenN.PirOutputSignals;

    validIn=hWrtEnbGenNinSigs(1);
    ready=hWrtEnbGenNinSigs(2);
    processingEnb=hWrtEnbGenNinSigs(3);
    wrtEnbStore=hWrtEnbGenNinSigs(4);
    wrtEnbLT=hWrtEnbGenNinSigs(5);

    wrtEnb=hWrtEnbGenNoutSigs(1);

    pirTyp1=pir_boolean_t;



    Constant_out1_s5=l_addSignal(hWrtEnbGenN,'Constant_out1',pirelab.createPirArrayType(pirTyp1,[blockInfo.MatrixSize*2,0]),slRate);
    LogicalOperator_out1_s6=l_addSignal(hWrtEnbGenN,sprintf('Logical\nOperator_out1'),pirTyp1,slRate);
    Switch1_out1_s8=l_addSignal(hWrtEnbGenN,'Switch1_out1',pirelab.createPirArrayType(pirTyp1,[blockInfo.MatrixSize*2,0]),slRate);


    pirelab.getConstComp(hWrtEnbGenN,...
    Constant_out1_s5,...
    zeros(1,blockInfo.MatrixSize*2),...
    'Constant','on',1,'','','');


    pirelab.getLogicComp(hWrtEnbGenN,...
    [validIn,ready],...
    LogicalOperator_out1_s6,...
    'and',sprintf('Logical\nOperator'));



    pirelab.getSwitchComp(hWrtEnbGenN,...
    [wrtEnbStore,Switch1_out1_s8],...
    wrtEnb,...
    LogicalOperator_out1_s6,'Switch',...
    '~=',0,'Floor','Wrap');


    pirelab.getSwitchComp(hWrtEnbGenN,...
    [wrtEnbLT,Constant_out1_s5],...
    Switch1_out1_s8,...
    processingEnb,'Switch1',...
    '~=',0,'Floor','Wrap');



    pirelab.instantiateNetwork(hN,hWrtEnbGenN,WrtEnbGenInSigs,WrtEnbGenOutSigs,...
    [hWrtEnbGenN.Name,'_inst']);

end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end
