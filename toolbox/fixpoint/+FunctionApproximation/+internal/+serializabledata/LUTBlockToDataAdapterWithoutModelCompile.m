classdef LUTBlockToDataAdapterWithoutModelCompile<FunctionApproximation.internal.serializabledata.LUTBlockToDataAdapterInterface







    methods
        function this=update(this,blockPath)
            this=update@FunctionApproximation.internal.serializabledata.LUTBlockToDataAdapterInterface(this,blockPath);
        end
    end

    methods(Access=protected)
        function blockData=getBlockData(this)
            blockData=FunctionApproximation.internal.serializabledata.BlockDataWithoutCompile().update(this.Path);
        end

        function inputTypes=getInputTypes(this)
            inputTypes=this.StorageTypes(1:end-1);
        end

        function outputType=getOutputType(this)
            outputType=this.StorageTypes(end);
        end

        function storageTypes=getStorageTypes(this)
            blockObject=getBlockObject(this);
            tableData=getTableData(this);
            nInputs=this.NumberOfDimensions;
            storageTypes=repmat(numerictype('double'),1,nInputs+1);
            entityAutoscalerInterface=SimulinkFixedPoint.EntityAutoscalersInterface.getInterface();
            entityAutoscaler=entityAutoscalerInterface.getAutoscaler(blockObject);

            dts=fixed.DataTypeSelector();
            for ii=1:nInputs
                monotonicityConstraint=SimulinkFixedPoint.AutoscalerConstraints.MonotonicityConstraint(entityAutoscaler.getDataTypeCreator(blockObject,ii));
                storageTypes(ii)=dts.propose([min(tableData{ii}),max(tableData{ii})],numerictype(1,16,4));
                storageTypes(ii)=monotonicityConstraint.snapDataType(storageTypes(ii));
            end

            minValue=min(tableData{end}(:));
            maxValue=max(tableData{end}(:));
            storageTypes(nInputs+1)=dts.propose([minValue,maxValue],numerictype(1,16,4));
        end
    end
end


