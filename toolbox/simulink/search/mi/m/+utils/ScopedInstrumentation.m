
classdef ScopedInstrumentation<handle








    properties(Access=private)
tagName
    end

    methods

        function obj=ScopedInstrumentation(name)
            obj.tagName=name;
            simulink.FindSystemTask.Testing.startPerfRecordingFor(obj.tagName);
        end


        function delete(obj)
            simulink.FindSystemTask.Testing.stopPerfRecordingFor(obj.tagName);
        end
    end

end

