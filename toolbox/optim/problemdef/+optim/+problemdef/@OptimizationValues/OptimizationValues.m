classdef(Sealed,InferiorClasses={...
    ?matlab.graphics.axis.Axes,?matlab.graphics.axis.UIAxes,})...
    OptimizationValues<matlab.mixin.CustomDisplay&...
    matlab.mixin.indexing.RedefinesDot&...
    matlab.mixin.indexing.RedefinesParen










    properties(Access=private)


VariableSize


ObjectiveSize


ConstraintSize


Values


NumValues


        NonlinearInequalityConstraints=strings(0,1)

    end


    methods(Hidden)
        function permute(~,~)
            error(message('optim_problemdef:OptimizationValues:MethodNotSupported','permute'));
        end

        function flip(~,~)
            error(message('optim_problemdef:OptimizationValues:MethodNotSupported','flip'));
        end

        function fliplr(~)
            error(message('optim_problemdef:OptimizationValues:MethodNotSupported','fliplr'));
        end

        function flipud(~)
            error(message('optim_problemdef:OptimizationValues:MethodNotSupported','flipud'));
        end

        function transpose(~)
            error(message('optim_problemdef:OptimizationValues:MethodNotSupported','transpose'));
        end

        function ctranspose(~)
            error(message('optim_problemdef:OptimizationValues:MethodNotSupported','ctranspose'));
        end

        function reshape(varargin)
            error(message('optim_problemdef:OptimizationValues:MethodNotSupported','reshape'));
        end

        function out=vertcat(varargin)



            out=vertcat@matlab.mixin.indexing.RedefinesParen(varargin{:});
        end

        function ind=end(varargin)



            ind=end@matlab.mixin.indexing.RedefinesParen(varargin{:});
        end

    end


    methods(Hidden)

        function obj=OptimizationValues(p,valueStruct)










            [VariableNames,ObjectiveNames,ConstraintNames]=getQuantityNames(p);


            obj.VariableSize=createSizeStruct(p,"Variables",VariableNames);


            obj.ObjectiveSize=createSizeStruct(p,"Objective",ObjectiveNames);


            if isstruct(p.Constraints)&&isempty(p.Constraints)
                obj.ConstraintSize.Constraints=[0,0];
            else
                obj.ConstraintSize=createSizeStruct(p,"Constraints",ConstraintNames);
            end



            obj.NumValues=max(optim.problemdef.OptimizationValues.numQuantityValues(valueStruct,p));


            QuantityNames=fieldnames(valueStruct);


            [variableNames,objectiveNames]=getQuantityNames(p);
            for i=1:numel(QuantityNames)
                thisQuantity=QuantityNames{i};
                thisValue=valueStruct.(thisQuantity);
                if isempty(thisValue)
                    problemProperty=optim.problemdef.OptimizationProblem.getPropertyFromQuantityName(...
                    thisQuantity,variableNames,objectiveNames);
                    thisValue=setUnspecifiedValues(obj,p,problemProperty,thisQuantity);
                end
                obj.Values.(thisQuantity)=thisValue;
            end


            obj.NonlinearInequalityConstraints=getNonlinearInequalityConstraintNames(p);

        end

        function props=properties(obj)

            props=[fieldnames(obj.VariableSize);...
            fieldnames(obj.ObjectiveSize);...
            fieldnames(obj.ConstraintSize)];

        end

    end


    methods(Hidden,Access=protected)


        out=dotReference(obj,indexOp)


        updatedObj=dotAssign(obj,indexOp,varargin)



        n=dotListLength(obj,indexOp,indexContext)


        updatedObj=parenAssign(obj,indexOp,varargin)


        updatedObj=parenDelete(obj,indexOp)



        n=parenListLength(obj,indexOp,indexContext)



        out=parenReference(obj,indexOp)

    end


    methods

        h=paretoplot(obj,varargin)
    end



    methods


        out=cat(dim,varargin)


        varargout=size(obj,varargin)

    end


    methods(Hidden,Access=protected)


        header=getHeader(obj);


        header=getFooter(obj);


        groups=getPropertyGroups(obj);


        displayNonScalarObject(obj);


        displayEmptyObject(obj);

    end


    methods(Hidden)



        function val=getSize(obj)
            val=[1,obj.NumValues];
        end


        objVals=objectiveValues4Solver(obj);



        conVals=inequalityConstraintValues4Solver(obj);



        checkSamePropertiesAsProblem(obj,p)


        [xData,yData,zData,xLabel,yLabel,zLabel]=paretoplotdata(obj,objIndex)


        objNames=objectiveNames(obj)


        numObj=numObjectives(obj)

    end


    methods(Hidden,Static)


        obj=createFromSolverBased(p,x,fval,cval)



        numValues=numQuantityValues(valueStruct,p)

    end


    methods(Access=private)



        checkSameProperties(obj,varargin);



        obj=setUnspecifiedValues(obj,p,problemProperty,thisQuantityName)

    end
end



function sizeStruct=createSizeStruct(p,Quantity,Names)

    numNames=numel(Names);
    if isstruct(p.(Quantity))&&numNames>0
        for i=1:numNames
            sizeStruct.(Names{i})=size(p.(Quantity).(Names{i}));
        end
    else
        sizeStruct.(Quantity)=size(p.(Quantity));
    end

end

