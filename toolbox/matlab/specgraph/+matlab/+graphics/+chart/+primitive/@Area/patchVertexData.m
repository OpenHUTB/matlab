function[xCoords,yCoords]=patchVertexData(hObj,adjustBase)






    xCoords=zeros(0,1);
    yCoords=zeros(0,1);

    x=hObj.AreaLayoutData.XData;
    y=hObj.AreaLayoutData.YData;
    valid=isfinite(hObj.AreaLayoutData.Order);

    if~isempty(y)
        if adjustBase







            if hObj.BaseArea

                y(:,1)=hObj.BaseValue;
            end



            [x,y]=matlab.graphics.chart.primitive.area.internal.fixSelfIntersectingFaces(x,y);
        else

            y(~valid,2)=NaN;
        end


        xCoords=[x(1,1);x;flipud(x)];
        yCoords=[y(1,1);y(:,2);flipud(y(:,1))];
    end

end
