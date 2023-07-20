function hNewC=elaborate(this,hN,hC)




    slbh=hC.SimulinkHandle;


    downSampleFactor=this.hdlslResolve('N',slbh);
    sampleOffset=this.hdlslResolve('phase',slbh);
    InitC=this.hdlslResolve('ic',slbh);




    hNewC=pirelab.getDownSampleComp(hN,hC.SLInputSignals,hC.SLOutputSignals,...
    downSampleFactor,sampleOffset,InitC,...
    hC.Name,'',-1);

end
