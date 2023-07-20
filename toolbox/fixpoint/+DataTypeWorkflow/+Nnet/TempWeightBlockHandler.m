classdef TempWeightBlockHandler<handle







    properties
        TempModelName=''
        ReplacementSubsystemPath=[]
    end

    properties(Access=private)
        TempWeightModelPrefix='TempWeightsModel'
        SusbystemNameSuffix='/Subsystem'
    end

    methods
        function this=TempWeightBlockHandler(weights,layerNum)
            this.createTemporaryModel();
            this.createWeightSubsystem(weights,layerNum);
        end

        function delete(this)
            close_system(this.TempModelName,0);
        end
    end

    methods(Access=private)
        function createTemporaryModel(this)
            [~,modelNameSuffix]=fileparts(tempname);
            this.TempModelName=[this.TempWeightModelPrefix,'_',modelNameSuffix];
            open_system(new_system(this.TempModelName));
        end

        function createWeightSubsystem(this,weights,layerNum)
            weightConst=getWeightBlockConstants();


            weightsVarName=weightConst.getWeightsVarName(layerNum);
            tempModelWS=get_param(this.TempModelName,'modelworkspace');
            tempModelWS.assignin(weightsVarName,weights);

            weightBlockName=weightConst.getWeightBlockName(layerNum);


            weightBlockHandle=add_block(weightConst.ConstantBlockLibraryPath,[this.TempModelName,'/',weightBlockName],...
            'Value',weightsVarName,'VectorParams1D','off');


            matrixMultiplyBlockHandle=add_block(weightConst.ProductBlockLibraryPath,...
            [this.TempModelName,'/',weightConst.MatrixMultBlockName],'Multiplication','Matrix(*)');


            weightPortHandles=getPortHandles(weightBlockHandle);
            matrixMultiplyPortHandles=getPortHandles(matrixMultiplyBlockHandle);
            add_line(this.TempModelName,weightPortHandles.Outport(1),matrixMultiplyPortHandles.Inport(1),'autorouting','on');


            blockHandles=[matrixMultiplyBlockHandle,weightBlockHandle];
            Simulink.BlockDiagram.createSubsystem(blockHandles);
            this.ReplacementSubsystemPath=[this.TempModelName,this.SusbystemNameSuffix];
        end
    end
end


function weightConst=getWeightBlockConstants()
    weightConst.getWeightsVarName=@(x)DataTypeWorkflow.Nnet.NetworkModelConstants.getWeightsVarName(x);
    weightConst.getWeightBlockName=@(x)DataTypeWorkflow.Nnet.NetworkModelConstants.getWeightBlockName(x);
    weightConst.ConstantBlockLibraryPath=DataTypeWorkflow.Nnet.NetworkModelConstants.ConstantBlockLibraryPath;
    weightConst.ProductBlockLibraryPath=DataTypeWorkflow.Nnet.NetworkModelConstants.ProductBlockLibraryPath;
    weightConst.MatrixMultBlockName=DataTypeWorkflow.Nnet.NetworkModelConstants.MatrixMultBlockName;
end

function portHandles=getPortHandles(block)
    portHandles=get_param(block,'PortHandles');
end


