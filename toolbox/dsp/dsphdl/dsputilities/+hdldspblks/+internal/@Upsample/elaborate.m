function hNewC=elaborate(this,hN,hC)




    slbh=hC.SimulinkHandle;





    upSampleFactor=this.hdlslResolve('N',slbh);
    sampleOffset=this.hdlslResolve('phase',slbh);


    InitC=this.hdlslResolve('ic',slbh);


    hInSignal=hC.SLInputSignals;
    hOutSignal=hC.SLOutputSignals;


    hNewC=pirelab.getUpSampleComp(hN,hInSignal,hOutSignal,upSampleFactor,...
    sampleOffset,InitC,hC.Name,'');


    hOutSignal.SimulinkRate=hInSignal.SimulinkRate/upSampleFactor;

end
