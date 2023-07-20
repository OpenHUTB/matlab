function hNewC=elaborate(~,hN,hC)




    outSignals=hC.Owner.SLOutputSignals;
    for i=1:length(outSignals)
        outSignal=outSignals(i);
        [~,~,~]=hN.getClockBundle(outSignal,1,1,0);
    end

    desc=hC.getComment();


    if~isempty(desc)
        pirelab.getAnnotationComp(hN,hC.Name,desc,hC.SimulinkHandle);
    end



    hC.Owner.removeComponent(hC);

    hNewC=hC;
