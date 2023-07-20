function v=validateBlock(this,hC)



    v=hdlvalidatestruct;
    hDriver=hdlcurrentdriver;


    if strcmp(this.getImplParams('BalanceDelays'),'off')&&~strcmp(hDriver.getParameter('TreatBalanceDelaysOffAs'),'off')
        blkH=hC.SimulinkHandle;
        blkname=getfullname(blkH);
        v(end+1)=hdlvalidatestruct(3,message('hdlcoder:validate:DelayBalancingOff',blkname,bdroot(getfullname(blkH))));
    end