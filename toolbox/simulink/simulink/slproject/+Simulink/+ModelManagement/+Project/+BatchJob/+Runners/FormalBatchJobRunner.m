classdef FormalBatchJobRunner<Simulink.ModelManagement.Project.BatchJob.BatchJobRunner





    methods(Access=public)

        function run(~,definition,listener,terminator)

            project=slproject.getCurrentProject;


            listener.initializing();
            definition.Command.initialize(project,definition.Files);


            if(terminator.isTerminated)
                return;
            end


            for n=1:length(definition.Files)
                file=definition.Files{n};


                listener.running(file);

                try

                    fileResult=definition.Command.run(file);


                    listener.completed(file,true,fileResult,fileResult);

                catch exception

                    disp(exception.getReport);
                    listener.completed(file,false,exception.message,exception.getReport);
                end


                if(terminator.isTerminated)
                    return;
                end
            end


            listener.finalizing();
            definition.Command.finalize();
        end

    end

end

