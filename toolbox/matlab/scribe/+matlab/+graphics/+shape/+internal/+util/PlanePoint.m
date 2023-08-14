classdef(Sealed)PlanePoint<matlab.graphics.shape.internal.util.PrimitivePoint









    properties(Access=private)





        AnchorPoint=[0,0,0];







        FirstPoint=[0,0,0];







        SecondPoint=[0,0,0];





        FirstFraction=0;





        SecondFraction=0;
    end

    methods

        function obj=PlanePoint(startPoint,firstPoint,firstFraction,secondPoint,secondFraction)






            if nargin
                narginchk(5,5);

                obj.AnchorPoint=startPoint;
                obj.FirstPoint=firstPoint;
                obj.FirstFraction=firstFraction;
                obj.SecondPoint=secondPoint;
                obj.SecondFraction=secondFraction;
            end
        end

        function obj=set.AnchorPoint(obj,newval)
            matlab.graphics.shape.internal.util.PrimitivePoint.checkIsPoint(newval);
            obj.AnchorPoint=newval;
        end

        function obj=set.FirstPoint(obj,newval)
            matlab.graphics.shape.internal.util.PrimitivePoint.checkIsPoint(newval);
            obj.FirstPoint=newval;
        end

        function obj=set.SecondPoint(obj,newval)
            matlab.graphics.shape.internal.util.PrimitivePoint.checkIsPoint(newval);
            obj.SecondPoint=newval;
        end

        function obj=set.FirstFraction(obj,newval)
            matlab.graphics.shape.internal.util.PrimitivePoint.checkIsFraction(newval);
            obj.FirstFraction=newval;
        end

        function obj=set.SecondFraction(obj,newval)
            matlab.graphics.shape.internal.util.PrimitivePoint.checkIsFraction(newval);
            obj.SecondFraction=newval;
        end

        function pt=doGetLocation(obj,ds,matrix)





            if obj.FirstFraction==0&&obj.SecondFraction==0


                pt=double(obj.AnchorPoint);
            else


                cs_points=matlab.graphics.shape.internal.util.PrimitivePoint.transform(...
                ds,matrix,[obj.AnchorPoint(:),obj.FirstPoint(:),obj.SecondPoint(:)]);


                pt=cs_points(:,1)...
                +obj.FirstFraction.*(cs_points(:,2)-cs_points(:,1))...
                +obj.SecondFraction.*(cs_points(:,3)-cs_points(:,1));


                pt=matlab.graphics.shape.internal.util.PrimitivePoint.untransform(...
                ds,matrix,pt);
                pt=pt(:).';
            end
        end
    end
end
