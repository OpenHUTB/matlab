classdef CheckSimulationResultsForModelBlocks<Simulink.ModelReference.CheckSimulationResults
    properties(SetAccess=private,GetAccess=public)
ModelBlocks
    end


    methods(Access=public)
        function this=CheckSimulationResultsForModelBlocks(modelName,varargin)
            this@Simulink.ModelReference.CheckSimulationResults(modelName,varargin{:});
            this.ModelBlocks=Simulink.ModelReference.Conversion.Utilities.getHandles(find_mdlref_blocks(this.Model));
        end
    end


    methods(Access=protected)
        function modificationObjects=createModificationObjects(this)
            modificationObjects=...
            cellfun(@(simMode)Simulink.ModelReference.Conversion.ChangeModelBlockSimulationMode(this.ModelBlocks,simMode),...
            this.SimulationModes,'UniformOutput',false);
        end
    end
end
