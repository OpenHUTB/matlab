
function gaussJordanEnable(~,hN,LTEnableInSigs,LTEnableOutSigs,...
    slRate)





    hLTEnableN=pirelab.createNewNetwork(...
    'Name','gaussJordanEnable',...
    'InportNames',{'invFinsh','storeDone'},...
    'InportTypes',[LTEnableInSigs(1).Type,LTEnableInSigs(2).Type],...
    'InportRates',slRate*ones(1,2),...
    'OutportNames',{'processingEnb'},...
    'OutportTypes',LTEnableOutSigs(1).Type);

    hLTEnableN.setTargetCompReplacementCandidate(true);


    for ii=1:numel(hLTEnableN.PirOutputSignals)
        hLTEnableN.PirOutputSignals(ii).SimulinkRate=slRate;
    end

    hLTEnableNinSigs=hLTEnableN.PirInputSignals;
    hLTEnableNoutSigs=hLTEnableN.PirOutputSignals;

    invFinsh=hLTEnableNinSigs(1);
    storeDone=hLTEnableNinSigs(2);

    processingEnb=hLTEnableNoutSigs(1);

    pirTyp1=pir_boolean_t;


    Constant1_out1_s2=l_addSignal(hLTEnableN,'Constant1_out1',pirTyp1,slRate);
    Constant2_out1_s3=l_addSignal(hLTEnableN,'Constant2_out1',pirTyp1,slRate);
    Switch2_out1_s5=l_addSignal(hLTEnableN,'Switch2_out1',pirTyp1,slRate);
    Switch3_out1_s6=l_addSignal(hLTEnableN,'Switch3_out1',pirTyp1,slRate);


    pirelab.getConstComp(hLTEnableN,...
    Constant1_out1_s2,...
    1,...
    'Constant1','on',0,'','','');


    pirelab.getConstComp(hLTEnableN,...
    Constant2_out1_s3,...
    0,...
    'Constant2','on',1,'','','');




    pirelab.getIntDelayComp(hLTEnableN,...
    Switch2_out1_s5,...
    processingEnb,...
    1,'Delay2',...
    false,...
    0,0,[],0,0);


    pirelab.getSwitchComp(hLTEnableN,...
    [Constant1_out1_s2,Switch3_out1_s6],...
    Switch2_out1_s5,...
    storeDone,'Switch2',...
    '~=',0,'Floor','Wrap');



    pirelab.getSwitchComp(hLTEnableN,...
    [Constant2_out1_s3,processingEnb],...
    Switch3_out1_s6,...
    invFinsh,'Switch3',...
    '~=',0,'Floor','Wrap');





    pirelab.instantiateNetwork(hN,hLTEnableN,LTEnableInSigs,LTEnableOutSigs,...
    [hLTEnableN.Name,'_inst']);
end


function hS=l_addSignal(hN,sigName,pirTyp,simulinkRate)
    hS=hN.addSignal;
    hS.Name=sigName;
    hS.Type=pirTyp;
    hS.SimulinkHandle=-1;
    hS.SimulinkRate=simulinkRate;
end

