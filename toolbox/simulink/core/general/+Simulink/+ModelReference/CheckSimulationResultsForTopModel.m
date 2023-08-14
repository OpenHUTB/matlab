classdef CheckSimulationResultsForTopModel<Simulink.ModelReference.CheckSimulationResults
    methods(Access=public)
        function this=CheckSimulationResultsForTopModel(modelName,varargin)
            this@Simulink.ModelReference.CheckSimulationResults(modelName,varargin{:});
        end
    end


    methods(Access=protected)
        function modificationObjects=createModificationObjects(this)
            modificationObjects=...
            cellfun(@(simMode)Simulink.ModelReference.Conversion.ChangeTopModelSimulationMode(this.Model,simMode),...
            this.SimulationModes,'UniformOutput',false);
        end
    end
end
