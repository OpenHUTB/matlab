classdef MemoryValue























    properties(Access=private)
        ValueInBits(1,:)double{mustBeReal,mustBeNonnegative}
    end

    properties(Dependent)
        Value(1,:)double{mustBeReal,mustBeNonnegative}
    end

    properties
        Unit FunctionApproximation.internal.MemoryUnit
    end

    methods
        function this=MemoryValue(value,varargin)


            p=inputParser;
            addRequired(p,'Value',@isnumeric);
            addOptional(p,'Unit',FunctionApproximation.internal.MemoryUnit.bits);
            parse(p,value,varargin{:});
            value=p.Results.Value;
            units=p.Results.Unit;



            this.Unit=units;
            conversionFactor=FunctionApproximation.internal.MemoryUnit.getConversionFactor(...
            this.Unit,FunctionApproximation.internal.MemoryUnit.bits);
            this.ValueInBits=value*conversionFactor;
        end

        function value=get.Value(this)
            conversionFactor=FunctionApproximation.internal.MemoryUnit.getConversionFactor(...
            FunctionApproximation.internal.MemoryUnit.bits,...
            this.Unit);
            value=this.ValueInBits*conversionFactor;
        end

        function unit=get.Unit(this)

            unit=this.Unit;
        end

        function this=set.Unit(this,newUnit)

            this.Unit=newUnit;
        end

        function flag=eq(this,other)

            flag=isa(other,class(this))&&(getBits(this)==getBits(other));
        end

        function value=getBits(this)

            value=this.ValueInBits;
        end

        function value=getBytes(this)

            value=0.125*this.ValueInBits;
        end
    end
end