classdef(Abstract)LUTBlockToDataAdapterInterface<FunctionApproximation.internal.serializabledata.LUTModelData






    properties(Hidden,SetAccess=protected)
Path
BlockData
        NumDim=0
    end

    methods
        function this=update(this,blockPath)
            this.Path=convertStringsToChars(blockPath);
            this.BlockData=getBlockData(this);
            this.Spacing=getSpacingMode(this);
            this.ExtrapolationMethod=getExtrapolationMethod(this);
            this.InterpolationMethod=getInterpolationMethod(this);
            this.RoundingMode=getRoundingMethod(this);
            this.InternalRulePriority=getInternalRulePriority(this);
            this.StorageTypes=getStorageTypes(this);
            this.InputTypes=getInputTypes(this);
            this.OutputType=getOutputType(this);
            this.Data=getTableData(this);
            this.FractionDataType=getFractionDataType(this);
            this.IntermediateType=getIntermediateType(this);
            this.UseLastTableValue=getUseLastTableValue(this);
        end
    end

    methods(Abstract,Access=protected)
        inputTypes=getInputTypes(this)
        outputType=getOutputType(this)
        storageTypes=getStorageTypes(this)
        blockData=getBlockData(this)
    end

    methods(Access=protected)
        function value=numberOfDimensions(this)
            if(this.NumDim==0)&&~isempty(this.Path)
                this.NumDim=numel(this.InputTypes);
                if this.NumDim<1
                    blockObject=getBlockObject(this);
                    this.NumDim=numel(blockObject.PortHandles.Inport);
                end
            end
            value=this.NumDim;
        end

        function spacingMode=getSpacingMode(this)
            blockObject=getBlockObject(this);
            if strcmp(blockObject.DataSpecification,'Table and breakpoints')
                spacingMode=blockObject.BreakpointsSpecification;
            else
                lookupTableObject=slResolve(blockObject.LookupTableObject,blockObject.Handle,'variable');
                spacingMode=lookupTableObject.BreakpointsSpecification;
            end
            spacingMode=FunctionApproximation.BreakpointSpecification.getEnum(spacingMode);
        end

        function tableData=getTableData(this)
            blockObject=getBlockObject(this);
            spacing=this.Spacing;
            if strcmp(blockObject.DataSpecification,'Table and breakpoints')
                tableData=cell(1,this.NumberOfDimensions+1);
                tableData{end}=double(slResolve(blockObject.Table,blockObject.Handle));
                tableSize=size(tableData{end});
                tableSize=tableSize(tableSize>1);
                if isEvenSpacing(spacing)
                    for ii=1:this.NumberOfDimensions
                        firstPoint=double(slResolve(blockObject.(['BreakpointsForDimension',num2str(ii,'%g'),'FirstPoint']),blockObject.Handle));
                        spacing=double(slResolve(blockObject.(['BreakpointsForDimension',num2str(ii,'%g'),'Spacing']),blockObject.Handle));
                        nPoints=tableSize(ii)-1;
                        tableData{ii}=firstPoint+[0,(1:nPoints)*spacing];
                    end
                else
                    for ii=1:this.NumberOfDimensions
                        tableData{ii}=double(slResolve(blockObject.(['BreakpointsForDimension',num2str(ii,'%g')]),blockObject.Handle));
                    end
                end
            else
                lookupTableObject=slResolve(blockObject.LookupTableObject,blockObject.Handle,'variable');
                tableData=cell(1,this.NumberOfDimensions+1);
                tableData{end}=double(lookupTableObject.Table.Value);
                tableSize=size(tableData{end});
                tableSize=tableSize(tableSize>1);
                if isEvenSpacing(spacing)
                    for ii=1:this.NumberOfDimensions
                        firstPoint=double(lookupTableObject.Breakpoints(ii).FirstPoint);
                        spacing=double(lookupTableObject.Breakpoints(ii).Spacing);
                        nPoints=tableSize(ii)-1;
                        tableData{ii}=firstPoint+[0,(1:nPoints)*spacing];
                    end
                else
                    for ii=1:this.NumberOfDimensions
                        tableData{ii}=double(lookupTableObject.Breakpoints(ii).Value);
                    end
                end
            end




            if~isEvenSpacing(this.Spacing)
                for ii=1:this.NumberOfDimensions
                    if iscolumn(tableData{ii})
                        tableData{ii}=tableData{ii}';
                    end
                end
            end
        end

        function extrapolationMode=getExtrapolationMethod(this)
            extrapolationMode=get_param(this.Path,'ExtrapMethod');
        end

        function interpolationMode=getInterpolationMethod(this)
            interpolationMode=get_param(this.Path,'InterpMethod');
        end

        function internalRulePriority=getInternalRulePriority(this)
            internalRulePriority=get_param(this.Path,'InternalRulePriority');
        end

        function roundingMethod=getRoundingMethod(this)
            roundingMethod=get_param(this.Path,'RndMeth');
        end

        function fractionDataType=getFractionDataType(this)
            fractionDataType=get_param(this.Path,'FractionDataTypeStr');
        end

        function intermediateType=getIntermediateType(this)
            intermediateType=get_param(this.Path,'IntermediateResultsDataTypeStr');
        end

        function blockObject=getBlockObject(this)
            blockObject=get_param(this.Path,'Object');
        end

        function useLastTableValue=getUseLastTableValue(this)
            useLastTableValue=get_param(this.Path,'UseLastTableValue');
        end

        function this=setSaturateOnIntegerOverflow(this)
            this.SaturateOnIntegerOverflow=get_param(this.Path,'SaturateOnIntegerOverflow');
        end
    end
end


