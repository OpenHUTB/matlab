classdef MatlabProfileInterface<matlab.internal.profileviewer.model.AbstractProfileInterface




    methods

        function obj=MatlabProfileInterface
            mlock;
        end

        function timer=getProfileTimer(~)
            timer=callstats('timer');
        end

        function profilerInvokedStatus=getProfilerInvokedStatus(~)
            profilerInvokedStatus=callstats('has_run');
        end

        function historyTracking=getHistoryTracking(~)
            historyTracking=callstats('history');
        end

        function historySize=getHistorySize(~)
            historySize=callstats('historysize');
        end

        function functionHistory=getFunctionHistory(~)

            [~,functionHistory]=callstats('stats');
        end

        function profileInfo=getProfileInfo(~)


















            [profileInfo.FunctionTable,...
            ~,...
            profileInfo.ClockPrecision,...
            profileInfo.Name,...
            profileInfo.ClockSpeed,...
            ~,...
            profileInfo.Overhead]=callstats('stats');
        end

        function fileLines=getFileLines(~,fileName)
            fileLines=callstats('file_lines',fileName);
        end

        function fileChanged=hasFileChangedDuringProfiling(~,functionCompleteName)
            fileChanged=callstats('has_changed',functionCompleteName);
        end

        function turnOff(~)
            profile('off');
        end

        function clear(~)
            profile('clear');
        end

        function viewer(~)
            profile('viewer');
        end

        function status=getProfilerStatus(~)
            status=callstats('status');
        end
    end
end
