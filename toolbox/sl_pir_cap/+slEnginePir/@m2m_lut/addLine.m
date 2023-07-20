function addLine(m2mObj,aSys,aSrcBlk,aSrcIdx,aDstBlk,aDstIdx)



    sys=[m2mObj.fPrefix,aSys];
    srcIdx=str2double(aSrcIdx)+1;
    oportIdx=num2str(srcIdx);
    oport=[aSrcBlk,'/',oportIdx];
    iportIdx=num2str(str2double(aDstIdx)+1);
    iport=[aDstBlk,'/',iportIdx];
    add_line([m2mObj.fPrefix,aSys],oport,iport,'AUTOROUTING','ON');

    seg=[];
    if isKey(m2mObj.fRemovedDstSegs,[sys,'/',iport])
        seg=m2mObj.fRemovedDstSegs([sys,'/',iport]);
    elseif isKey(m2mObj.fRemovedSrcSegs,[sys,'/',oport])
        seg=m2mObj.fRemovedSrcSegs([sys,'/',oport]);
    end
    if~isempty(seg)
        lineHandles=get_param([sys,'/',aSrcBlk],'LineHandles');
        newSeg=get_param(lineHandles.Outport(srcIdx),'object');
        setSegParam(newSeg,seg);
    end
end

function setSegParam(aNewSeg,aOrigSeg)
    aNewSeg.DataLogging=aOrigSeg.DataLogging;
    aNewSeg.DataLoggingNameMode=aOrigSeg.DataLoggingNameMode;
    aNewSeg.DataLoggingName=aOrigSeg.DataLoggingName;
    aNewSeg.DataLoggingDecimateData=aOrigSeg.DataLoggingDecimateData;
    aNewSeg.DataLoggingDecimation=aOrigSeg.DataLoggingDecimation;
    aNewSeg.DataLoggingSampleTime=aOrigSeg.DataLoggingSampleTime;
    aNewSeg.DataLoggingLimitDataPoints=aOrigSeg.DataLoggingLimitDataPoints;
    aNewSeg.DataLoggingMaxPoints=aOrigSeg.DataLoggingMaxPoints;
    aNewSeg.TestPoint=aOrigSeg.TestPoint;
    aNewSeg.StorageClass=aOrigSeg.StorageClass;
    if aOrigSeg.MustResolveToSignalObject&&isempty(aOrigSeg.SignalNameFromLabel)
        aNewSeg.SignalNameFromLabel=aOrigSeg.Name;
    else
        aNewSeg.SignalNameFromLabel=aOrigSeg.SignalNameFromLabel;
    end
    aNewSeg.MustResolveToSignalObject=aOrigSeg.MustResolveToSignalObject;
    aNewSeg.ShowPropagatedSignals=aOrigSeg.ShowPropagatedSignals;
    aNewSeg.TaskTransitionSpecified=aOrigSeg.TaskTransitionSpecified;
    aNewSeg.TaskTransitionIC=aOrigSeg.TaskTransitionIC;
    aNewSeg.ExtrapolationMethod=aOrigSeg.ExtrapolationMethod;
    aNewSeg.TaskTransitionType=aOrigSeg.TaskTransitionType;
    aNewSeg.UserSpecifiedLogName=aOrigSeg.UserSpecifiedLogName;
    aNewSeg.SignalPropagation=aOrigSeg.SignalPropagation;
    aNewSeg.Name=aOrigSeg.Name;
    aNewSeg.HiliteAncestors=aOrigSeg.HiliteAncestors;
end
