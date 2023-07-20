classdef(Abstract)AbstractWrapper<matlab.mixin.Copyable






    properties(SetAccess=protected)
FunctionToEvaluate
NumberOfDimensions
LastOutput
    end

    properties(SetAccess=private,GetAccess=private)
        Vectorized logical=true
    end

    methods(Access=protected)


        outputValue=execute(this,inputs);
    end

    methods(Access=private)
        function setLastOutput(this,lastOutput)
            this.LastOutput=lastOutput;
        end
    end

    methods
        function outputValues=evaluate(this,inputs)

            outputValues=execute(this,inputs);
            setLastOutput(this,outputValues);
        end

        function setVectorized(this,value)
            this.Vectorized=value;
        end

        function flag=getVectorized(this)
            flag=this.Vectorized;
        end
    end

    methods(Sealed)







        function wrapper=abs(this)


            wrapper=FunctionApproximation.internal.functionwrapper.AbsoluteValueWrapper(this);
        end

        function wrapper=times(this,other)


            if isnumeric(other)&&isscalar(other)&&isa(this,'FunctionApproximation.internal.functionwrapper.AbstractWrapper')

                wrapper=FunctionApproximation.internal.functionwrapper.ScaledValueWrapper(this,other);
            elseif isnumeric(this)&&isscalar(this)&&isa(other,'FunctionApproximation.internal.functionwrapper.AbstractWrapper')

                wrapper=FunctionApproximation.internal.functionwrapper.ScaledValueWrapper(other,this);
            elseif isa(other,'FunctionApproximation.internal.functionwrapper.AbstractWrapper')&&isa(this,'FunctionApproximation.internal.functionwrapper.AbstractWrapper')

                wrapper=FunctionApproximation.internal.functionwrapper.MultiplyWrapper(this,other);
            end
        end

        function wrapper=uminus(this)


            wrapper=-1.*this;
        end

        function wrapper=plus(this,other)

            if isnumeric(other)&&isscalar(other)&&isa(this,'FunctionApproximation.internal.functionwrapper.AbstractWrapper')

                wrapper=FunctionApproximation.internal.functionwrapper.AddConstantWrapper(this,other);
            elseif isnumeric(this)&&isscalar(this)&&isa(other,'FunctionApproximation.internal.functionwrapper.AbstractWrapper')

                wrapper=FunctionApproximation.internal.functionwrapper.AddConstantWrapper(other,this);
            else

                wrapper=FunctionApproximation.internal.functionwrapper.AddWrapper(this,other);
            end
        end

        function wrapper=minus(this,other)


            wrapper=this+(-other);
        end

        function wrapper=power(this,other)

            if isnumeric(other)&&isscalar(other)
                wrapper=FunctionApproximation.internal.functionwrapper.PowerWrapper(this,other);
            end
        end

        function wrapper=rdivide(this,other)

            wrapper=this.*(other.^-1);
        end

        function wrapper=fiWrapper(this,varargin)

            wrapper=FunctionApproximation.internal.functionwrapper.FiWrapper(this,varargin{:});
        end

        function wrapper=infProtect(this,negativeInfCorrection,positiveInfCorrection)


            mustBeFinite(negativeInfCorrection)
            mustBeFinite(positiveInfCorrection)
            wrapper=FunctionApproximation.internal.functionwrapper.InfProtectedWrapper(this,negativeInfCorrection,positiveInfCorrection);
        end

        function wrapper=saturateWrapper(this,minCorrection,maxCorrection)


            mustBeFinite(minCorrection)
            mustBeFinite(maxCorrection)
            wrapper=FunctionApproximation.internal.functionwrapper.SaturationWrapper(this,minCorrection,maxCorrection);
        end

        function wrapper=nanProtect(this,nanCorrection)

            mustBeFinite(nanCorrection)
            wrapper=FunctionApproximation.internal.functionwrapper.NaNProtectedWrapper(this,nanCorrection);
        end

        function wrapper=max(this,other)


            if isnumeric(other)&&isscalar(other)&&isa(this,'FunctionApproximation.internal.functionwrapper.AbstractWrapper')
                wrapper=FunctionApproximation.internal.functionwrapper.MaxWithConstantWrapper(this,other);
            elseif isnumeric(this)&&isscalar(this)&&isa(other,'FunctionApproximation.internal.functionwrapper.AbstractWrapper')
                wrapper=FunctionApproximation.internal.functionwrapper.MaxWithConstantWrapper(other,this);
            end
        end

        function wrapper=castToType(this,dataType)


            if isfloat(dataType)
                if isdouble(dataType)
                    wrapper=FunctionApproximation.internal.functionwrapper.CastToDoubleWrapper(this);
                elseif issingle(dataType)
                    wrapper=FunctionApproximation.internal.functionwrapper.CastToSingleWrapper(this);
                end
            else
                wrapper=FunctionApproximation.internal.functionwrapper.CastToTypeWrapper(this,dataType);
            end
        end
    end
end
