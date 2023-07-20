function[vd,stripData]=transformPoints(us,x,y,z)




    if isempty(x)



        vd=[];
        stripData=[];

    else




        iter=matlab.graphics.axis.dataspace.XYZPointsIterator;
        iter.XData=x;
        iter.YData=y;
        iter.ZData=z;

        vd=TransformPoints(us.DataSpace,...
        us.TransformUnderDataSpace,...
        iter);



        stripData=uint32([1,numel(x)+1]);

    end

end