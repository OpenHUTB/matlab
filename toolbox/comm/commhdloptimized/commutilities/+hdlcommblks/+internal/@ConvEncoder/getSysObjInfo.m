function blockInfo=getSysObjInfo(~,sysObj)



















    blockInfo.opMode=sysObj.TerminationMethod;
    blockInfo.hasResetPort=sysObj.ResetInputPort;

    if sysObj.ResetInputPort
        blockInfo.DelayedResetAction=sysObj.DelayedResetAction;
    else
        blockInfo.DelayedResetAction=false;
    end

    blockInfo.hasFSt=sysObj.FinalStateOutputPort;




    blockInfo.clength=7;
    blockInfo.gmatrix=[171,133];
    blockInfo.fbmatrix=[];
    [k,n]=size(blockInfo.gmatrix);
    blockInfo.k=k;
    blockInfo.n=n;
    blockInfo.isSupportedTrellis=true;
    blockInfo.Comment='poly2trellis';
