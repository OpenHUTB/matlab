classdef ModelPreparator<handle



























    properties(GetAccess=private,SetAccess=immutable)
SimulinkData
NetworkData
    end

    properties(SetAccess=protected)
ModelForFxpConversion
Report
    end

    methods
        function this=ModelPreparator(networkToPrep,trainingInput,trainingTarget,varargin)
            try
                netDataPrep=DataTypeWorkflow.Nnet.NetworkDataProcessor(...
                networkToPrep,trainingInput,trainingTarget,varargin{:});
                this.SimulinkData=netDataPrep.SimulinkData;
                this.NetworkData=netDataPrep.NetworkData;
            catch err


                throwAsCaller(err);
            end

            try
                transformer=DataTypeWorkflow.Nnet.NetworkModelTransformer(...
                this.SimulinkData,this.NetworkData);
                transformer.prepareModelForConversion();
            catch err




                warning(err.getReport);
            end
            this.ModelForFxpConversion=this.SimulinkData.SystemUnderDesign;
            this.Report=transformer.Report;
        end

    end
end


