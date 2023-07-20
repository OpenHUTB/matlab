function[intdelay,N,B]=getIntDelay(this,hC)






    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        blockInfo=getSysObjInfo(this,sysObjHandle);
    else
        blockInfo=getBlockInfo(this,hC);
    end


    intdelay=blockInfo.intdelay;
    N=blockInfo.N;
    B=blockInfo.B;


