classdef LUTModelDataToModel<FunctionApproximation.internal.datatomodeladapter.BlockDataToModel





    methods(Hidden)
        function modelInfo=initializeModelInfo(~)

            modelInfo=FunctionApproximation.internal.datatomodeladapter.LookupNDModelInfo();
        end

        function copyOriginalBlock(~,modelInfo,blockData)

            lutBlockPath=getBlockPath(modelInfo);
            add_block(modelInfo.LookupNDBlockLibraryPath,lutBlockPath);
            set_param(lutBlockPath,'NumberOfTableDimensions',int2str(blockData.NumberOfDimensions));


            set_param(lutBlockPath,'InputSameDT','off');
        end
    end
end

