




classdef Logical<internal.mtree.Type

    methods(Access=public)

        function this=Logical(dimensions)
            this=this@internal.mtree.Type(dimensions);
        end

        function name=getMLName(~)
            name='logical';
        end

        function type=toSlName(~)
            type='boolean';
        end

        function doesit=supportsExampleValues(~)
            doesit=true;
        end

    end

    methods(Access=protected)

        function type=toScalarPIRType(~)
            type=pir_boolean_t;
        end

        function exVal=getExampleValueScalar(~)
            exVal=false;
        end

        function exStr=getExampleValueStringScalar(~)
            exStr='false';
        end

        function res=isTypeEqualScalar(~,other)

            res=isa(other,'internal.mtree.type.Logical');
        end

    end

end
