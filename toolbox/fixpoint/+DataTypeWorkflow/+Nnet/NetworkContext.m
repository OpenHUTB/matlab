classdef NetworkContext<handle







    properties
NumLayers
InputWeights
LayerWeights
TrainingInput
TrainingTarget
    end

    methods
        function this=NetworkContext(networkToPrep,trainingInput,trainingTarget)
            this.runPreChecks(networkToPrep,trainingInput,trainingTarget);
            this.NumLayers=networkToPrep.numLayers;
            this.InputWeights=networkToPrep.IW;
            this.LayerWeights=networkToPrep.LW;
            this.TrainingInput=timeseries(trainingInput');
            this.TrainingTarget=timeseries(trainingTarget');
        end

        function weights=getWeightInformation(this,layerNum)

            if(layerNum==1)

                weights.Value=this.InputWeights{1,1};
            else

                weights.Value=this.LayerWeights{layerNum,layerNum-1};
            end
            weights.BlockName=this.getWeightBlockName(layerNum);
            weights.VarName=this.getWeightsVarName(layerNum);
        end

        function weightBlockName=getWeightBlockName(~,layerNum)

            weightBlockName=DataTypeWorkflow.Nnet.NetworkModelConstants.getWeightBlockName(layerNum);
        end

        function weightsVarName=getWeightsVarName(~,layerNum)


            weightsVarName=DataTypeWorkflow.Nnet.NetworkModelConstants.getWeightsVarName(layerNum);
        end

        function layerBlockPath=getLayerBlockPath(~,networkBlockPath,layerNum)


            layerBlockPath=DataTypeWorkflow.Nnet.NetworkModelConstants.getLayerBlockPath(networkBlockPath,layerNum);
        end
    end
    methods(Access={?NnetTestCase})
        function runPreChecks(this,networkToPrep,trainingInput,trainingTarget)
            this.checkForDLT();
            this.validateRequiredInput(networkToPrep,trainingInput,trainingTarget);
        end

        function checkForDLT(~)
            if~hasDeepLearningToolbox()
                error(message('FixedPointTool:fixedPointTool:DLTLicenseNotAvailable'));
            end
        end

        function validateRequiredInput(~,networkToPrep,trainingInput,trainingTarget)
            if~isa(networkToPrep,'network')
                error(message('FixedPointTool:fixedPointTool:InvalidShallowNNET'));
            end

            if~(isnumeric(trainingInput)&&isnumeric(trainingTarget))
                error(message('FixedPointTool:fixedPointTool:NumericTrainingData'));
            end

            if~(size(trainingInput,2)==size(trainingTarget,2))
                error(message('FixedPointTool:fixedPointTool:BatchSizeMismatch'));
            end

            if~(size(trainingInput,1)==networkToPrep.inputs{1}.size)
                error(message('FixedPointTool:fixedPointTool:InputDataAndNetworkMismatch'));
            end

            if~(size(trainingTarget,1)==networkToPrep.outputs{end}.size)
                error(message('FixedPointTool:fixedPointTool:TargetDataAndNetworkMismatch'));
            end
        end
    end
end


