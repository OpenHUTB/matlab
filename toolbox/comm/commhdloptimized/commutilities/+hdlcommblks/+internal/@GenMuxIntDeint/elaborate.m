function hNewC=elaborate(this,hN,hC)





    slbh=hC.SimulinkHandle;


    intdelay=this.getIntDelay(hC);



    isdeint=strcmpi(hdlgetblocklibpath(slbh),...
    ['commcnvintrlv2/General',newline,'Multiplexed',newline,'Deinterleaver']);
    if isdeint
        blkname='General Multiplexed Deinterleaver - Shift Register Implementation';
        intdeintdelay=max(intdelay)-intdelay;
    else
        blkname='General Multiplexed Interleaver - Shift Register Implementation';
        intdeintdelay=intdelay;
    end


    blkComment=[blkname,newline...
    ,'Interleaver Delay - ',num2str(intdelay)];


    hNewC=this.elaborateIntDeint(hN,hC,intdeintdelay,blkComment);



