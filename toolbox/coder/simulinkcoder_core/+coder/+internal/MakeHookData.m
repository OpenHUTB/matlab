classdef MakeHookData<handle



    properties
        CleanupFunctions={};
    end

    methods

        function addCleanupFunction(this,cleanupFunction)
            this.CleanupFunctions{end+1}=cleanupFunction;
        end

        function delete(this)
            for i=1:length(this.CleanupFunctions)
                feval(this.CleanupFunctions{i});
            end
        end
    end

end
