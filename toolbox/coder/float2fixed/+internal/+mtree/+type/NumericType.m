classdef NumericType<internal.mtree.Type





    properties(Access=public)
        Complex(1,1)logical
    end

    methods(Access=protected)

        function this=NumericType(dimensions,isComplex)
            this=this@internal.mtree.Type(dimensions);
            this.Complex=isComplex;
        end


        function type=toScalarPIRType(this)
            if this.Complex
                type=pir_complex_t(this.toPIRLeafType);
            else
                type=this.toPIRLeafType;
            end
        end


        function exVal=getExampleValueScalar(this)
            realVal=this.getExampleValueScalarReal;

            if this.Complex
                exVal=complex(realVal,realVal);
            else
                exVal=realVal;
            end
        end


        function exValStr=getExampleValueStringScalar(this)
            realStr=this.getExampleValueStringScalarReal;

            if this.Complex
                exValStr=sprintf('complex(%s, %s)',realStr,realStr);
            else
                exValStr=realStr;
            end
        end



        function scalarEq=isTypeEqualScalar(this,other)
            if isa(other,'internal.mtree.type.NumericType')&&...
                this.Complex==other.Complex
                scalarEq=this.isTypeEqualScalarReal(other);
            else
                scalarEq=false;
            end
        end

    end

    methods(Abstract,Access=protected)

        type=toPIRLeafType(this);

        realVal=getExampleValueScalarReal(this);

        realStr=getExampleValueStringScalarReal(this);

        realEq=isTypeEqualScalarReal(this,other);

    end

end
