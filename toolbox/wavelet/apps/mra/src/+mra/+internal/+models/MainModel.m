

classdef MainModel<handle



    properties(Access=private)
DataModel
DecompositionModel
    end

    methods

        function this=MainModel(signalMgr,inputSignal)
            this.DataModel=mra.internal.models.DataModel(inputSignal);
            this.DecompositionModel=mra.internal.models.DecompositionModel(this.DataModel,signalMgr);
        end

        function dataModel=getDecompositionModel(this)
            dataModel=this.DecompositionModel;
        end

        function dataModel=getDataModel(this)
            dataModel=this.DataModel;
        end
    end
end