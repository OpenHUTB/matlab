function point=doGetReportedPosition(hObj,index,~)








    [ny,nx]=size(hObj.ColorData);

    if index>0&&index<=nx*ny

        [y,x]=ind2sub([ny,nx],index);
    else
        x=NaN;
        y=NaN;
    end


    point=matlab.graphics.shape.internal.util.SimplePoint([x,y,0]);
    point.Is2D=true;

end
