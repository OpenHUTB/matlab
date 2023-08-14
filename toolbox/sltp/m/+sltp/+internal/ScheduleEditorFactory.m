classdef ScheduleEditorFactory

    methods(Static)
        function editor=createScheduleEditor(modelHandle)
            hookValue=slsvTestingHook('ScheduleEditorTesting');
            switch(hookValue)
            case isProduction()
                editor=sltp.internal.ScheduleEditor(modelHandle);
            case isTesting()
                editor=sltp.internal.ScheduleEditorTest(modelHandle);
            otherwise
                error('Invalid testing hook specified');
            end
        end
    end
end

function out=isProduction()
    out=0;
end

function out=isTesting()
    out=1;
end
