function setSegmentParam(this,aNewSeg,aOriSeg)%#ok



    aNewSeg.DataLogging=aOriSeg.DataLogging;
    aNewSeg.DataLoggingNameMode=aOriSeg.DataLoggingNameMode;
    aNewSeg.DataLoggingName=aOriSeg.DataLoggingName;
    aNewSeg.DataLoggingDecimateData=aOriSeg.DataLoggingDecimateData;
    aNewSeg.DataLoggingDecimation=aOriSeg.DataLoggingDecimation;
    aNewSeg.DataLoggingSampleTime=aOriSeg.DataLoggingSampleTime;
    aNewSeg.DataLoggingLimitDataPoints=aOriSeg.DataLoggingLimitDataPoints;
    aNewSeg.DataLoggingMaxPoints=aOriSeg.DataLoggingMaxPoints;
    aNewSeg.TestPoint=aOriSeg.TestPoint;
    aNewSeg.StorageClass=aOriSeg.StorageClass;
    if aOriSeg.MustResolveToSignalObject&&isempty(aOriSeg.SignalNameFromLabel)
        aNewSeg.SignalNameFromLabel=aOriSeg.Name;
    else
        aNewSeg.SignalNameFromLabel=aOriSeg.SignalNameFromLabel;
    end
    aNewSeg.MustResolveToSignalObject=aOriSeg.MustResolveToSignalObject;
    aNewSeg.ShowPropagatedSignals=aOriSeg.ShowPropagatedSignals;
    aNewSeg.TaskTransitionSpecified=aOriSeg.TaskTransitionSpecified;
    aNewSeg.TaskTransitionIC=aOriSeg.TaskTransitionIC;
    aNewSeg.ExtrapolationMethod=aOriSeg.ExtrapolationMethod;
    aNewSeg.TaskTransitionType=aOriSeg.TaskTransitionType;
    aNewSeg.UserSpecifiedLogName=aOriSeg.UserSpecifiedLogName;
    aNewSeg.SignalPropagation=aOriSeg.SignalPropagation;
    aNewSeg.Name=aOriSeg.Name;
    aNewSeg.HiliteAncestors=aOriSeg.HiliteAncestors;
end
