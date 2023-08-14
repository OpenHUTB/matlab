




classdef Single<internal.mtree.type.FloatType

    methods(Access=public)

        function this=Single(dimensions,isComplex)
            this=this@internal.mtree.type.FloatType(dimensions,isComplex);
        end

        function name=getMLName(~)
            name='single';
        end

        function type=toSlName(~)
            type='single';
        end

        function doesit=supportsExampleValues(~)
            doesit=true;
        end

    end

    methods(Access=protected)

        function type=toPIRLeafType(~)
            type=pir_single_t;
        end

        function realVal=getExampleValueScalarReal(~)
            realVal=single(1);
        end

        function realStr=getExampleValueStringScalarReal(~)
            realStr='single(1)';
        end

        function res=isTypeEqualScalarReal(~,other)

            res=isa(other,'internal.mtree.type.Single');
        end

    end

end
