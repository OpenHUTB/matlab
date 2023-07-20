classdef(Sealed)SimplePoint<matlab.graphics.shape.internal.util.PrimitivePoint








    properties(Access=private)




        Point=[0,0,0];
    end

    methods

        function obj=SimplePoint(pt)





            if nargin
                narginchk(1,1);

                obj.Point=pt;
            end
        end

        function obj=set.Point(obj,newval)
            matlab.graphics.shape.internal.util.PrimitivePoint.checkIsPoint(newval);
            obj.Point=newval;
        end

        function pt=doGetLocation(obj,~,~)





            pt=double(obj.Point);
        end
    end
end
