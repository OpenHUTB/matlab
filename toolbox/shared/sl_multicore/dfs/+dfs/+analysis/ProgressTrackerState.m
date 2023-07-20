classdef ProgressTrackerState<handle






    properties
        CheckState=dfs.analysis.ProgressTrackerEnum.None;
        ProfileState=dfs.analysis.ProgressTrackerEnum.None;
        ProfileStartOffset=0;
        ProfilePercentage=0;
        PartitionState=dfs.analysis.ProgressTrackerEnum.None;
        PartitionPercentage=0;
    end

    properties(Constant)
        SuccessImage=fullfile(matlabroot,'toolbox','shared','sl_multicore','dfs','resources','success_32.svg');
        WarnImage=fullfile(matlabroot,'toolbox','shared','sl_multicore','dfs','resources','warning_32.svg');
        ErrorImage=fullfile(matlabroot,'toolbox','shared','sl_multicore','dfs','resources','error_32.svg');
        InfoImage=fullfile(matlabroot,'toolbox','shared','sl_multicore','dfs','resources','c_info_32.svg');
    end

    methods

        function setRuntimeProgress(obj,checkState,profileState,profilePercentage,partitionState,partitionPercentage)
            obj.CheckState=checkState;
            obj.ProfileState=profileState;
            obj.ProfileStartOffset=0;
            obj.ProfilePercentage=profilePercentage;
            obj.PartitionState=partitionState;
            obj.PartitionPercentage=partitionPercentage;
        end

        function setProfilingProgressIndeterminate(obj,profileStartOffset,profileEndOffset)
            obj.CheckState=dfs.analysis.ProgressTrackerEnum.Complete;
            obj.ProfileState=dfs.analysis.ProgressTrackerEnum.None;
            obj.ProfileStartOffset=profileStartOffset;
            obj.ProfilePercentage=profileEndOffset;
            obj.PartitionState=dfs.analysis.ProgressTrackerEnum.None;
            obj.PartitionPercentage=0;
        end

        function setEditTimeProgress(obj,state)
            obj.ProfileStartOffset=0;
            switch state
            case dfs.analysis.MultithreadingState.NoDataForModel
                clearProgress(obj);
            case dfs.analysis.MultithreadingState.NoDataForSubsystem
                clearProgress(obj);
            case dfs.analysis.MultithreadingState.Disabled

            case dfs.analysis.MultithreadingState.NewParent

            case dfs.analysis.MultithreadingState.RTWData
                clearProgress(obj);
            case dfs.analysis.MultithreadingState.ProfiledNoSchedule
                obj.CheckState=dfs.analysis.ProgressTrackerEnum.Complete;
                obj.ProfileState=dfs.analysis.ProgressTrackerEnum.Complete;
                obj.ProfilePercentage=110;
                obj.PartitionState=dfs.analysis.ProgressTrackerEnum.None;
                obj.PartitionPercentage=0;
            case dfs.analysis.MultithreadingState.NeedsAutotuning
                obj.CheckState=dfs.analysis.ProgressTrackerEnum.Complete;
                obj.ProfileState=dfs.analysis.ProgressTrackerEnum.None;
                obj.ProfilePercentage=0;
                obj.PartitionState=dfs.analysis.ProgressTrackerEnum.None;
                obj.PartitionPercentage=0;
            case dfs.analysis.MultithreadingState.SingleThread
                obj.CheckState=dfs.analysis.ProgressTrackerEnum.Warn;
                obj.ProfileState=dfs.analysis.ProgressTrackerEnum.None;
                obj.ProfilePercentage=0;
                obj.PartitionState=dfs.analysis.ProgressTrackerEnum.None;
                obj.PartitionPercentage=0;
            case dfs.analysis.MultithreadingState.LatencyMismatch
                obj.CheckState=dfs.analysis.ProgressTrackerEnum.Complete;
                obj.ProfileState=dfs.analysis.ProgressTrackerEnum.Complete;
                obj.ProfilePercentage=110;
                obj.PartitionState=dfs.analysis.ProgressTrackerEnum.None;
                obj.PartitionPercentage=0;
            case dfs.analysis.MultithreadingState.Partitioned
                obj.CheckState=dfs.analysis.ProgressTrackerEnum.Complete;
                obj.ProfileState=dfs.analysis.ProgressTrackerEnum.Complete;
                obj.ProfilePercentage=110;
                obj.PartitionState=dfs.analysis.ProgressTrackerEnum.Complete;
                obj.PartitionPercentage=110;
            case dfs.analysis.MultithreadingState.MinExec
                obj.CheckState=dfs.analysis.ProgressTrackerEnum.Complete;
                obj.ProfileState=dfs.analysis.ProgressTrackerEnum.Complete;
                obj.ProfilePercentage=110;
                obj.PartitionState=dfs.analysis.ProgressTrackerEnum.Complete;
                obj.PartitionPercentage=110;
            case dfs.analysis.MultithreadingState.NoBlocks
                obj.CheckState=dfs.analysis.ProgressTrackerEnum.Warn;
                obj.ProfileState=dfs.analysis.ProgressTrackerEnum.None;
                obj.ProfilePercentage=0;
                obj.PartitionState=dfs.analysis.ProgressTrackerEnum.None;
                obj.PartitionPercentage=0;
            case dfs.analysis.MultithreadingState.ModelSettingsChanged
                obj.CheckState=dfs.analysis.ProgressTrackerEnum.None;
                obj.ProfileState=dfs.analysis.ProgressTrackerEnum.None;
                obj.ProfilePercentage=0;
                obj.PartitionState=dfs.analysis.ProgressTrackerEnum.None;
                obj.PartitionPercentage=0;
            otherwise
                assert(false,'Unhandled MultithreadingState');
            end
        end

        function clearProgress(obj)
            obj.CheckState=dfs.analysis.ProgressTrackerEnum.None;
            obj.ProfileState=dfs.analysis.ProgressTrackerEnum.None;
            obj.ProfilePercentage=0;
            obj.PartitionState=dfs.analysis.ProgressTrackerEnum.None;
            obj.PartitionPercentage=0;
        end

        function path=getImagePath(obj,state)
            switch state
            case dfs.analysis.ProgressTrackerEnum.None
                path=obj.SuccessImage;
            case dfs.analysis.ProgressTrackerEnum.Complete
                path=obj.SuccessImage;
            case dfs.analysis.ProgressTrackerEnum.Warn
                path=obj.WarnImage;
            case dfs.analysis.ProgressTrackerEnum.Error
                path=obj.ErrorImage;
            case dfs.analysis.ProgressTrackerEnum.Info
                path=obj.InfoImage;
            otherwise
                assert(false,'Unhandled Progress State');
            end
        end

    end
end


