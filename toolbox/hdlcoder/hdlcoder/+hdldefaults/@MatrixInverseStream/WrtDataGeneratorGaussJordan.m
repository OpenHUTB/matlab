

function WrtDataGeneratorGaussJordan(~,hN,WrtDataGenInSigs,WrtDataGenOutSigs,hBoolT,hInputDataT,...
    slRate,blockInfo)




    hWrtDataGenN=pirelab.createNewNetwork(...
    'Name','WrtDataGeneratorGaussJordan',...
    'InportNames',{'validIn','ready','processingEnb','wrtDataStore',...
    'wrtDataLT'},...
    'InportTypes',[hBoolT,hBoolT,hBoolT,WrtDataGenInSigs(4).Type,WrtDataGenInSigs(5).Type],...
    'InportRates',slRate*ones(1,5),...
    'OutportNames',{'wrtData'},...
    'OutportTypes',pirelab.createPirArrayType(hInputDataT,[blockInfo.RowSize*2,0]));

    hWrtDataGenN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hWrtDataGenN.PirOutputSignals)
        hWrtDataGenN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hWrtDataGenNinSigs=hWrtDataGenN.PirInputSignals;
    hWrtDataGenNoutSigs=hWrtDataGenN.PirOutputSignals;

    validIn=hWrtDataGenNinSigs(1);
    ready=hWrtDataGenNinSigs(2);
    processingEnb=hWrtDataGenNinSigs(3);
    wrtDataStore=hWrtDataGenNinSigs(4);
    wrtDataLT=hWrtDataGenNinSigs(5);

    wrtData=hWrtDataGenNoutSigs(1);

    pirTyp1=pir_boolean_t;
    pirTyp2=hInputDataT;

    Constant_out1_s5=l_addSignal(hWrtDataGenN,'Constant_out1',pirelab.createPirArrayType(pirTyp2,[blockInfo.MatrixSize*2,0]),slRate);
    LogicalOperator_out1_s6=l_addSignal(hWrtDataGenN,sprintf('Logical\nOperator_out1'),pirTyp1,slRate);
    Switch1_out1_s8=l_addSignal(hWrtDataGenN,'Switch1_out1',pirelab.createPirArrayType(pirTyp2,[blockInfo.MatrixSize*2,0]),slRate);


    pirelab.getConstComp(hWrtDataGenN,...
    Constant_out1_s5,...
    zeros(1,blockInfo.MatrixSize*2),...
    'Constant','on',1,'','','');


    pirelab.getLogicComp(hWrtDataGenN,...
    [validIn,ready],...
    LogicalOperator_out1_s6,...
    'and',sprintf('Logical\nOperator'));



    pirelab.getSwitchComp(hWrtDataGenN,...
    [wrtDataStore,Switch1_out1_s8],...
    wrtData,...
    LogicalOperator_out1_s6,'Switch',...
    '~=',0,'Floor','Wrap');


    pirelab.getSwitchComp(hWrtDataGenN,...
    [wrtDataLT,Constant_out1_s5],...
    Switch1_out1_s8,...
    processingEnb,'Switch1',...
    '~=',0,'Floor','Wrap');




    pirelab.instantiateNetwork(hN,hWrtDataGenN,WrtDataGenInSigs,WrtDataGenOutSigs,...
    [hWrtDataGenN.Name,'_inst']);

end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end
