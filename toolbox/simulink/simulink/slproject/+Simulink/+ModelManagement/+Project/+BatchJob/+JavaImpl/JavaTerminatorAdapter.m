classdef JavaTerminatorAdapter<Simulink.ModelManagement.Project.BatchJob.BatchJobTerminator




    properties
JavaTerminator
    end

    methods(Access=public)

        function terminator=JavaTerminatorAdapter(javaTerminator)
            terminator.JavaTerminator=javaTerminator;
        end

        function terminate(terminator)
            terminator.JavaTerminator.terminate();
        end

        function terminated=isTerminated(terminator)
            terminated=terminator.JavaTerminator.isTerminated();
        end

    end

end

