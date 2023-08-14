classdef ConflictResolutionSpecification<handle&matlab.mixin.CustomDisplay








    properties
        PropertyList=DataTypeOptimization.SimulationInput.MergingProperty.empty(0,1);
    end

    methods
        function this=ConflictResolutionSpecification()

            this.initialize();
        end
    end

    methods(Hidden)
        function initialize(this)


            this.PropertyList=[...
            DataTypeOptimization.SimulationInput.MergingProperty('ModelName',DataTypeOptimization.SimulationInput.ConflictMode.Error),...
            DataTypeOptimization.SimulationInput.MergingProperty('LoggingSpecification',DataTypeOptimization.SimulationInput.ConflictMode.Error),...
            DataTypeOptimization.SimulationInput.MergingProperty('InitialState',DataTypeOptimization.SimulationInput.ConflictMode.Error),...
            DataTypeOptimization.SimulationInput.MergingProperty('ExternalInput',DataTypeOptimization.SimulationInput.ConflictMode.Error),...
            DataTypeOptimization.SimulationInput.MergingProperty('ModelParameters',DataTypeOptimization.SimulationInput.ConflictMode.Merge),...
            DataTypeOptimization.SimulationInput.MergingProperty('BlockParameters',DataTypeOptimization.SimulationInput.ConflictMode.Merge),...
            DataTypeOptimization.SimulationInput.MergingProperty('Variables',DataTypeOptimization.SimulationInput.ConflictMode.Merge),...
            DataTypeOptimization.SimulationInput.MergingProperty('PreSimFcn',DataTypeOptimization.SimulationInput.ConflictMode.Error),...
            DataTypeOptimization.SimulationInput.MergingProperty('PostSimFcn',DataTypeOptimization.SimulationInput.ConflictMode.Error),...
            DataTypeOptimization.SimulationInput.MergingProperty('UserString',DataTypeOptimization.SimulationInput.ConflictMode.Merge),...
            ];
        end
    end


end

