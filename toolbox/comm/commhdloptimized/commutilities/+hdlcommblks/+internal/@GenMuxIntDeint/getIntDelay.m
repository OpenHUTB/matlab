function intdelay=getIntDelay(this,hC)%#ok





    slbh=hC.SimulinkHandle;


    intdelay=hdlslResolve('delay',slbh);


