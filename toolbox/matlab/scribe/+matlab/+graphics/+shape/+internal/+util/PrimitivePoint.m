classdef PrimitivePoint









    properties








        Is2D=false;
    end

    methods(Sealed)
        function point=getLocation(obj,dataspace,transformmatrix)



















            if nargin==2&&isa(dataspace,'matlab.graphics.Graphics')
                [~,transformmatrix,dataspace,~]=matlab.graphics.internal.getSpatialTransforms(dataspace);
            end
            if isempty(dataspace)

                dataspace=matlab.graphics.axis.dataspace.DataSpace;
            end

            point=doGetLocation(obj,dataspace,transformmatrix);
            if obj.Is2D
                point=point(1:2);
            end
        end
    end

    methods(Abstract)











        point=doGetLocation(obj,dataspace,transformmatrix)
    end


    methods(Static,Access=protected)
        function X=transform(ds,matrix,X)








            iter=matlab.graphics.axis.dataspace.XYZPointsIterator(...
            'XData',X(1,:),...
            'YData',X(2,:),...
            'ZData',X(3,:));
            X=double(ds.TransformPoints(matrix,iter));
        end

        function X=untransform(ds,matrix,X)












            iter=matlab.graphics.axis.dataspace.XYZPointsIterator(...
            'XData',single(X(1,:)),...
            'YData',single(X(2,:)),...
            'ZData',single(X(3,:)));
            X=ds.UntransformPoints(matrix,iter);
        end

        function checkIsPoint(value)





            if~isnumeric(value)...
                ||~isreal(value)...
                ||~isequal(size(value),[1,3])
                m=message('MATLAB:graphics:shape:internal:util:PrimitivePoint:InvalidPoint');
                throwAsCaller(MException(m.Identifier,m.getString()));
            end
        end

        function checkIsFraction(value)






            if~isnumeric(value)...
                ||~isa(value,'double')...
                ||~isreal(value)...
                ||~isscalar(value)
                m=message('MATLAB:graphics:shape:internal:util:PrimitivePoint:InvalidFraction');
                throwAsCaller(MException(m.Identifier,m.getString()));
            end
        end
    end
end
