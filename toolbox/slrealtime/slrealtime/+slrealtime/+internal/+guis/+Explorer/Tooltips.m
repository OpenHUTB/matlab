classdef Tooltips<handle






    properties(Constant,Access=public)
        disconnectedTooltip='slrealtime:explorer:disconnectSelectedTarget';
        connectedTooltip='slrealtime:explorer:connectedSelectedTarget';
        filterTooltip='slrealtime:explorer:filterSignalsParameters';
        contentsOnlyTooltip='slrealtime:explorer:contentsOfCurrentSystemOnly';
        contentsBelowTooltip='slrealtime:explorer:contentsOfCurrentSystemBelow';
        streamSignalGroupTooltip='slrealtime:explorer:streamSignalListToSDI';
        stopStreamSignalGroupTooltip='slrealtime:explorer:stopStreamToSDI';
        highlightSignalButtonTooltip='slrealtime:explorer:highlightSignalInModel';
        highlightParameterButtonTooltip='slrealtime:explorer:highlightParameterInModel';
        pressToMonitor='slrealtime:explorer:startMonitoringSignals';
        streamFirstToMonitor='slrealtime:explorer:streamSignalsToSDIFirst';
        exportAcquireList='slrealtime:explorer:exportAcquireList';
        importAcquireList='slrealtime:explorer:importAcquireList';
        publishAcquireList='slrealtime:explorer:publishAcquireList';



        addToSignalGroupButtonTooltip='Add selected signals to signal group';
        removeFromSignalGroupButtonTooltip='Remove selected signals from signal group';
        stopTimeFieldTooltip='Stop time parameter for model';
        helpButtonTooltip='Help using SLRT Explorer';
        yMinRangeTooltip='Specify minimum y-limit for current channel';
        yMaxRangeTooltip='Specify maximum y-limit for current channel';
        yOffsetTooltip='Specify y-axis offset for current channel';

    end


    methods
        function this=Tooltips()



        end
    end

end
