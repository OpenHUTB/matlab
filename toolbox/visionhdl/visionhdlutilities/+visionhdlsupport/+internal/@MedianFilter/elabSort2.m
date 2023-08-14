function msNet=elabSort2(~,topNet,dataRate,dinType)




    ctlType=pir_boolean_t();





    msNet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','Sort2',...
    'InportNames',{'in1','in2'},...
    'InportTypes',[dinType,dinType],...
    'InportRates',[dataRate,dataRate],...
    'OutportNames',{'lowValue','highValue'},...
    'OutportTypes',[dinType,dinType]...
    );


    in1=msNet.PirInputSignals(1);
    in2=msNet.PirInputSignals(2);
    lowValue=msNet.PirOutputSignals(1);
    highValue=msNet.PirOutputSignals(2);


    sel=msNet.addSignal(ctlType,'sel');
    pirelab.getRelOpComp(msNet,[in1,in2],sel,'<');
    pirelab.getSwitchComp(msNet,[in1,in2],lowValue,sel,'','==',1);
    pirelab.getSwitchComp(msNet,[in2,in1],highValue,sel,'','==',1);
end
