classdef ConstType




    enumeration
        NOT_A_CONST(0)
        IS_A_CONST(1)
        TUNABLE_CONST(2)
        INDETERMINABLE_IF_CONST(3)
        PARTIALLY_CONST(4)
    end

    methods
        function obj=ConstType(variableConstness)
            switch variableConstness
            case 'NOT_A_CONST'
                obj=internal.mtree.analysis.ConstType.NOT_A_CONST;
            case 'IS_A_CONST'
                obj=internal.mtree.analysis.ConstType.IS_A_CONST;
            case 'TUNABLE_CONST'
                obj=internal.mtree.analysis.ConstType.TUNABLE_CONST;
            case 'INDETERMINABLE_IF_CONST'
                obj=internal.mtree.analysis.ConstType.INDETERMINABLE_IF_CONST;
            case 'PARTIALLY_CONST'
                obj=internal.mtree.analysis.ConstType.PARTIALLY_CONST;
            end
        end
    end
end

