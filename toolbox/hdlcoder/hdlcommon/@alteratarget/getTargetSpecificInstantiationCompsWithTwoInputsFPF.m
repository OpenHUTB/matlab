function[hC,num]=getTargetSpecificInstantiationCompsWithTwoInputsFPF(hN,hInSignals,hOutSignals,altMegaFunctionName,latency)




    [dimlen,~]=pirelab.getVectorTypeInfo(hInSignals(1));
    if dimlen>1
        hC=alteratarget.getVectorMegaFunctionCompFPF(hN,hInSignals,hOutSignals,altMegaFunctionName,latency,@getScalarTargetSpecificMegafunctionCompWithTwoInputs);
    else
        hC=getScalarTargetSpecificMegafunctionCompWithTwoInputs(hN,hInSignals,hOutSignals,altMegaFunctionName,latency);
    end

    num=dimlen*hN.getNumOfInstances();

    function hC=getScalarTargetSpecificMegafunctionCompWithTwoInputs(hN,hInSignals,hOutSignals,altMegaFunctionName,latency)

        hC=pircore.getMegaFunctionComp(hN,altMegaFunctionName,hInSignals,hOutSignals,...
        altMegaFunctionName,{'a','b'},{'q'},{'clk'},{'en'},{'areset'},latency);


