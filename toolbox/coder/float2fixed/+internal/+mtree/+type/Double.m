




classdef Double<internal.mtree.type.FloatType

    methods(Access=public)

        function this=Double(dimensions,isComplex)
            this=this@internal.mtree.type.FloatType(dimensions,isComplex)
        end

        function name=getMLName(~)
            name='double';
        end

        function type=toSlName(~)
            type='double';
        end

        function doesit=supportsExampleValues(~)
            doesit=true;
        end

    end

    methods(Access=protected)

        function type=toPIRLeafType(~)
            type=pir_double_t;
        end

        function realVal=getExampleValueScalarReal(~)
            realVal=1;
        end

        function realStr=getExampleValueStringScalarReal(~)
            realStr='1';
        end

        function res=isTypeEqualScalarReal(~,other)

            res=isa(other,'internal.mtree.type.Double');
        end

    end

end
