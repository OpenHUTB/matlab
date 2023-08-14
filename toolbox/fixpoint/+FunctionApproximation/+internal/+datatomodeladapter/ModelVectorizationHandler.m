classdef ModelVectorizationHandler<handle





    properties(SetAccess=private)
        isVectorized logical=true
    end

    methods
        function handle(this,modelInfo,value)
            modelVectorizeState=isa(get_param(modelInfo.getInputPath(1),'Object'),'Simulink.Constant');
            if modelVectorizeState==value
                this.isVectorized=value;
                return;
            end

            if value
                nBlocks=modelInfo.NumberOfDimensions;
                for idx=1:nBlocks
                    inputPath=modelInfo.getInputPath(idx);
                    constantValue=get_param(inputPath,'OutValues');
                    position=get_param(inputPath,'Position');
                    delete_block(inputPath);
                    add_block(modelInfo.ConstantBlockLibraryPath,inputPath,...
                    'Position',position);
                    set_param(inputPath,'Value',constantValue);
                    set_param(inputPath,'OutDataTypeStr','Inherit: Inherit via back propagation');
                end
                set_param(modelInfo.ModelName,'StopTime','0');
                this.isVectorized=true;
            else
                nBlocks=modelInfo.NumberOfDimensions;
                for idx=1:nBlocks
                    inputPath=modelInfo.getInputPath(idx);
                    constantValue=get_param(inputPath,'Value');
                    position=get_param(inputPath,'Position');
                    delete_block(inputPath);
                    add_block(modelInfo.RepeatingSequenceStairBlockLibraryPath,inputPath,...
                    'Position',position);
                    set_param(inputPath,'OutValues',constantValue);
                    set_param(inputPath,'OutDataTypeStr','Inherit: Inherit via back propagation');
                end
                set_param(modelInfo.ModelName,'StopTime',['size(',modelInfo.InputValuesVariableName,',1) - 1']);
                this.isVectorized=false;
            end
        end
    end
end
