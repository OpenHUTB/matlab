classdef(HandleCompatible=true)ProblemDefinition<matlab.mixin.CustomDisplay







    properties(SetAccess={?FunctionApproximation.internal.ProblemDefinition,?FunctionApproximation.internal.ProblemDefinitionFactory})
FunctionToApproximate
        NumberOfInputs(1,1){mustBeNumeric,mustBeInteger}
    end

    properties
        InputTypes(1,:)
        InputLowerBounds(1,:)
        InputUpperBounds(1,:)
        OutputType(1,:)
        Options(1,1)FunctionApproximation.Options
    end

    properties(Access=private)
        InterfaceTypes=[]
    end

    properties(Hidden,SetAccess={...
        ?FunctionApproximation.internal.ProblemDefinition,...
        ?FunctionApproximation.internal.ProblemDefinitionFactory,...
        ?FunctionApproximation.internal.problemmodifier.ProblemDefinitionModifier})
        InputFunctionType(1,:)FunctionApproximation.internal.FunctionType
        InputFunctionWrapper FunctionApproximation.internal.functionwrapper.AbstractWrapper=FunctionApproximation.internal.functionwrapper.FunctionHandleWrapper(@sin)
        ApproximateFunctionType(1,:)FunctionApproximation.internal.FunctionType=FunctionApproximation.internal.FunctionType.LUTBlock
        FunctionToReplace(1,:)char=''
    end

    methods
        function this=set.InputTypes(this,inputTypes)
            mustBeNonempty(inputTypes);
            mustBeValidType(inputTypes,'SimulinkFixedPoint:functionApproximation:inputTypeClassCheck');
            this.InputTypes=this.getNumericTypes(inputTypes);
            locWLGreaterThan128=find(arrayfun(@(x)x.WordLength>128,this.InputTypes));
            if any(locWLGreaterThan128)
                FunctionApproximation.internal.DisplayUtils.throwError(MException(message('SimulinkFixedPoint:functionApproximation:inputTypesWLGreaterThan128')));
            end
        end

        function this=set.OutputType(this,outputType)
            mustBeNonempty(outputType);
            mustBeValidType(outputType,'SimulinkFixedPoint:functionApproximation:outputTypeClassCheck');
            finalType=this.getNumericTypes(outputType);
            validateattributes(finalType,{'embedded.numerictype'},{'scalar'})
            this.OutputType=finalType;
            if this.OutputType.WordLength>128
                FunctionApproximation.internal.DisplayUtils.throwError(MException(message('SimulinkFixedPoint:functionApproximation:outputTypeWLGreaterThan128')));
            end
        end

        function this=set.InputLowerBounds(this,value)
            if isempty(value)
                value=-Inf(1,getNumInputs(this));
            else
                value=FunctionApproximation.internal.Utils.parseCharValue(value);
                mustBeNumeric(value);
                mustBeNonNan(value);
                value=double(value);
                mustBeReal(value);
            end
            this.InputLowerBounds=value;
        end

        function this=set.InputUpperBounds(this,value)
            if isempty(value)
                value=Inf(1,getNumInputs(this));
            else
                value=FunctionApproximation.internal.Utils.parseCharValue(value);
                mustBeNumeric(value);
                mustBeNonNan(value);
                value=double(value);
                mustBeReal(value);
            end
            this.InputUpperBounds=value;
        end
    end

    methods(Hidden)
        function nInputs=getNumInputs(this)
            nInputs=this.NumberOfInputs;
        end

        function types=getInterfaceTypes(this)
            if isempty(this.InterfaceTypes)
                this.InterfaceTypes=[this.InputTypes,this.OutputType];
            end
            types=this.InterfaceTypes;
        end

        function propList=getPropList(this)
            propNames=properties(this);
            propList=propNames;
            if numel(this)==1
                propList=struct();
                for ii=1:numel(propNames)
                    propList.(propNames{ii})=this.(propNames{ii});
                end
                if~isempty(propList.InputTypes)
                    propList.InputTypes=arrayfun(@(x)string(tostring(x)),propList.InputTypes);
                end
                if~isempty(propList.OutputType)
                    propList.OutputType=string(tostring(propList.OutputType));
                end
            end
        end

        function flag=isequal(this,other)
            flag=isequal(class(this),class(other));
            propertiesToCompare={'FunctionToApproximate',...
            'InputTypes',...
            'InputLowerBounds',...
            'InputUpperBounds',...
            'OutputType',...
            'Options'};

            for ii=1:numel(propertiesToCompare)
                flag=flag&&isequal(this.(propertiesToCompare{ii}),other.(propertiesToCompare{ii}));
                if~flag
                    break;
                end
            end
        end

        function flag=isequaln(this,other)
            flag=FunctionApproximation.internal.isequaln(this,other);
        end
    end

    methods(Hidden,Static)
        function dataTypeCell=convertToCell(dataType)
            if ischar(dataType)||isstring(dataType)
                dataType=convertStringsToChars(dataType);
            end
            if~iscell(dataType)
                if ischar(dataType)
                    dataTypeCell={dataType};
                else
                    dataTypeCell=num2cell(dataType);
                end
            else
                dataTypeCell=dataType;
            end
        end

        function numericType=getNumericTypes(dataType)
            dataTypeCell=FunctionApproximation.internal.ProblemDefinition.convertToCell(dataType);
            numericType=repmat(numerictype('double'),1,numel(dataTypeCell));
            for ii=1:numel(dataTypeCell)
                currentType=dataTypeCell{ii};
                if(isa(currentType,'embedded.numerictype')||isa(currentType,'Simulink.NumericType'))
                    numericType(ii)=numerictype(currentType);
                else
                    parsedContainer=FunctionApproximation.internal.Utils.dataTypeParser(currentType);
                    numericType(ii)=numerictype(parsedContainer.ResolvedType);
                end
            end
        end
    end


    methods(Access=protected)
        function header=getHeader(this)
            dimStr=matlab.mixin.CustomDisplay.convertDimensionsToString(this);
            header=FunctionApproximation.internal.DisplayUtils.getClassHeaderString(...
            this,...
            message('SimulinkFixedPoint:functionApproximation:withProperties').getString(),...
            dimStr);
        end

        function propgrp=getPropertyGroups(this)

            propgrp(1)=matlab.mixin.util.PropertyGroup(getPropList(this));
        end
    end
end


function mustBeValidType(dataType,id)
    dataType=FunctionApproximation.internal.ProblemDefinition.convertToCell(dataType);

    validationError=false;
    for ii=1:numel(dataType)
        currentType=dataType{ii};
        if~isa(currentType,'embedded.numerictype')&&~isa(currentType,'Simulink.NumericType')...
            &&~((ischar(currentType)||isstring(currentType))&&FunctionApproximation.internal.Utils.isDataTypeStringValid(currentType))
            validationError=true;
            break;
        end
    end

    if validationError
        FunctionApproximation.internal.DisplayUtils.throwError(MException(message(id)));
    end
end
