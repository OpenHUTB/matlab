function hNewC=elaborate(this,hN,hC)







    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        blockInfo=getSysObjInfo(this,sysObjHandle);
    else
        blockInfo=getBlockInfo(this,hC);
    end


    intdelay=blockInfo.intdelay;
    N=blockInfo.N;
    B=blockInfo.B;




    isint=blockInfo.isint;
    if isint

        blkname='Convolutional Interleaver - Shift Register Implementation';
    else
        blkname='Convolutional Deinterleaver - Shift Register Implementation';
        intdelay=(B*(N-1))-intdelay;
    end


    blkComment=[blkname,newline...
    ,'N (rows) = ',num2str(N),', B (register length step) = ',num2str(B)];



    hNewC=this.elaborateIntDeint(hN,hC,intdelay,blkComment);



