




classdef Half<internal.mtree.type.FloatType

    methods(Access=public)

        function this=Half(dimensions,isComplex)
            this=this@internal.mtree.type.FloatType(dimensions,isComplex)
        end

        function name=getMLName(~)
            name='half';
        end

        function type=toSlName(~)%#ok<STOUT>
            error('Half type is not supported by Simulink');
        end

        function doesit=supportsExampleValues(~)
            doesit=true;
        end

    end

    methods(Access=protected)

        function type=toPIRLeafType(~)
            type=pir_half_t;
        end

        function realVal=getExampleValueScalarReal(~)
            realVal=half(1);
        end

        function realStr=getExampleValueStringScalarReal(~)
            realStr='half(1)';
        end

        function res=isTypeEqualScalarReal(~,other)

            res=isa(other,'internal.mtree.type.Half');
        end

    end

end
