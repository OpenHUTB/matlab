function extents=getXYZDataExtents(hObj,transform,constraints)





    yData=double(hObj.YDataCache);
    xData=double(hObj.XDataCache);
    xNeg=abs(double(hObj.XNegativeDeltaCache));
    xPos=abs(double(hObj.XPositiveDeltaCache));
    yNeg=abs(double(hObj.YNegativeDeltaCache));
    yPos=abs(double(hObj.YPositiveDeltaCache));


    numPoints=numel(yData);
    if numel(xData)~=numPoints||...
        (~isempty(xNeg)&&numel(xNeg)~=numPoints)||...
        (~isempty(xPos)&&numel(xPos)~=numPoints)||...
        (~isempty(yNeg)&&numel(yNeg)~=numPoints)||...
        (~isempty(yPos)&&numel(yPos)~=numPoints)


        extents=[];
        return
    end


    if~isempty(constraints)&&isfield(constraints,'XConstraints')&&~isempty(xData)
        mask=(xData>=constraints.XConstraints(1))&(xData<=constraints.XConstraints(2));
    else
        mask=true(size(xData));
    end




    xd=xData(:,mask);
    yd=yData(:,mask);


    if~isempty(xNeg)
        xd=[xd,xData(mask)-xNeg(mask)];
        yd=[yd,yData(mask)];
    end

    if~isempty(xPos)
        xd=[xd,xData(mask)+xPos(mask)];
        yd=[yd,yData(mask)];
    end

    if~isempty(yNeg)
        xd=[xd,xData(mask)];
        yd=[yd,yData(mask)-yNeg(mask)];
    end

    if~isempty(yPos)
        xd=[xd,xData(mask)];
        yd=[yd,yData(mask)+yPos(mask)];
    end


    vertices=[xd;yd;zeros(1,numel(xd));ones(1,numel(xd))];
    finite=all(isfinite(vertices),1);
    vertices=vertices(:,finite);


    vertices=transform*vertices;


    xd=[];
    if strcmp(hObj.XLimInclude,'on')
        xd=vertices(1,:);
    end

    yd=[];
    if strcmp(hObj.YLimInclude,'on')
        yd=vertices(2,:);
    end


    xlim=matlab.graphics.chart.primitive.utilities.arraytolimits(xd);
    ylim=matlab.graphics.chart.primitive.utilities.arraytolimits(yd);
    zlim=matlab.graphics.chart.primitive.utilities.arraytolimits(0);

    extents=[xlim;ylim;zlim];

end
