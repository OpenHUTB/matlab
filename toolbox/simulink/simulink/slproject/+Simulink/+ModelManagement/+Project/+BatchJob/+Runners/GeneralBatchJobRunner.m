classdef GeneralBatchJobRunner<Simulink.ModelManagement.Project.BatchJob.BatchJobRunner






    methods(Access=public)

        function run(~,definition,listener,terminator)
            import Simulink.ModelManagement.Project.BatchJob.Runners.*;


            type=InterfaceType.determineInterfaceType(definition);


            if(type==InterfaceType.Informal)
                runner=InformalBatchJobRunner;
            elseif(type==InterfaceType.Formal)
                runner=FormalBatchJobRunner;
            else
                DAStudio.error('SimulinkProject:BatchJob:invalidBatchJob');
            end


            runner.run(definition,listener,terminator);
        end

    end

end

