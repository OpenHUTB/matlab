


classdef(Hidden=true)ScheduleEditorTest<sltp.internal.ScheduleEditorInterface

    properties(SetAccess=private)
openState
    end

    methods

        function obj=ScheduleEditorTest(modelHandle)
            obj=obj@sltp.internal.ScheduleEditorInterface(modelHandle);
            obj.openState=false;
        end


        function visible=isVisible(obj)
            visible=obj.openState;
        end


        function delete(~)
        end


        function hide(obj)
            obj.openState=false;
        end

        function show(obj)
            obj.openState=true;
        end
    end
end
