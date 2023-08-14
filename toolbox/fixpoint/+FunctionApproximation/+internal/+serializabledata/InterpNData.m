classdef InterpNData<FunctionApproximation.internal.serializabledata.SerializableData






    properties(Transient)
        MemoryUsage FunctionApproximation.internal.MemoryValue
    end

    properties
Data
        StorageTypes(1,:)
        Spacing(1,1)FunctionApproximation.BreakpointSpecification
        ExtrapolationMethod='nearest'
        InterpolationMethod='linear'
        SaturateOnIntegerOverflow='off'
        HDLOptimized=false
        ApproximateType=FunctionApproximation.internal.ApproximateSolutionType.Simulink
    end

    methods
        function this=update(this,tableDataForInterpolation,varargin)
            optargs={numerictype('double'),...
            repmat(numerictype('double'),1,numel(tableDataForInterpolation)),...
            'linear',...
            'nearest',...
            FunctionApproximation.BreakpointSpecification.ExplicitValues};
            optargs(1:numel(varargin))=varargin;
            [outputType,storageTypes,interpMethod,extrapMethod,spacing]=optargs{:};

            this.OutputType=outputType;
            this.StorageTypes=storageTypes;
            this.InterpolationMethod=interpMethod;
            this.ExtrapolationMethod=extrapMethod;
            this.Spacing=spacing;
            this.Data=tableDataForInterpolation;
        end

        function this=set.Data(this,tableData)
            [this,tableData]=adjustData(this,tableData);
            this.Data=tableData;
            this=setSaturateOnIntegerOverflow(this);
        end

        function this=set.StorageTypes(this,storageTypes)
            [this,storageTypes]=adjustStorageTypes(this,storageTypes);
            this.StorageTypes=storageTypes;
        end

        function memoryUsage=get.MemoryUsage(this)
            data=this.Data;
            if isempty(data)

                memoryUsage=FunctionApproximation.internal.MemoryValue.empty;
            else


                wordLenghts=arrayfun(@(x)x.WordLength,this.StorageTypes);
                gridSize=size(data{end});
                gridSize=gridSize(gridSize>1);
                spacing=this.Spacing;
                memoryToStore=FunctionApproximation.internal.getLUTDataMemoryUsage(spacing,gridSize,...
                wordLenghts(1:end-1),wordLenghts(end),this.HDLOptimized,this.InterpolationMethod);
                memoryUsage=FunctionApproximation.internal.MemoryValue(memoryToStore,'Unit','bits');
            end
        end
    end

    methods(Access=protected)
        function[this,tableData]=adjustData(this,tableData)




            nLoop=min(numel(this.StorageTypes),numel(tableData));
            interfaceTypes=getInterfaceTypes(this);
            for ii=1:nLoop


                if this.StorageTypes(ii).isscalingunspecified
                    this.StorageTypes(ii)=FunctionApproximation.internal.scaleDataType(this.StorageTypes(ii),tableData{ii},interfaceTypes(ii));
                end
                tableData{ii}=FunctionApproximation.internal.quantizeValue(tableData{ii},this.StorageTypes(ii));
            end
        end

        function[this,storageTypes]=adjustStorageTypes(this,storageTypes)




            nLoop=min(numel(this.Data),numel(storageTypes));
            interfaceTypes=getInterfaceTypes(this);
            for ii=1:nLoop

                if storageTypes(ii).isscalingunspecified
                    storageTypes(ii)=FunctionApproximation.internal.scaleDataType(storageTypes(ii),this.Data{ii},interfaceTypes(ii));
                end
            end
        end

        function this=setSaturateOnIntegerOverflow(this)
            this.SaturateOnIntegerOverflow='off';
        end
    end
end


