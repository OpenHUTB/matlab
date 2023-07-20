

classdef MainModel<handle



    properties(Access=private)
DataModel
DenoisingModel
    end

    methods

        function this=MainModel(signalMgr,inputSignal)
            this.DataModel=waveletsignaldenoiser.internal.models.DataModel(inputSignal);
            this.DenoisingModel=waveletsignaldenoiser.internal.models.DenoisingModel(this.DataModel,signalMgr);
        end

        function dataModel=getDenoisingModel(this)
            dataModel=this.DenoisingModel;
        end

        function dataModel=getDataModel(this)
            dataModel=this.DataModel;
        end
    end
end