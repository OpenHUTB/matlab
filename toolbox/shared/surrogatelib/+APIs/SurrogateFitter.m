classdef SurrogateFitter<handle&matlab.mixin.SetGet&matlab.mixin.internal.FunctionObject



    properties

        SamplingState=struct("Sobol",[],"Halton",[],"LHS",[],"Random",[]);


    end
    properties(Dependent)




Range

GradientSupport

HessianSupport
    end

    methods(Abstract)

























        designs=fitImpl(obj,expensiveDataStorageOrHandle,varargin);

















        designs=updateImpl(obj,newDataIndexOrRange,...
        expensiveDataStorageOrHandle,varargin);
    end


    methods


        function designs=fit(obj,expensiveDataStorageOrHandle,varargin)


























            p=inputParser;
            addRequired(p,"Surrogate",...
            @(x)validateattributes(x,{'APIs.SurrogateFitter'},{'scalar'}));
            addRequired(p,"DataStorageOrHandle",...
            @(x)validateattributes(x,{'APIs.DataStorage','APIs.ExpensiveHandle'},{'scalar'}));
            parse(p,obj,expensiveDataStorageOrHandle);




            if isa(expensiveDataStorageOrHandle,'APIs.DataStorage')
                surrogateNames=expensiveDataStorageOrHandle.getResponseNames();
                numberIndependentVariables=size(expensiveDataStorageOrHandle.getIndependentVariable(),2);
            else
                surrogateNames=expensiveDataStorageOrHandle.Names;
                numberIndependentVariables=expensiveDataStorageOrHandle.NumberIndependentVariables;
                p=inputParser;
                addRequired(p,"DataStorageOrHandle",...
                @(x)validateattributes(x,{'APIs.DataStorage','APIs.ExpensiveHandle'},{'scalar'}));
                parse(p,varargin{1});
                set(obj,"Range",varargin{1});
            end
            set(obj,"NumberIndependentVariables",numberIndependentVariables);


            if isempty(obj.SurrogateEvaluator)
                error(message("shared_surrogatelib:SurrogateFitter:InvalidEvaluator"));
            end
            set(obj.SurrogateEvaluator,"Names",surrogateNames);


            try
                designs=obj.fitImpl(expensiveDataStorageOrHandle,varargin{:});
            catch causeException
                baseException=MException(message("shared_surrogatelib:SurrogateEvaluator:FailedFit"));
                baseException=addCause(baseException,causeException);
                throw(baseException);
            end

        end


        function designs=update(obj,expensiveDataStorageOrHandle,newDataIndexOrRange,varargin)



























            p=inputParser;
            addRequired(p,"Surrogate",...
            @(x)validateattributes(x,{'APIs.SurrogateFitter'},{'scalar'}));
            addRequired(p,"DataStorageOrExpensiveHandle",...
            @(x)validateattributes(x,{'APIs.DataStorage','APIs.ExpensiveHandle'},{'scalar'}));
            parse(p,obj,expensiveDataStorageOrHandle);

            if isa(expensiveDataStorageOrHandle,'APIs.DataStorage')
                p=inputParser;
                addRequired(p,"NewDataIndex",@(x)validateattributes(x,{'numeric'},{'vector'}));
                parse(p,newDataIndexOrRange);
            else
                set(obj,"Range",varargin{1});
            end

            try
                designs=obj.updateImpl(expensiveDataStorageOrHandle,newDataIndexOrRange,varargin{:});
            catch causeException
                baseException=MException(message("shared_surrogatelib:SurrogateEvaluator:FailedEvaluation"));
                baseException=addCause(baseException,causeException);
                throw(baseException);
            end
        end

        function evaluatorObj=getEvaluator(obj)


















            p=inputParser;
            addRequired(p,"Surrogate",...
            @(x)validateattributes(x,{'APIs.SurrogateFitter'},{'scalar'}));
            parse(p,obj);

            evaluatorObj=copy(obj.SurrogateEvaluator);

        end



        function set.Range(obj,range)
            p=inputParser;
            addRequired(p,"Surrogate",@(x)validateattributes(x,{'APIs.SurrogateFitter'},{'scalar'}));
            addRequired(p,"Value",@(x)validateattributes(x,{'numeric'},{'2d','ncols',2,'nonempty','nonnan'}));
            parse(p,obj,range);
            if~isempty(obj.NumberIndependentVariables)&&obj.NumberIndependentVariables~=size(range,1)
                error(message("shared_surrogatelib:SurrogateFitter:InvalidRange",...
                size(range,1),obj.NumberIndependentVariables));
            end
            obj.NumberIndependentVariables=size(range,1);
            set(obj.SurrogateEvaluator,"Range",range);
        end
        function range=get.Range(obj)
            range=get(obj.SurrogateEvaluator,"Range");
        end



        function gradientSupport=get.GradientSupport(obj)
            p=inputParser;
            addRequired(p,"Surrogate",@(x)validateattributes(x,{'APIs.SurrogateFitter'},{'scalar'}));
            parse(p,obj);
            gradientSupport=get(obj.SurrogateEvaluator,"GradientSupport");
        end


        function hessianSupport=get.HessianSupport(obj)
            p=inputParser;
            addRequired(p,"Surrogate",@(x)validateattributes(x,{'APIs.SurrogateFitter'},{'scalar'}));
            parse(p,obj);
            hessianSupport=get(obj.SurrogateEvaluator,"HessianSupport");
        end


        function samples=drawSamples(obj,numSamples,range,samplingMethod,varargin)

































            p=inputParser;
            addRequired(p,"Surrogate",...
            @(x)validateattributes(x,{'APIs.SurrogateFitter'},{'scalar'}));
            addRequired(p,"NumberSamples",...
            @(x)validateattributes(x,{'numeric'},{'scalar','positive','integer'}));
            addRequired(p,"Range",...
            @(x)validateattributes(x,{'numeric'},{'2d','ncols',2}));
            addRequired(p,"SamplingMethod",...
            @(x)validateattributes(x,{'char','string'},{'scalartext','nonempty'}));
            parse(p,obj,numSamples,range,samplingMethod);
            if~isempty(obj.NumberIndependentVariables)&&obj.NumberIndependentVariables~=size(range,1)
                error(message("shared_surrogatelib:SurrogateFitter:InvalidSamplingRange",...
                size(range,1),obj.NumberIndependentVariables));
            end
            switch lower(samplingMethod)
            case "sobol"

                samples=obj.drawSobolSamplesImpl(numSamples,range,varargin{:});
            case "halton"

                samples=obj.drawHaltonSamplesImpl(numSamples,range,varargin{:});
            case "lhs"

                samples=obj.drawLHSSamplesImpl(numSamples,range,varargin{:});
            case "random"

                samples=obj.drawRandomUniformSamplesImpl(numSamples,range,varargin{:});
            otherwise
                error(method("shared_surrogatelib:SurrogateFitter:UnsupportedSamplingMethod",samplingMethod));
            end
        end
        function samples=drawSobolSamplesImpl(obj,numSamples,range,varargin)


            numParams=size(range,1);
            if isempty(obj.SamplingState.Sobol)
                numExistingSamples=0;
                p=sobolset(numParams,varargin{:});
            elseif~isempty(varargin)
                p=sobolset(numParams,varargin{:});
                numExistingSamples=p.Skip;
            else
                p=obj.SamplingState.Sobol;
                numExistingSamples=p.Skip;
            end
            samples=net(p,numSamples);

            samples=samples.*diff(range,1,2)'+range(:,1)';
            p.Skip=numExistingSamples+numSamples;
            obj.SamplingState.Sobol=p;
        end
        function samples=drawHaltonSamplesImpl(obj,numSamples,range,varargin)


            numParams=size(range,1);
            if isempty(obj.SamplingState.Halton)
                numExistingSamples=0;
                p=haltonset(numParams,varargin{:});
            elseif~isempty(varargin)
                p=haltonset(numParams,varargin{:});
                numExistingSamples=p.Skip;
            else
                p=obj.SamplingState.Halton;
                numExistingSamples=p.Skip;
            end
            samples=net(p,numSamples);

            samples=samples.*diff(range,1,2)'+range(:,1)';
            p.Skip=numExistingSamples+numSamples;
            obj.SamplingState.Halton=p;
        end
        function samples=drawLHSSamplesImpl(obj,numSamples,range,varargin)


            numParams=size(range,1);
            globalStream=RandStream.getGlobalStream();
            if isempty(obj.SamplingState.LHS)
                obj.SamplingState.LHS=RandStream.create(globalStream.Type);
            elseif~isempty(varargin)
                obj.SamplingState.LHS=varargin{1};
            end
            cleanupObj=onCleanup(@()RandStream.setGlobalStream(globalStream));
            RandStream.setGlobalStream(obj.SamplingState.LHS);
            samples=lhsdesign(numSamples,numParams,varargin{:});

            samples=samples.*diff(range,1,2)'+range(:,1)';
            delete(cleanupObj);
        end
        function samples=drawRandomUniformSamplesImpl(obj,numSamples,range,varargin)


            numParams=size(range,1);
            globalStream=RandStream.getGlobalStream();
            if isempty(obj.SamplingState.Random)
                obj.SamplingState.Random=RandStream.create(globalStream.Type);
            elseif~isempty(varargin)
                obj.SamplingState.Random=varargin{1};
            end
            cleanupObj=onCleanup(@()RandStream.setGlobalStream(globalStream));
            RandStream.setGlobalStream(obj.SamplingState.Random);
            samples=rand(numSamples,numParams,varargin{:});

            samples=samples.*diff(range,1,2)'+range(:,1)';
            delete(cleanupObj);
        end

        function obj=resetSamplingState(obj,samplingMethod)




            if nargin<=1
                obj.SamplingState.Sobol={};
                obj.SamplingState.Halton={};
                obj.SamplingState.LHS={};
                obj.SamplingState.Random={};
            end

            switch lower(samplingMethod)
            case "sobol"

                obj.SamplingState.Sobol=[];
            case "halton"

                obj.SamplingState.Halton=[];
            case "lhs"

                obj.SamplingState.LHS=[];
            case "random"

                obj.SamplingState.Random=[];
            otherwise
                error(method("shared_surrogatelib:SurrogateFitter:UnsupportedSamplingMethod",samplingMethod));
            end
        end
        function set.SamplingState(obj,val)
            if~isempty(val.Sobol)&&~isa(val.Sobol,"sobolset")&&~isscalar(val.Sobol)
                error(method("shared_surrogatelib:SurrogateFitter:UnsupportedSamplingState","Sobol","sobolset","sobolset"));
            end
            if~isempty(val.Halton)&&~isa(val.Halton,"haltonset")&&~isscalar(val.Halton)
                error(method("shared_surrogatelib:SurrogateFitter:UnsupportedSamplingState","Halton","haltonset","haltonset"));
            end
            if~isempty(val.LHS)&&~isa(val.LHS,"RandStream")&&~isscalar(val.LHS)
                error(method("shared_surrogatelib:SurrogateFitter:UnsupportedSamplingState","LHS","Randstream","RandStream.create"));
            end
            if~isempty(val.Random)&&~isa(val.Random,"RandStream")&&~isscalar(val.Random)
                error(method("shared_surrogatelib:SurrogateFitter:UnsupportedSamplingState","LHS","Randstream","RandStream.create"));
            end
            obj.SamplingState=val;
        end
    end
    methods







































        function varargout=parenReference(obj,x,varargin)

            p=inputParser;
            addRequired(p,"Surrogate",@(x)validateattributes(x,{'APIs.SurrogateFitter'},{'scalar'}));
            parse(p,obj);

            varargout=cell(1,nargout);



            [varargout{:}]=obj.SurrogateEvaluator(x,varargin{:});
        end
        function grad=gradient(obj,x,varargin)


























            p=inputParser;
            addRequired(p,"Surrogate",@(x)validateattributes(x,{'APIs.SurrogateFitter'},{'scalar'}));
            parse(p,obj);


            grad=obj.SurrogateEvaluator.gradient(x,varargin{:});

        end

        function hess=hessian(obj,x,varargin)


























            p=inputParser;
            addRequired(p,"Surrogate",@(x)validateattributes(x,{'APIs.SurrogateFitter'},{'scalar'}));
            parse(p,obj);


            hess=obj.SurrogateEvaluator.hessian(x,varargin{:});

        end
    end
    properties(GetAccess=protected,SetAccess=protected)

        NumberIndependentVariables;
    end
    properties(GetAccess=public,SetAccess=protected)

NumberRequiredPoints
    end
    properties(GetAccess=protected,SetAccess=protected)














        SurrogateEvaluator(1,1)
    end
    methods
        function set.SurrogateEvaluator(obj,value)
            if~isvalid(value)||~isa(value,"APIs.SurrogateEvaluator")
                error(message("shared_surrogatelib:SurrogateFitter:InvalidSurrogateEvaluator"));
            end
            obj.SurrogateEvaluator=value;
        end
    end
end
