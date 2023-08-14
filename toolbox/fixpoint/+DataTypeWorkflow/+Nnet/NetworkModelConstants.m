classdef NetworkModelConstants<handle






    properties(Constant)
        FromWorkspaceBlockLibraryPath='simulink/Sources/From Workspace'
        DTCBlockLibraryPath='simulink/Signal Attributes/Data Type Conversion'
        DiffBlockLibraryPath='simulink/Math Operations/Subtract'
        ConstantBlockLibraryPath='simulink/Sources/Constant'
        ProductBlockLibraryPath='simulink/Math Operations/Product'
        TrainingInputVarName='xarr'
        TrainingTargetVarName='yarr'
        DTCFromBlockName='dtc_from'
        DTCToBlockName='dtc_to'
        DiffBlockName='diff'
        InputWeightBlockName='IW{1,1}'
        LayerWeightBlockPrefix='LW'
        LayerBlockPrefix='Layer'
        WeightSuffix='Weights'
        MatrixMultBlockName='MatrixMultiply'
    end

    methods(Static)
        function weightBlockName=getWeightBlockName(layerNum)









            if(layerNum==1)
                weightBlockName=DataTypeWorkflow.Nnet.NetworkModelConstants.InputWeightBlockName;
            else
                weightBlockName=[DataTypeWorkflow.Nnet.NetworkModelConstants.LayerWeightBlockPrefix...
                ,'{',num2str(layerNum),',',num2str(layerNum-1),'}'];
            end
        end

        function weightsVarName=getWeightsVarName(layerNum)


            weightsVarName=[DataTypeWorkflow.Nnet.NetworkModelConstants.LayerBlockPrefix...
            ,'_',num2str(layerNum),'_',DataTypeWorkflow.Nnet.NetworkModelConstants.WeightSuffix];
        end

        function layerBlockPath=getLayerBlockPath(networkBlockPath,layerNum)


            layerBlockPath=[networkBlockPath,'/'...
            ,DataTypeWorkflow.Nnet.NetworkModelConstants.LayerBlockPrefix,' ',num2str(layerNum)];
        end
    end
end

