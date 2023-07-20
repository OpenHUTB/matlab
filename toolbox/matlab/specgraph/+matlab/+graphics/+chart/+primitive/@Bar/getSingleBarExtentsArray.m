function[xd,yd]=getSingleBarExtentsArray(hObj,constraints)







    width=abs(hObj.BarWidth*hObj.WidthScaleFactor);
    xOffset=hObj.XOffset;
    yOffset=hObj.YOffset;
    xData=double(hObj.XDataCache);
    yExtentData=double(hObj.YDataCache);


    if numel(xData)~=numel(yExtentData)
        xd=[];
        yd=[];
        return
    end

    if numel(yOffset)==numel(yExtentData)

        yExtentData=yExtentData+yOffset;
    end















    xExtentData=xData(isfinite(xData));

    vIsFinite=isfinite(xData)&isfinite(yExtentData);
    yExtentData=yExtentData(vIsFinite);


    xd=[xExtentData+xOffset-width/2;
    xExtentData+xOffset;
    xExtentData+xOffset+width/2];



    yd=yExtentData;


    if strcmpi(hObj.Horizontal,'off')
        [xd,yd]=applyConstraints(xd,yd,constraints,'XConstraints');

        if strcmp(hObj.XLimInclude,'off')
            xd=[];
        end
        if strcmp(hObj.YLimInclude,'off')
            yd=[];
        end


    else

        [xd,yd]=applyConstraints(xd,yd,constraints,'YConstraints');


        if strcmp(hObj.XLimInclude,'off')
            yd=[];
        end


        if strcmp(hObj.YLimInclude,'off')
            xd=[];
        end
    end

end


function[xd,yd]=applyConstraints(xd,yd,constraints,field)

    if~isempty(constraints)&&isfield(constraints,field)&&~isempty(xd)
        mask=(xd>=constraints.(field)(1))&(xd<=constraints.(field)(2));
        xd=xd(mask);
        mask=any(mask(:,1:numel(yd)),1);
        yd=yd(mask);
    end
end
