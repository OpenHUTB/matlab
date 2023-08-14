classdef(Sealed)LinePoint<matlab.graphics.shape.internal.util.PrimitivePoint










    properties(Access=private)




        AnchorPoint=[0,0,0];





        EndPoint=[0,0,0];





        InterpolationFraction=0;
    end

    methods

        function obj=LinePoint(startPoint,endPoint,fraction)






            if nargin
                narginchk(3,3);

                obj.AnchorPoint=startPoint;
                obj.EndPoint=endPoint;
                obj.InterpolationFraction=fraction;
            end
        end

        function obj=set.AnchorPoint(obj,newval)
            matlab.graphics.shape.internal.util.PrimitivePoint.checkIsPoint(newval);
            obj.AnchorPoint=newval;
        end

        function obj=set.EndPoint(obj,newval)
            matlab.graphics.shape.internal.util.PrimitivePoint.checkIsPoint(newval);
            obj.EndPoint=newval;
        end

        function obj=set.InterpolationFraction(obj,newval)
            matlab.graphics.shape.internal.util.PrimitivePoint.checkIsFraction(newval);
            obj.InterpolationFraction=newval;
        end

        function pt=doGetLocation(obj,ds,matrix)





            if obj.InterpolationFraction==0


                pt=double(obj.AnchorPoint);
            elseif obj.InterpolationFraction==1


                pt=double(obj.EndPoint);
            else


                cs_points=matlab.graphics.shape.internal.util.PrimitivePoint.transform(...
                ds,matrix,[obj.AnchorPoint(:),obj.EndPoint(:)]);


                pt=cs_points(:,1)+obj.InterpolationFraction.*(cs_points(:,2)-cs_points(:,1));


                pt=matlab.graphics.shape.internal.util.PrimitivePoint.untransform(...
                ds,matrix,pt);
                pt=pt(:).';
            end
        end
    end
end
