classdef LUTModelData<FunctionApproximation.internal.serializabledata.InterpNData





    properties(Access=private)
        DataTypeSelector=fixed.DataTypeSelector;
    end

    properties
        RoundingMode='Simplest';
        InternalRulePriority='Speed';
        FractionDataType='Inherit: Inherit via internal rule';
        IntermediateType='Inherit: Same as output';
        UseLastTableValue='on';
    end

    methods
        function this=update(this,inputTypes,outputType,spacing,tableData,storageTypes,varargin)
            optargs={'linear','nearest'};
            optargs(1:numel(varargin))=varargin;
            [interpMethod,extrapMethod]=optargs{:};

            this.InputTypes=inputTypes;
            this.OutputType=outputType;
            this.StorageTypes=storageTypes;
            this.Spacing=spacing;
            this.InterpolationMethod=interpMethod;
            this.ExtrapolationMethod=extrapMethod;
            this.Data=tableData;
            if ishalf(this.OutputType)
                this.IntermediateType='Inherit: Inherit via internal rule';
            end
        end

        function rangeObject=getRangeObject(this)
            minValues=zeros(1,this.NumberOfDimensions);
            maxValues=minValues;
            for ii=1:this.NumberOfDimensions
                minValues(ii)=this.Data{ii}(1);
                maxValues(ii)=this.Data{ii}(end);
            end
            rangeObject=FunctionApproximation.internal.Range(minValues,maxValues);
        end
    end

    methods(Access=protected)
        function this=setSaturateOnIntegerOverflow(this)
            this.SaturateOnIntegerOverflow='off';
            if~isempty(this.Data)&&isEvenSpacing(this.Spacing)


                tableValues=this.Data{end};
                outputType=numerictype(this.OutputType);
                if outputType.isscalingunspecified

                    this.SaturateOnIntegerOverflow='off';
                else


                    r=double(fixed.internal.type.finiteRepresentableRange(outputType));
                    if min(tableValues(:))<=r(1)||max(tableValues(:))>=r(2)
                        this.SaturateOnIntegerOverflow='on';
                    end
                end
            end
        end
    end
end


