classdef SystemObject<internal.mtree.Type





    properties(Access=public)
        ClassName(1,1)string
        IsPIRBased(1,1)logical
    end

    methods(Access=public)
        function this=SystemObject(className,isPIRBased)
            this=this@internal.mtree.Type([1,1]);

            this.ClassName=className;
            this.IsPIRBased=isPIRBased;
        end

        function name=getMLName(this)

            name=this.ClassName;
        end

        function type=toSlName(this)
            type=this.ClassName;
        end

        function doesit=supportsExampleValues(~)
            doesit=false;
        end

    end
    methods(Access=protected)
        function exVal=getExampleValueScalar(~)%#ok<STOUT>
            error('Cannot return scalar value for SystemObject type.');
        end

        function exStr=getExampleValueStringScalar(~)%#ok<STOUT>
            error('Cannot return a string value for SystemObject type.');
        end

        function res=isTypeEqualScalar(this,other)
            res=strcmp(this.ClassName,other.ClassName)&&(this.IsPIRBased==other.IsPIRBased);
        end

        function type=toScalarPIRType(~)





            type=pir_double_t;
        end
    end
end


