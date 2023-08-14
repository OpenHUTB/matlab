


classdef(Abstract)Type<handle


    properties

    end

    methods

        function obj=Type()

        end


        function isa=isFlexibleWidth(obj)%#ok<*MANU>

            isa=false;
        end
        function isa=isBusType(obj)
            isa=false;
        end
        function isa=isFixedPtType(obj)
            isa=false;
        end
        function isa=isBooleanType(obj)
            isa=false;
        end
        function isa=isSingleType(obj)
            isa=false;
        end
        function isa=isDoubleType(obj)
            isa=false;
        end
        function isa=isHalfType(obj)
            isa=false;
        end

        function initFromPirType(~,~)

        end

        function maxWL=getMaxWordLength(obj)
            maxWL=0;
        end
        function wl=getWordLength(obj)
            wl=0;
        end


    end
end
