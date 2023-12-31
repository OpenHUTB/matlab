function[hC,num]=getTargetSpecificInstantiationCompsWithOneInput(targetCompInventory,hN,hInSignals,hOutSignals,coregenBlkName)




    [dimlen,~]=pirelab.getVectorTypeInfo(hInSignals(1));
    if dimlen>1
        hC=alteratarget.getVectorMegaFunctionComp(targetCompInventory,hN,hInSignals,hOutSignals,coregenBlkName,@getScalarTargetSpecificCoreGenCompWithOneInput);
    else
        hC=getScalarTargetSpecificCoreGenCompWithOneInput(targetCompInventory,hN,hInSignals,hOutSignals,coregenBlkName);
    end
    num=dimlen*hN.getNumOfInstances();

    function hC=getScalarTargetSpecificCoreGenCompWithOneInput(~,hN,hInSignals,hOutSignals,coregenBlkName)

        hC=pirelab.getInstantiationComp(...
        'Network',hN,...
        'Name',coregenBlkName,...
        'EntityName',coregenBlkName,...
        'InportNames',{'a'},...
        'OutportNames',{'result'},...
        'InportSignals',hInSignals,...
        'OutportSignals',hOutSignals,...
        'AddClockPort','on',...
        'ClockInputPort','clk',...
        'AddClockEnablePort','on',...
        'ClockEnableInputPort','ce',...
        'AddResetPort','on',...
        'ResetInputPort','sclr',...
        'InlineConfigurations','off'...
        );
        hC.setTargetIP(true);


