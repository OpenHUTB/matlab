classdef SurrogateEvaluator<handle&matlab.mixin.SetGet&matlab.mixin.internal.FunctionObject&matlab.mixin.Copyable



    properties(GetAccess=public,SetAccess=public)

        Names;


    end
    properties(GetAccess=public,SetAccess=?APIs.SurrogateFitter)








        Range;
    end
    properties(GetAccess=public,SetAccess=protected)



GradientSupport



HessianSupport
    end

    methods(Abstract)







































        varargout=evaluateImpl(obj,x,responseIndicesOrNames,varargin);
    end
    methods(Access=protected)























        function grad=gradientImpl(obj,x,responseIndicesOrNames,varargin)%#ok<INUSD,STOUT>
            assert(isscalar(obj.GradientSupport)&&islogical(obj.GradientSupport)&&~obj.GradientSupport,...
            "Property 'GradientSupport' must be initialized to false if no gradient implementation is provided.");
            error(message("shared_surrogatelib:SurrogateEvaluator:UnsupportedGradientMethod"));
        end
























        function hess=hessianImpl(obj,x,responseIndicesOrNames,varargin)%#ok<INUSD,STOUT>
            assert(isscalar(obj.HessianSupport)&&islogical(obj.HessianSupport)&&~obj.HessianSupport,...
            "Property 'HessianSupport' must be initialized to false if no Hessian implementation is provided.");
            error(message("shared_surrogatelib:SurrogateEvaluator:UnsupportedHessianMethod"));
        end

    end


    methods


        function varargout=parenReference(obj,x,varargin)






















































            p=inputParser;
            addRequired(p,"Surrogate",@(x)validateattributes(x,{'APIs.SurrogateEvaluator'},{'scalar'}));
            parse(p,obj);







            varargout=cell(1,nargout);
            if isempty(varargin)
                responseIndicesOrNames=1:numel(obj.Names);
            else
                responseIndicesOrNames=varargin{1};
            end

            if isnumeric(responseIndicesOrNames)
                if any(~isfinite(responseIndicesOrNames))||...
                    any(responseIndicesOrNames<0)||...
                    any(responseIndicesOrNames>numel(obj.Names))
                    error(message("shared_surrogatelib:SurrogateEvaluator:InvalidResponseIndex",numel(obj.Names)));
                end
            else
                responseIndicesOrNames=convertStringsToChars(responseIndicesOrNames);
                if ischar(responseIndicesOrNames)
                    responseIndicesOrNames={responseIndicesOrNames};
                end
                if~iscellstr(responseIndicesOrNames)%#ok<ISCLSTR>
                    error(message("shared_surrogatelib:SurrogateEvaluator:InvalidResponseIndex",numel(obj.Names)));
                end
                [tfValidName,responseIndicesOrNames]=...
                ismember(responseIndicesOrNames,obj.Names);
                if~all(tfValidName)
                    error(message("shared_surrogatelib:SurrogateEvaluator:UnknownResponseName.",strjoin(responseIndicesOrNames(~tfValidName),', ')));
                end
            end


            try
                [varargout{:}]=evaluateImpl(obj,x,responseIndicesOrNames,varargin{2:end});
            catch causeException
                baseException=MException(message("shared_surrogatelib:SurrogateEvaluator:FailedEvaluation"));
                baseException=addCause(baseException,causeException);
                throw(baseException);
            end


            if numel(varargout)>=1&&~isempty(varargout{1})
                validateResponseValues(obj,x,varargout{1},responseIndicesOrNames);
            end
            if numel(varargout)>=2&&~isempty(varargout{2})
                validateGradients(obj,x,varargout{2},responseIndicesOrNames);
            end
            if numel(varargout)>=3&&~isempty(varargout{3})
                validateHessians(obj,x,varargout{3},responseIndicesOrNames);
            end

        end

        function grad=gradient(obj,x,varargin)




































            p=inputParser;
            addRequired(p,"Surrogate",@(x)validateattributes(x,{'APIs.SurrogateEvaluator'},{'scalar'}));
            parse(p,obj);

            if isempty(varargin)
                responseIndicesOrNames=1:numel(obj.Names);
            else
                responseIndicesOrNames=varargin{1};
            end

            if isnumeric(responseIndicesOrNames)
                if any(~isfinite(responseIndicesOrNames))||...
                    any(responseIndicesOrNames<0)||...
                    any(responseIndicesOrNames>numel(obj.Names))
                    error(message("shared_surrogatelib:SurrogateEvaluator:InvalidResponseIndex",numel(obj.Names)));
                end
            else
                responseIndicesOrNames=convertStringsToChars(responseIndicesOrNames);
                if ischar(responseIndicesOrNames)
                    responseIndicesOrNames={responseIndicesOrNames};
                end
                if~iscellstr(responseIndicesOrNames)%#ok<ISCLSTR>
                    error(message("shared_surrogatelib:SurrogateEvaluator:InvalidResponseIndex",numel(obj.Names)));
                end
                [tfValidName,responseIndicesOrNames]=...
                ismember(responseIndicesOrNames,obj.Names);
                if~all(tfValidName)
                    error(message("shared_surrogatelib:SurrogateEvaluator:UnknownResponseName.",strjoin(responseIndicesOrNames(~tfValidName),', ')));
                end
            end


            try
                grad=gradientImpl(obj,x,varargin{2:end});
            catch causeException
                baseException=MException(message("shared_surrogatelib:SurrogateEvaluator:FailedGradientEvaluation"));
                baseException=addCause(baseException,causeException);
                throw(baseException);
            end
            validateGradients(obj,x,grad,responseIndicesOrNames);

        end

        function hess=hessian(obj,x,varargin)



































            p=inputParser;
            addRequired(p,"Surrogate",@(x)validateattributes(x,{'APIs.SurrogateEvaluator'},{'scalar'}));
            parse(p,obj);

            if isempty(varargin)
                responseIndicesOrNames=1:numel(obj.Names);
            else
                responseIndicesOrNames=varargin{1};
            end

            if isnumeric(responseIndicesOrNames)
                if any(~isfinite(responseIndicesOrNames))||...
                    any(responseIndicesOrNames<0)||...
                    any(responseIndicesOrNames>numel(obj.Names))
                    error(message("shared_surrogatelib:SurrogateEvaluator:InvalidResponseIndex",numel(obj.Names)));
                end
            else
                responseIndicesOrNames=convertStringsToChars(responseIndicesOrNames);
                if ischar(responseIndicesOrNames)
                    responseIndicesOrNames={responseIndicesOrNames};
                end
                if~iscellstr(responseIndicesOrNames)%#ok<ISCLSTR>
                    error(message("shared_surrogatelib:SurrogateEvaluator:InvalidResponseIndex",numel(obj.Names)));
                end
                [tfValidName,responseIndicesOrNames]=...
                ismember(responseIndicesOrNames,obj.Names);
                if~all(tfValidName)
                    error(message("shared_surrogatelib:SurrogateEvaluator:UnknownResponseName.",strjoin(responseIndicesOrNames(~tfValidName),', ')));
                end
            end



            try
                hess=hessianImpl(obj,x,responseIndicesOrNames,varargin{2:end});
            catch causeException
                baseException=MException(message("shared_surrogatelib:SurrogateEvaluator:FailedHessianEvaluation"));
                baseException=addCause(baseException,causeException);
                throw(baseException);
            end
            validateHessians(obj,x,hess,responseIndicesOrNames);

        end

    end


    methods(Access=private)

        function validateResponseValues(~,x,values,responseIndicesOrNames)

            dimY=size(values);
            if dimY(1)~=size(x,1)
                error(message("shared_surrogatelib:SurrogateEvaluator:InvalidNumberOfEvaluations",size(x,1),dimY(1)));




            end



        end
        function validateGradients(~,x,grad,responseIndicesOrNames)

            dimGrad=size(grad);
            if dimGrad(1)~=size(x,1)
                error(message("shared_surrogatelib:SurrogateEvaluator:InvalidNumberOfGradients",size(x,1),dimGrad(1)));







            end



        end
        function validateHessians(~,x,hessians,responseIndicesOrNames)

            dimHess=size(hessians);
            if dimHess(1)~=size(x,1)
                error(message("shared_surrogatelib:SurrogateEvaluator:InvalidNumberOfHessians",size(x,1),dimHess(1)));







            end
            if any(isnan(hessians),"all")
                error(message("shared_surrogatelib:SurrogateEvaluator:HessianEvaluationResultedinNaN"));
            end
        end
    end
end
