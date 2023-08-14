function[hC,num]=getTargetSpecificRelopInstantiationComp(targetCompInventory,hN,hInSignals,hOutSignals,coregenBlkName)




    [dimlen,~]=pirelab.getVectorTypeInfo(hInSignals(1));
    if dimlen>1
        hC=xilinxtarget.getVectorCoreGenComp(targetCompInventory,hN,hInSignals,hOutSignals,coregenBlkName,@getScalarTargetSpecificRelopInstantiationComp);
    else
        hC=getScalarTargetSpecificRelopInstantiationComp(targetCompInventory,hN,hInSignals,hOutSignals,coregenBlkName);
    end
    num=dimlen*hN.getNumOfInstances();

    function hC=getScalarTargetSpecificRelopInstantiationComp(~,hN,hInSignals,hOutSignals,coregenBlkName)


        relopInstOutType=pirelab.getPirVectorType(hOutSignals.Type,1,true);
        relopInstOut=hN.addSignal(relopInstOutType,sprintf('%s_out',coregenBlkName));

        hC=pirelab.getInstantiationComp(...
        'Network',hN,...
        'Name',coregenBlkName,...
        'EntityName',coregenBlkName,...
        'InportNames',{'a','b'},...
        'OutportNames',{'result'},...
        'InportSignals',hInSignals,...
        'OutportSignals',relopInstOut,...
        'AddClockPort','on',...
        'ClockInputPort','clk',...
        'AddClockEnablePort','on',...
        'ClockEnableInputPort','ce',...
        'AddResetPort','on',...
        'ResetInputPort','sclr',...
        'InlineConfigurations','off'...
        );
        hC.setTargetIP(true);
        pirelab.getWireComp(hN,relopInstOut.slice('index',0),hOutSignals);

