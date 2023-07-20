classdef InformalBatchJobRunner<Simulink.ModelManagement.Project.BatchJob.BatchJobRunner





    methods(Access=public)

        function run(~,definition,listener,terminator)

            listener.initializing();


            for n=1:length(definition.Files)
                file=definition.Files{n};


                listener.running(file);

                try

                    fileResult=feval(definition.Command,file);


                    listener.completed(file,true,fileResult,fileResult);

                catch exception

                    disp(exception.getReport);
                    listener.completed(file,false,exception.message,exception.getReport);
                end


                if(terminator.isTerminated)
                    break;
                end
            end


            listener.finalizing();
        end

    end

end

