classdef NullTerminator<Simulink.ModelManagement.Project.BatchJob.BatchJobTerminator




    methods(Access=public)

        function terminate(~)
        end

        function terminated=isTerminated(~)
            terminated=false;
        end

    end

end

