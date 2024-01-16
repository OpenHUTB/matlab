classdef ExpensiveHandle<handle&matlab.mixin.internal.FunctionObject


    properties(GetAccess=public,SetAccess=public)

        Names;
        NumberIndependentVariables;
    end


    methods(Abstract)
        varargout=evaluateImpl(obj,x,varargin);
    end


    methods
        function varargout=parenReference(obj,x,varargin)
            if isempty(obj.NumberIndependentVariables)
                error(message("shared_surrogatelib:ExpensiveHandle:MissingNumberOfIndependentVariables"));
            end
            if isempty(obj.Names)
                error(message("shared_surrogatelib:ExpensiveHandle:MissingResponseNames"));
            end
            numOutputs=max(nargout,1);
            varargout=cell(1,numOutputs);
            [varargout{:}]=obj.evaluateImpl(x,varargin{:});
            dimY=size(varargout{1});
            if dimY(1)~=size(x,1)
                error(message("shared_surrogatelib:ExpensiveHandle:InvalidNumberOfEvaluations",size(x,1),size(varargout{1},1)));
            elseif(numel(dimY)<2&&numel(obj.Names)>1)||...
                (numel(dimY)>=2&&dimY(2)~=numel(obj.Names))
                error(message("shared_surrogatelib:ExpensiveHandle:InvalidNumberOfResponses",numel(obj.Names),size(varargout{1},2)));
            end
            if numOutputs>1
                dimGrad=size(varargout{2});
                if dimGrad(1)~=size(x,1)
                    error(message("shared_surrogatelib:ExpensiveHandle:InvalidNumberOfGradients",size(x,1),size(varargout{2},1)));
                elseif(numel(dimGrad)<2&&size(x,2)>1)||...
                    (numel(dimGrad)>=2&&dimGrad(2)~=size(x,2))
                    error(message("shared_surrogatelib:ExpensiveHandle:InvalidNumberOfDerivativesInGradient",size(x,2),size(varargout{2},2)));
                elseif(numel(dimGrad)<3&&numel(obj.Names)>1)||...
                    (numel(dimGrad)>=3&&dimGrad(3)~=numel(obj.Names))
                    error(message("shared_surrogatelib:ExpensiveHandle:InvalidNumberOfResponsesInGradient",numel(obj.Names),size(varargout{2},3)));
                end
            end
            if numOutputs>2
                dimHess=size(varargout{3});
                if dimHess(1)~=size(x,1)
                    error(message("shared_surrogatelib:ExpensiveHandle:InvalidNumberOfHessians",size(x,1),size(varargout{3},1)));
                elseif(numel(dimHess)<3&&size(x,2)>1)||...
                    (numel(dimHess)>=3&&(dimHess(2)~=size(x,2)||dimHess(3)~=size(x,2)))
                    error(message("shared_surrogatelib:ExpensiveHandle:InvalidNumberOfDerivativesInHessian"));
                elseif(numel(dimHess)<4&&numel(obj.Names)>1)||...
                    (numel(dimHess)>=4&&dimHess(4)~=numel(obj.Names))
                    error(message("shared_surrogatelib:ExpensiveHandle:InvalidNumberOfResponsesInHessian",numel(obj.Names),size(varargout{3},4)));
                end
            end
        end
    end
end
