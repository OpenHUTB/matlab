function setLocalTimingInfo(this,tcinfo)















    if~iscell(tcinfo.phases)
        tcinfo.phases=num2cell(tcinfo.phases);
    end


    for n=1:length(tcinfo.phases)
        tempTc.enbsIn=tcinfo.enbsIn;
        tempTc.initValue=tcinfo.initValue;
        if~ischar(tcinfo.enbsOut)
            tempTc.enbsOut=hdlsignalname(tcinfo.enbsOut(n));
        else
            tempTc.enbsOut=tcinfo.enbsOut;
        end
        tempTc.oldphases=tcinfo.phases{n};
        tempTc.phases=normPhase(tcinfo.maxCount,tcinfo.initValue,tcinfo.phases{n});
        tempTc.maxCount=tcinfo.maxCount;
        this.LocalTimingControllerInfo=[this.LocalTimingControllerInfo,tempTc];
    end

    function rPhase=normPhase(maxCount,initValue,phase)


        if initValue~=0
            phase=phase+maxCount;
            rPhase=mod(phase-initValue,maxCount);
        else
            rPhase=phase;
        end


