classdef LUTBlockToDataAdapterWithModelCompile<FunctionApproximation.internal.serializabledata.LUTBlockToDataAdapterInterface







    properties(Access=protected)
        BlockInterfaceParser=FunctionApproximation.internal.BlockInterfaceParser;
    end

    methods
        function this=update(this,blockPath)
            modelCompileHandler=fixed.internal.modelcompilehandler.ModelCompileHandler(blockPath);
            start(modelCompileHandler);
            this=update@FunctionApproximation.internal.serializabledata.LUTBlockToDataAdapterInterface(this,blockPath);
            stop(modelCompileHandler);
        end
    end

    methods(Access=protected)
        function blockData=getBlockData(this)
            blockData=FunctionApproximation.internal.serializabledata.BlockDataAssumeCompile().update(this.Path);
        end

        function inputTypes=getInputTypes(this)
            inputTypes=this.BlockData.InputTypes;
        end

        function outputType=getOutputType(this)
            outputType=this.BlockData.OutputType;
        end

        function storageTypes=getStorageTypes(this)
            blockObject=getBlockObject(this);
            storageTypes(this.NumberOfDimensions+1)=numerictype(FunctionApproximation.internal.Utils.dataTypeParser(blockObject.TableDataTypeName,blockObject).ResolvedType);
            for ii=1:this.NumberOfDimensions
                storageTypes(ii)=numerictype(FunctionApproximation.internal.Utils.dataTypeParser(blockObject.(['BreakpointsForDimension',num2str(ii,'%g'),'DataTypeName']),blockObject).ResolvedType);
            end
        end




    end
end


