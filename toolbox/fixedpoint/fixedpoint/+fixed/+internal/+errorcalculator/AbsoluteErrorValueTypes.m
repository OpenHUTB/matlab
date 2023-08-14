classdef(Sealed)AbsoluteErrorValueTypes<fixed.internal.errorcalculator.NumericValueTypes







    properties(SetAccess=private)
Zeros
PosInfs
NegInfs
    end

    methods
        function this=AbsoluteErrorValueTypes(value)
            this=this@fixed.internal.errorcalculator.NumericValueTypes(value);
            this.Zeros=zeros(this.Size);


            this.PosInfs=this.Infs&(value>0);
            this.NegInfs=this.Infs&(value<0);
        end

        function result=subtract(this,other)
            result=fixed.internal.errorcalculator.AbsoluteErrorValueTypes(1);




            result.Zeros=(this.NaNs&other.NaNs)...
            |(this.PosInfs&other.PosInfs)...
            |(this.NegInfs&other.NegInfs);

            result.NaNs=xor(this.NaNs,other.NaNs);


            result.Infs=~result.NaNs&~result.Zeros...
            &(this.Infs|other.Infs);








            result.PosInfs=result.Infs&(this.PosInfs|other.NegInfs);
            result.NegInfs=result.Infs&(this.NegInfs|other.PosInfs);
            result.Size=this.Size;
        end
    end
end
