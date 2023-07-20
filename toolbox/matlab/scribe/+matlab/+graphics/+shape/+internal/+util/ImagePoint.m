classdef(Sealed)ImagePoint<matlab.graphics.shape.internal.util.PrimitivePoint









    properties(Access=private)




        XData=[0,0];





        YData=[0,0];





        DataSize=[0,0];





        XIndex=0;





        YIndex=0;
    end

    methods

        function obj=ImagePoint(xData,yData,dataSize,xInd,yInd)






            if nargin
                narginchk(5,5);
                obj.XData=xData;
                obj.YData=yData;
                obj.DataSize=dataSize;
                obj.XIndex=xInd;
                obj.YIndex=yInd;
            end
        end

        function obj=set.XData(obj,newval)
            matlab.graphics.shape.internal.util.ImagePoint.checkIsExtent(newval);
            obj.XData=newval;
        end

        function obj=set.YData(obj,newval)
            matlab.graphics.shape.internal.util.ImagePoint.checkIsExtent(newval);
            obj.YData=newval;
        end

        function obj=set.DataSize(obj,newval)
            matlab.graphics.shape.internal.util.ImagePoint.checkIsSize(newval);
            obj.DataSize=newval;
        end

        function obj=set.XIndex(obj,newval)
            matlab.graphics.shape.internal.util.ImagePoint.checkIsIndex(newval);
            obj.XIndex=newval;
        end

        function obj=set.YIndex(obj,newval)
            matlab.graphics.shape.internal.util.ImagePoint.checkIsIndex(newval);
            obj.YIndex=newval;
        end

        function pt=doGetLocation(obj,ds,matrix)







            bl=[obj.XData(1);obj.YData(1);0];
            tr=[obj.XData(2);obj.YData(2);0];



            cs_points=matlab.graphics.shape.internal.util.PrimitivePoint.transform(...
            ds,matrix,[bl,tr]);

            dataSize=obj.DataSize;



            xStart=cs_points(1,1);
            xEnd=cs_points(1,2);
            xDiff=xEnd-xStart;






            xNum=dataSize(2)*xStart+(obj.XIndex-0.5)*xDiff;
            xLocation=xNum/dataSize(2);



            yStart=cs_points(2,1);
            yEnd=cs_points(2,2);
            yDiff=yEnd-yStart;

            yNum=dataSize(1)*yStart+(obj.YIndex-0.5)*yDiff;
            yLocation=yNum/dataSize(1);


            pt=matlab.graphics.shape.internal.util.PrimitivePoint.untransform(...
            ds,matrix,[xLocation;yLocation;0]);
            pt=pt(:).';

        end
    end


    methods(Access=private,Static)
        function checkIsExtent(value)





            if~isnumeric(value)...
                ||~isreal(value)...
                ||~isvector(value)...
                ||size(value,1)~=1...
                ||size(value,2)~=2
                m=message('MATLAB:graphics:shape:internal:util:ImagePoint:InvalidExtent');
                throwAsCaller(MException(m.Identifier,m.getString()));
            end
        end

        function checkIsSize(value)





            if~isnumeric(value)...
                ||~isa(value,'double')...
                ||~isreal(value)...
                ||~isvector(value)...
                ||size(value,1)~=1...
                ||size(value,2)~=2...
                ||any(value<0)
                m=message('MATLAB:graphics:shape:internal:util:ImagePoint:InvalidSize');
                throwAsCaller(MException(m.Identifier,m.getString()));
            end
        end

        function checkIsIndex(value)





            if~isnumeric(value)...
                ||~isa(value,'double')...
                ||~isreal(value)...
                ||~isscalar(value)
                m=message('MATLAB:graphics:shape:internal:util:ImagePoint:InvalidIndex');
                throwAsCaller(MException(m.Identifier,m.getString()));
            end
        end

    end
end
