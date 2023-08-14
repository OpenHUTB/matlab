classdef DirectLUData<FunctionApproximation.internal.serializabledata.SerializableData















    properties(Constant)
        AcceptableInputWLs=1:128;
    end

    properties(Transient)
        MemoryUsage FunctionApproximation.internal.MemoryValue
    end

    properties
        Data double=[1,2,3]
        LowerBounds(:,1)double=1
        UpperBounds(:,1)double=3
        IntermediateTypes(:,1)
    end

    properties(SetAccess=private)
        NeedsLowerBoundCorrection(:,1)logical
        NeedsTypeCorrectionForInput(:,1)logical
        InputWLCorrection(:,1)double
        LowerBoundsSI(:,1)double
        UpperBoundsSI(:,1)double
        MinMaxSI(:,2)double
        NumSI(:,1)double
        NeedsInputTypeConversion(:,1)double
        NeedsOutputTypeConversion(:,1)double
    end

    methods
        function this=DirectLUData()
            this.InputTypes=numerictype(0,16,0);
            this.OutputType=numerictype(0,16,0);
            this.IntermediateTypes=[this.InputTypes,this.OutputType];
        end

        function this=update(this,inputTypes,outputType,tableData,varargin)
            bounds=zeros(numel(inputTypes),2);
            for ii=1:numel(inputTypes)
                r=range(fi([],inputTypes(ii)));
                bounds(ii,1)=r(1);
                bounds(ii,2)=r(2);
            end

            optargs={bounds,[inputTypes,outputType]};
            optargs(1:numel(varargin))=varargin;
            [bounds,intermediateInputTypes]=optargs{:};

            this.OutputType=outputType;
            this.InputTypes=inputTypes;
            this.IntermediateTypes=intermediateInputTypes;
            this.Data=tableData;
            this.LowerBounds=bounds(:,1);
            this.UpperBounds=bounds(:,2);
        end

        function this=set.Data(this,data)
            this.Data=double(fi(data,getTypeForTableData(this)));
        end

        function this=set.LowerBounds(this,lowerBounds)
            for ii=1:min(numel(lowerBounds),this.NumberOfDimensions)
                this.LowerBounds(ii,1)=double(fi(lowerBounds(ii),this.InputTypes(ii)));
            end
        end

        function this=set.UpperBounds(this,upperBounds)
            for ii=1:min(numel(upperBounds),this.NumberOfDimensions)
                this.UpperBounds(ii,1)=double(fi(upperBounds(ii),this.InputTypes(ii)));
            end
        end

        function memoryUsage=get.MemoryUsage(this)
            tableType=getTypeForTableData(this);
            memoryToStore=numel(this.Data)*tableType.WordLength;
            memoryUsage=FunctionApproximation.internal.MemoryValue(memoryToStore,'Unit','bits');
        end

        function value=get.NeedsLowerBoundCorrection(this)
            value=logical(this.LowerBoundsSI-this.MinMaxSI(:,1));
        end

        function value=get.NeedsTypeCorrectionForInput(this)
            value=true(this.NumberOfDimensions,1);
            for ii=this.NumberOfDimensions:-1:1
                inputType=getIntermediateInputType(this,ii);
                inputWL=inputType.WordLength;
                value(ii)=~ismember(inputWL,this.InputWLCorrection);
            end
        end

        function value=get.InputWLCorrection(this)
            value=zeros(this.NumberOfDimensions,1);
            for ii=1:min(numel(this.NumSI),this.NumberOfDimensions)
                greaterWLs=this.AcceptableInputWLs(this.AcceptableInputWLs>=log2(this.NumSI(ii)));
                value(ii)=greaterWLs(1);
            end
            value=repmat(max(value),size(value));
        end

        function value=get.LowerBoundsSI(this)
            value=zeros(this.NumberOfDimensions,1);
            for ii=1:min(numel(this.LowerBounds),this.NumberOfDimensions)
                value(ii)=storedIntegerToDouble(fi(this.LowerBounds(ii),getIntermediateInputType(this,ii)));
            end
        end

        function value=get.UpperBoundsSI(this)
            value=zeros(this.NumberOfDimensions,1);
            for ii=1:min(numel(this.UpperBounds),this.NumberOfDimensions)
                value(ii)=storedIntegerToDouble(fi(this.UpperBounds(ii),getIntermediateInputType(this,ii)));
            end
        end

        function value=get.MinMaxSI(this)
            value=zeros(this.NumberOfDimensions,2);
            for ii=this.NumberOfDimensions:-1:1
                value(ii,:)=storedIntegerToDouble(range(fi([],getIntermediateInputType(this,ii))));
            end
        end

        function value=get.NumSI(this)
            value=this.UpperBoundsSI-this.LowerBoundsSI+1;
        end

        function value=get.NeedsInputTypeConversion(this)
            value=false(1,numel(this.InputTypes));
            for ii=1:numel(value)
                value(ii)=~isequal(this.InputTypes(ii),this.IntermediateTypes(ii));
            end
        end

        function value=get.NeedsOutputTypeConversion(this)
            value=false(1,numel(this.OutputType));
            for ii=1:numel(value)
                value(ii)=~isequal(this.OutputType(ii),this.IntermediateTypes(numel(this.InputTypes)+ii));
            end
        end

        function dataType=getTypeForTableData(this)
            dataType=this.IntermediateTypes(end);
        end

        function dataType=getIntermediateInputType(this,index)
            dataType=this.IntermediateTypes(index);
        end
    end
end