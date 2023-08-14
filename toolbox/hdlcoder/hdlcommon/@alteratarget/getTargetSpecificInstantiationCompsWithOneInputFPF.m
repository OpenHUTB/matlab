function[hC,num]=getTargetSpecificInstantiationCompsWithOneInputFPF(hN,hInSignals,hOutSignals,altMegaFunctionName,latency)




    [dimlen,~]=pirelab.getVectorTypeInfo(hInSignals(1));
    if dimlen>1
        hC=alteratarget.getVectorMegaFunctionCompFPF(hN,hInSignals,hOutSignals,altMegaFunctionName,latency,@getScalarTargetSpecificMegafunctionCompWithOneInput);
    else
        hC=getScalarTargetSpecificMegafunctionCompWithOneInput(hN,hInSignals,hOutSignals,altMegaFunctionName,latency);
    end
    num=dimlen*hN.getNumOfInstances();

    function hC=getScalarTargetSpecificMegafunctionCompWithOneInput(hN,hInSignals,hOutSignals,altMegaFunctionName,latency)

        hC=pircore.getMegaFunctionComp(hN,altMegaFunctionName,hInSignals,hOutSignals,...
        altMegaFunctionName,{'a'},{'q'},{'clk'},{'en'},{'areset'},latency);


