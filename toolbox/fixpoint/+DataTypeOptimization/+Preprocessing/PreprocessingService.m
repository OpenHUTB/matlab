classdef PreprocessingService<handle







    properties
preprocessingActions
    end

    methods
        function this=PreprocessingService(opt)
            this.registerActions(opt);

        end

        function diagnostic=execute(this,environmentContext)

            diagnostic=MSLDiagnostic.empty;

            for aIndex=1:numel(this.preprocessingActions)
                diagnostic=[diagnostic,this.preprocessingActions{aIndex}.execute(environmentContext)];%#ok<AGROW>
            end
        end

        function registerActions(this,opt)


            if opt.AdvancedOptions.EnforceLooseCoupling



                this.preprocessingActions{1}=DataTypeOptimization.Preprocessing.RemoveSameDT();


                this.preprocessingActions{2}=DataTypeOptimization.Preprocessing.ReplaceInheritance();
            end
        end

        function si=exportSimulationInput(this,environmentContext)
            si=Simulink.SimulationInput();
            siMerger=DataTypeOptimization.SimulationInput.SimulationInputMerger(DataTypeOptimization.SimulationInput.ConflictResolutionSpecification);
            for aIndex=1:numel(this.preprocessingActions)
                currentSimIn=this.preprocessingActions{aIndex}.exportSimulationInput(environmentContext);
                si=siMerger.merge(si,currentSimIn);
            end
        end
    end
end