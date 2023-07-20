function hNewNet=elabSerialOperation(this,hN,opName,ipf,bmp,hInType,refSLHandle,upRate,hSignalsIn)





    operationName=sprintf('serial_%s_operation',opName);


    ufix1Type=pir_ufixpt_t(1,0);


    hNewNet=pirelab.createNewNetwork('Network',hN,...
    'Name',sprintf('serial_%s_operation',opName),...
    'InportNames',{'dvld','din','dinx','outenb','prein','preenb'},...
    'InportTypes',[ufix1Type,hInType,hInType,ufix1Type,hInType,ufix1Type],...
    'OutportNames',{'dout'},...
    'OutportTypes',hInType);


    dataVldSignal=hNewNet.PirInputSignals(1);
    serialInSignal=hNewNet.PirInputSignals(2);
    extraInSignal=hNewNet.PirInputSignals(3);
    outEnbSignal=hNewNet.PirInputSignals(4);
    preInSignal=hNewNet.PirInputSignals(5);
    preEnbSignal=hNewNet.PirInputSignals(6);
    dataoutSignal=hNewNet.PirOutputSignals(1);


    serialInSignal.SimulinkRate=hSignalsIn(1).SimulinkRate;
    [clk,cascadeEnbSignal]=hNewNet.getClockBundle(serialInSignal,upRate,1,1);


    regInSignal=hNewNet.addSignal(hInType,sprintf('%s',opName));
    regOutSignal=hNewNet.addSignal(hInType,sprintf('%s_reg',opName));


    compSelSignal=hNewNet.addSignal(hInType,'saved_in');
    hInSignals=[extraInSignal,regOutSignal];
    compSelComp=pirelab.getSwitchComp(hNewNet,hInSignals,compSelSignal,dataVldSignal,'comp_switch','==',1);
    compSelComp.addComment(sprintf('%s: Choose between new input value or saved value',operationName));


    inSelSignal=hNewNet.addSignal(hInType,'serial_in');
    hInSignals=[preInSignal,serialInSignal];
    inSelComp=pirelab.getSwitchComp(hNewNet,hInSignals,inSelSignal,preEnbSignal,'input_switch','==',1);
    inSelComp.addComment(sprintf('%s: Choose between serial input or previous stage''s output',operationName));


    opInSignals=[compSelSignal,inSelSignal];
    compName=sprintf('%s_comp',opName);
    opComp=this.getCgirCompForEml(hNewNet,opInSignals,regInSignal,compName,ipf,bmp);
    opComp.paramsFollowInputs(false);
    opComp.addComment(sprintf('%s: Compute ''%s'' operation',operationName,opName));


    compName=sprintf('output_%s_reg',opName);
    outRegComp=pireml.getUnitDelayComp(hNewNet,regInSignal,regOutSignal,compName);
    outRegComp.addComment(sprintf('%s: Stage output register',operationName));
    outRegComp.setClockEnable([cascadeEnbSignal,outEnbSignal]);


    endComp=pirelab.getWireComp(hNewNet,regOutSignal,dataoutSignal);


