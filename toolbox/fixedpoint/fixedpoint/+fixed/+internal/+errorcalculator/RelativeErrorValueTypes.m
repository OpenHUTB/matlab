classdef(Sealed)RelativeErrorValueTypes<fixed.internal.errorcalculator.NumericValueTypes






    properties(SetAccess=private)
Zeros
FiniteNonZeros
    end

    methods
        function this=RelativeErrorValueTypes(value)
            this=this@fixed.internal.errorcalculator.NumericValueTypes(value);
            this.Zeros=value==0;
            this.FiniteNonZeros=this.Finites&~this.Zeros;
        end

        function result=divide(this,other)

            result=fixed.internal.errorcalculator.RelativeErrorValueTypes(1);








            result.Zeros=this.Zeros;
            result.NaNs=~result.Zeros...
            &(this.NaNs|(this.Infs&other.Infs));
            result.Infs=~result.Zeros&(~result.NaNs)...
            &(this.Infs|other.Zeros);
            result.FiniteNonZeros=this.FiniteNonZeros&other.FiniteNonZeros;
            result.Size=this.Size;
        end
    end
end
