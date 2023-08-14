























classdef Cleanup<handle
    properties
Data
Task
    end

    methods
        function obj=Cleanup(optionalTask,optionalData)
            if nargin>=1
                obj.Task=optionalTask;
                if nargin>=2
                    obj.Data=optionalData;
                end
            end
        end

        function delete(obj)
            if~isempty(obj.Task)
                obj.Task();
            end
        end
    end
end
