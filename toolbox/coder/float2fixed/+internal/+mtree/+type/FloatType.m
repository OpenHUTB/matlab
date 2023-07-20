





classdef FloatType<internal.mtree.type.NumericType
    methods(Access=protected)
        function this=FloatType(dimensions,isComplex)
            this=this@internal.mtree.type.NumericType(dimensions,isComplex);
        end
    end
end
